require('dns').setDefaultResultOrder('ipv4first');
/**
 * One-time / re-runnable provisioning script — creates a Firebase Auth
 * account for every staff member who has portal access (staff docs with
 * both `employeeId` and `password` set), and sets custom claims for both
 * staff and admins so Storage security rules can check role without a
 * cross-service Firestore lookup (see note below).
 *
 * Why this exists: the `staff` collection stores employeeId/password in
 * PLAINTEXT. That's fine as data the admin panel manages, but the mobile
 * app must never let an unauthenticated client read that collection to
 * check a password (Firestore rules can't redact individual fields — any
 * rule permissive enough to check the password would also return it).
 *
 * Instead, each staff member gets a real Firebase Auth account:
 *   - uid            = the staff Firestore doc ID (so Firestore rules can do
 *                       exists(/databases/$(db)/documents/staff/$(request.auth.uid)))
 *   - email           = synthetic, derived from employeeId
 *                       (<employeeId>@staff.solaruniverse.app, lowercased)
 *   - password        = the same plaintext value already in Firestore,
 *                       so the login UX (Employee ID + password) is unchanged
 *                       and staff don't need to learn a new credential.
 *   - custom claims   = { staff: true }
 *
 * Why custom claims (not just relying on Firestore rules' exists() check):
 * Firestore's own security rules can reference Firestore documents
 * same-service with exists()/get() — that works fine. But Cloud Storage
 * rules referencing Firestore is a *cross-service* call
 * (firestore.exists(/databases/(default)/documents/...)), and on this
 * project that consistently returned "Permission denied" even for a
 * hardcoded, known-good path — verified via REST end-to-end tests. Rather
 * than depend on a cross-service mechanism that isn't working reliably
 * here, storage.rules checks request.auth.token.staff / .admin instead,
 * which is the standard, well-supported pattern for this exact case.
 *
 * Firebase Auth does real password hashing/verification — the plaintext
 * value from Firestore is only used once here, server-side, to seed the
 * account.
 *
 * Run: node scripts/provision_staff_auth.js
 * Re-run any time a new staff member is added with employeeId+password, an
 * existing one's password changes in Firestore, or a new admin doc is
 * added — it's idempotent (updates existing accounts rather than erroring).
 */
const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('../serviceAccountKey.json');

initializeApp({ credential: cert(serviceAccount) });
const auth = getAuth();
const db = getFirestore();

const EMAIL_DOMAIN = 'staff.solaruniverse.app';

function syntheticEmail(employeeId) {
  return `${employeeId.toLowerCase()}@${EMAIL_DOMAIN}`;
}

async function provisionStaffOne(doc) {
  const data = doc.data();
  const { employeeId, password, name } = data;
  if (!employeeId || !password) return { skipped: doc.id };

  const uid = doc.id;
  const email = syntheticEmail(employeeId);

  try {
    await auth.updateUser(uid, { email, password, disabled: false });
    console.log(`updated  ${employeeId}  (${name})  uid=${uid}`);
  } catch (err) {
    if (err.code === 'auth/user-not-found') {
      await auth.createUser({ uid, email, password, disabled: false, emailVerified: true });
      console.log(`created  ${employeeId}  (${name})  uid=${uid}`);
    } else {
      throw err;
    }
  }
  await auth.setCustomUserClaims(uid, { staff: true });
  return { done: uid };
}

async function provisionAdminClaim(doc) {
  const uid = doc.id;
  try {
    await auth.getUser(uid);
  } catch (err) {
    if (err.code === 'auth/user-not-found') {
      console.log(`skip admin ${uid} — no matching Firebase Auth account (admins are created via the web console, not this script)`);
      return { skipped: uid };
    }
    throw err;
  }
  await auth.setCustomUserClaims(uid, { admin: true });
  console.log(`admin claim set  uid=${uid}`);
  return { done: uid };
}

async function main() {
  const staffSnap = await db.collection('staff').get();
  console.log(`Scanning ${staffSnap.size} staff docs...\n`);
  let created = 0, skipped = 0;
  for (const doc of staffSnap.docs) {
    const result = await provisionStaffOne(doc);
    if (result.done) created++;
    else skipped++;
  }
  console.log(`\nStaff: ${created} provisioned, ${skipped} skipped (no employeeId/password).`);

  const adminSnap = await db.collection('admins').get();
  console.log(`\nScanning ${adminSnap.size} admin docs...\n`);
  let adminDone = 0, adminSkipped = 0;
  for (const doc of adminSnap.docs) {
    const result = await provisionAdminClaim(doc);
    if (result.done) adminDone++;
    else adminSkipped++;
  }
  console.log(`\nAdmins: ${adminDone} claim(s) set, ${adminSkipped} skipped.`);
}

main().catch((err) => {
  console.error('Provisioning failed:', err);
  process.exit(1);
});

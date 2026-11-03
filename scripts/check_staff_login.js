/**
 * Read-only: for every staff doc with employeeId + password, checks that the
 * matching Firebase Auth account exists (same uid, synthetic email) and that a
 * real email/password sign-in AND a Firestore read of staff/{uid} succeed — the
 * exact path the app's staff login takes. Makes no writes.
 *
 * Run: node scripts/check_staff_login.js
 */
require('dns').setDefaultResultOrder('ipv4first');
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');
const sa = require('./serviceAccountKey.json');

initializeApp({ credential: cert(sa) });
const db = getFirestore();
const auth = getAuth();
const API_KEY = 'AIzaSyD6eoGNiRqgZAMNBpdZ8wAvGF1ng9Oj6yM';
const DOMAIN = 'staff.solaruniverse.app';

async function main() {
  const snap = await db.collection('staff').get();
  console.log(`staff docs: ${snap.size}\n`);
  for (const d of snap.docs) {
    const { employeeId, password, name, role } = d.data();
    if (!employeeId || !password) {
      console.log(`SKIP   ${d.id}  ${name} (${role}) — no employeeId/password`);
      continue;
    }
    const email = `${employeeId.trim().toLowerCase()}@${DOMAIN}`;
    let authState = 'missing';
    try {
      const u = await auth.getUserByEmail(email);
      authState = u.uid === d.id ? 'ok' : `UID MISMATCH (auth ${u.uid} vs doc ${d.id})`;
    } catch (_) {}
    let signIn = 'n/a', read = 'n/a';
    const r = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password, returnSecureToken: true }),
    });
    const j = await r.json();
    if (j.idToken) {
      signIn = 'ok';
      const fr = await fetch(
        `https://firestore.googleapis.com/v1/projects/${sa.project_id}/databases/(default)/documents/staff/${d.id}`,
        { headers: { Authorization: `Bearer ${j.idToken}` } });
      read = fr.ok ? 'ok' : `DENIED ${fr.status}`;
    } else {
      signIn = `FAIL ${j.error && j.error.message}`;
    }
    console.log(`${employeeId}  ${name} (${role})  auth=${authState}  signIn=${signIn}  firestoreRead=${read}`);
  }
}
main().catch((e) => { console.error(e); process.exit(1); });

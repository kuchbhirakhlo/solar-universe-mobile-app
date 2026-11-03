/**
 * Read-only: diagnoses live staff tracking. Prints the `staff_locations`
 * documents, whether the live Firestore rules cover that collection, and — for
 * every staff member — when they last signed in / refreshed their token
 * (Firebase Auth metadata) and whether they marked attendance today, so a
 * "no location documents" report can be matched against real login activity.
 * Makes no writes.
 *
 * Run: node scripts/check_tracking.js
 */
require('dns').setDefaultResultOrder('ipv4first');
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');
const { GoogleAuth } = require('google-auth-library');
const sa = require('./serviceAccountKey.json');

initializeApp({ credential: cert(sa) });
const db = getFirestore();
const auth = getAuth();

(async () => {
  console.log('now (UTC):', new Date().toISOString(), '\n');

  const locs = await db.collection('staff_locations').get();
  console.log(`staff_locations docs: ${locs.size}`);
  locs.forEach((d) => console.log(' ', d.id, JSON.stringify(d.data())));

  const client = await new GoogleAuth({
    credentials: sa,
    scopes: ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/firebase'],
  }).getClient();
  const rel = (await client.request({
    url: `https://firebaserules.googleapis.com/v1/projects/${sa.project_id}/releases/cloud.firestore`,
  })).data;
  const rs = (await client.request({ url: `https://firebaserules.googleapis.com/v1/${rel.rulesetName}` })).data;
  const src = rs.source.files[0].content;
  const i = src.indexOf('staff_locations');
  console.log('\nlive ruleset:', rel.rulesetName, '(updated', rel.updateTime + ')');
  console.log('rules mention staff_locations:', i !== -1);
  if (i !== -1) console.log(src.slice(i - 12, i + 90).replace(/\n/g, ' '));

  const today = new Date().toISOString().slice(0, 10);
  const staff = await db.collection('staff').get();
  console.log(`\nstaff (${staff.size}), attendance date ${today}:`);
  for (const d of staff.docs) {
    const s = d.data();
    let meta = 'no auth account';
    try {
      const u = await auth.getUser(d.id);
      meta = `lastSignIn=${u.metadata.lastSignInTime}  lastRefresh=${u.metadata.lastRefreshTime}`;
    } catch (_) {}
    const att = await db.collection('attendance').doc(`${d.id}_${today}`).get();
    console.log(` ${s.employeeId || '-'}  ${s.name} (${s.role})  ${meta}  attendanceToday=${att.exists ? att.data().status : 'none'}`);
  }
})().catch((e) => { console.error(e); process.exit(1); });

/**
 * Read-only: diagnoses the Engineer "My Service Requests" screen. Lists every
 * `service_requests` doc with the fields that decide whether an engineer sees
 * it (assignedEngineerId/Name, status, createdAt + its type), the engineers in
 * `staff` (id + employeeId), and runs the app's exact query so the real
 * Firestore error (e.g. a missing composite index) is printed. No writes.
 *
 * Run: node scripts/check_service_requests.js
 */
require('dns').setDefaultResultOrder('ipv4first');
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const sa = require('./serviceAccountKey.json');

initializeApp({ credential: cert(sa) });
const db = getFirestore();

(async () => {
  const staff = await db.collection('staff').get();
  const engineers = staff.docs.filter((d) => /engineer/i.test(d.data().role || ''));
  console.log('Engineers:');
  engineers.forEach((d) => console.log(`  ${d.id}  ${d.data().employeeId}  ${d.data().name}`));

  const sr = await db.collection('service_requests').get();
  console.log(`\nservice_requests: ${sr.size}`);
  sr.forEach((d) => {
    const x = d.data();
    console.log(`  ${d.id}  status=${JSON.stringify(x.status)}  assignedEngineerId=${JSON.stringify(x.assignedEngineerId)}` +
      `  assignedEngineerName=${JSON.stringify(x.assignedEngineerName)}  customer=${JSON.stringify(x.customerName)}` +
      `  createdAt=${JSON.stringify(x.createdAt)} (${x.createdAt && x.createdAt.toDate ? 'Timestamp' : typeof x.createdAt})`);
    console.log(`     keys: ${Object.keys(x).sort().join(', ')}`);
  });

  for (const e of engineers) {
    const ids = [...new Set([e.id, e.data().employeeId].filter(Boolean))];
    try {
      const snaps = await Promise.all(
        ids.map((id) => db.collection('service_requests').where('assignedEngineerId', '==', id).get())
      );
      const seen = new Set();
      snaps.forEach((q) => q.forEach((d) => seen.add(d.id)));
      console.log(`\napp query for ${e.data().employeeId} (ids=${ids.join(',')}): OK, ${seen.size} result(s)`);
    } catch (err) {
      console.log(`\napp query for ${e.data().employeeId}: FAILED -> ${err.code} ${String(err.message).slice(0, 400)}`);
    }
  }
})().catch((e) => { console.error(e); process.exit(1); });

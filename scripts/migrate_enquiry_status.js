require('dns').setDefaultResultOrder('ipv4first');
/**
 * One-time fix for enquiries written by older app builds in a shape the admin
 * CRM can't display properly:
 *   - status 'New' (not a CRM stage; the admin <select> silently shows
 *     "Interested", and stage filters miss it)  ->  'Interested'
 *   - status in ALL CAPS ('INTERESTED') or other casing  ->  canonical title-case
 * and, only where missing, seeds `remark` and a `statusHistory` creation entry
 * exactly like the website's addEnquiry (updatedAt = the doc's own createdAt).
 *
 * Only touches documents whose status isn't already a canonical CRM stage;
 * docs already in the new format are never modified. Dry run by default.
 *
 * Run:  node scripts/migrate_enquiry_status.js            (dry run, prints plan)
 *       node scripts/migrate_enquiry_status.js --apply    (writes)
 */
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const sa = require('./serviceAccountKey.json');

initializeApp({ credential: cert(sa) });
const db = getFirestore();
const APPLY = process.argv.includes('--apply');

const STAGES = [
  'Interested', 'Contacted', 'Paper Correction', 'Paper Received', 'Site Visit',
  'Quotation', 'File Submitted in Bank', 'Payment Received', 'Converted', 'Rejected',
];

function canonical(status) {
  if (typeof status !== 'string') return null;
  const key = status.trim().toLowerCase();
  if (key === 'new') return 'Interested';
  return STAGES.find((s) => s.toLowerCase() === key) || null;
}

(async () => {
  const snap = await db.collection('enquiries').get();
  console.log(`Project ${sa.project_id}: ${snap.size} enquiries scanned. Mode: ${APPLY ? 'APPLY' : 'DRY RUN'}\n`);
  let changed = 0;
  for (const doc of snap.docs) {
    const d = doc.data();
    const target = canonical(d.status);
    if (target === null || d.status === target) continue; // unknown value, or already canonical

    const update = { status: target };
    const hasHistory = Array.isArray(d.statusHistory) && d.statusHistory.length > 0;
    const remark = (d.remark && String(d.remark).trim()) ||
      (d.message && String(d.message).trim()) ||
      `Logged by ${d.createdByStaffName || 'Mobile App'}`;
    if (!d.remark) update.remark = remark;
    if (!hasHistory) {
      update.statusHistory = [{
        status: target,
        remark,
        updatedBy: d.createdByStaffName || 'Mobile App',
        updatedAt: typeof d.createdAt === 'string' ? d.createdAt : new Date().toISOString(),
      }];
    }
    changed++;
    console.log(`${doc.id}  ${d.name || ''}  status ${JSON.stringify(d.status)} -> ${JSON.stringify(target)}` +
      `${update.remark ? '  +remark' : ''}${update.statusHistory ? '  +history' : ''}`);
    if (APPLY) await doc.ref.update(update);
  }
  console.log(`\n${changed} document(s) ${APPLY ? 'updated' : 'would be updated'}.`);
  if (!APPLY && changed) console.log('Re-run with --apply to write these changes.');
})().catch((e) => { console.error(e); process.exit(1); });

/**
 * Read-only production sanity check: deployed Firestore/Storage rules,
 * composite indexes, Auth sign-in providers, default Storage bucket, and
 * per-collection doc counts against whatever project serviceAccountKey.json
 * actually points at. Safe to re-run any time — makes no writes.
 *
 * Run: node scripts/sanity_check.js
 */
require('dns').setDefaultResultOrder('ipv4first');
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');
const { GoogleAuth } = require('google-auth-library');
const serviceAccount = require('./serviceAccountKey.json');
const PROJECT_ID = serviceAccount.project_id;

initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();
const auth = getAuth();

async function main() {
  console.log('Project:', PROJECT_ID, '\n');

  // 1. Firestore rules currently deployed
  const gAuth = new GoogleAuth({
    credentials: serviceAccount,
    scopes: ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/firebase'],
  });
  const client = await gAuth.getClient();
  try {
    const rel = await client.request({
      url: `https://firebaserules.googleapis.com/v1/projects/${PROJECT_ID}/releases/cloud.firestore`,
    });
    const rulesetName = rel.data.rulesetName;
    console.log('Deployed Firestore ruleset:', rulesetName || '(none)');
    if (rulesetName) {
      const rs = await client.request({ url: `https://firebaserules.googleapis.com/v1/${rulesetName}` });
      const content = rs.data.source.files[0].content;
      console.log('--- rules (first 500 chars) ---\n' + content.slice(0, 500) + '\n---');
    }
  } catch (e) {
    console.log('Firestore rules check failed:', e.message);
  }

  // 2. Storage rules / bucket existence
  try {
    const sRel = await client.request({
      url: `https://firebaserules.googleapis.com/v1/projects/${PROJECT_ID}/releases/firebase.storage`,
    });
    console.log('\nDeployed Storage ruleset:', sRel.data.rulesetName || '(none)');
  } catch (e) {
    console.log('\nStorage rules check:', e.response ? e.response.data.error.message : e.message);
  }

  // 3. Composite indexes
  try {
    const idx = await client.request({
      url: `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/collectionGroups/-/indexes`,
    });
    const indexes = idx.data.indexes || [];
    console.log(`\nComposite indexes (${indexes.length}):`);
    indexes.forEach(i => console.log(' -', i.name.split('/').pop(), i.state, JSON.stringify(i.fields)));
  } catch (e) {
    console.log('\nIndexes check failed:', e.response ? JSON.stringify(e.response.data) : e.message);
  }

  // 4. Phone auth provider config
  try {
    const cfg = await client.request({
      url: `https://identitytoolkit.googleapis.com/admin/v2/projects/${PROJECT_ID}/config`,
    });
    console.log('\nSign-in config:', JSON.stringify(cfg.data.signIn, null, 2));
  } catch (e) {
    console.log('\nAuth config check failed:', e.response ? JSON.stringify(e.response.data) : e.message);
  }

  // 5. Storage bucket
  try {
    const admin = require('firebase-admin');
    const bucket = admin.storage().bucket(`${PROJECT_ID}.firebasestorage.app`);
    const [exists] = await bucket.exists();
    console.log('\nDefault storage bucket exists:', exists);
  } catch (e) {
    console.log('\nStorage bucket check failed:', e.message);
  }

  // 6. Staff/admin/customers doc counts (sanity on real data)
  for (const col of ['staff', 'admins', 'customers', 'enquiries', 'brands', 'pricing', 'projects', 'faq']) {
    try {
      const snap = await db.collection(col).count().get();
      console.log(`Collection '${col}': ${snap.data().count} docs`);
    } catch (e) {
      console.log(`Collection '${col}': error`, e.message);
    }
  }
}

main().catch(e => { console.error('FATAL', e); process.exit(1); });

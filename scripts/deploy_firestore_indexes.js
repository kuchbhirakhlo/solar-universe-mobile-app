require('dns').setDefaultResultOrder('ipv4first');
/**
 * Creates the composite indexes listed in ../firestore.indexes.json via the
 * Firestore Admin REST API directly using the service account (same
 * REST-API-with-service-account approach as deploy_firestore_rules.js /
 * deploy_storage_rules.js, since the Firebase CLI's cached login is
 * unreliable in this environment).
 *
 * Firestore composite index creation is async — this script fires the
 * create requests and reports each one's initial state; indexes typically
 * finish building within a few minutes for a collection this size. A 409
 * ("already exists") is treated as success, so this is safe to re-run.
 *
 * Run: node scripts/deploy_firestore_indexes.js
 */
const fs = require('fs');
const path = require('path');
const { GoogleAuth } = require('google-auth-library');

const PROJECT_ID = 'solaruniverse-fef74';
const INDEXES_PATH = path.join(__dirname, '..', 'firestore.indexes.json');

async function main() {
  const auth = new GoogleAuth({
    keyFile: path.join(__dirname, '..', 'serviceAccountKey.json'),
    scopes: ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/datastore'],
  });
  const client = await auth.getClient();

  const { indexes } = JSON.parse(fs.readFileSync(INDEXES_PATH, 'utf8'));

  for (const index of indexes) {
    const { collectionGroup, queryScope, fields } = index;
    try {
      await client.request({
        url: `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/collectionGroups/${collectionGroup}/indexes`,
        method: 'POST',
        data: { queryScope, fields },
      });
      console.log(`Creating index: ${collectionGroup} (${fields.map((f) => f.fieldPath).join(', ')})`);
    } catch (err) {
      const status = err.response && err.response.status;
      if (status === 409) {
        console.log(`Already exists: ${collectionGroup} (${fields.map((f) => f.fieldPath).join(', ')})`);
      } else {
        throw err;
      }
    }
  }

  console.log('\nDone. Indexes build asynchronously — check Firebase Console > Firestore > Indexes for build status.');
}

main().catch((err) => {
  console.error('Deploy failed:', err.response ? err.response.data : err);
  process.exit(1);
});

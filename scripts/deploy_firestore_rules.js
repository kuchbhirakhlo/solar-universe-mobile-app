require('dns').setDefaultResultOrder('ipv4first');
/**
 * Deploys firestore.rules via the Firebase Rules REST API directly using
 * the service account (bypasses `firebase deploy`, whose cached user CLI
 * login had expired). Safe to re-run any time rules change.
 */
const fs = require('fs');
const path = require('path');
const { GoogleAuth } = require('google-auth-library');

const PROJECT_ID = 'solaruniverse-fef74';
const RULES_PATH = path.join(__dirname, '..', 'firestore.rules');

async function main() {
  const auth = new GoogleAuth({
    keyFile: path.join(__dirname, '..', 'serviceAccountKey.json'),
    scopes: ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/firebase'],
  });
  const client = await auth.getClient();

  const source = fs.readFileSync(RULES_PATH, 'utf8');

  // 1. Create a new Ruleset with the rules source.
  const createRes = await client.request({
    url: `https://firebaserules.googleapis.com/v1/projects/${PROJECT_ID}/rulesets`,
    method: 'POST',
    data: {
      source: {
        files: [{ name: 'firestore.rules', content: source }],
      },
    },
  });
  const rulesetName = createRes.data.name;
  console.log('Created ruleset:', rulesetName);

  // 2. Release it to cloud.firestore (the live Firestore rules "release" name).
  const releaseName = `projects/${PROJECT_ID}/releases/cloud.firestore`;
  await client.request({
    url: `https://firebaserules.googleapis.com/v1/projects/${PROJECT_ID}/releases/cloud.firestore`,
    method: 'PATCH',
    data: {
      release: { name: releaseName, rulesetName },
    },
  }).catch(async (err) => {
    // Release doesn't exist yet — create it instead.
    if (err.response && err.response.status === 404) {
      await client.request({
        url: `https://firebaserules.googleapis.com/v1/projects/${PROJECT_ID}/releases`,
        method: 'POST',
        data: { release: { name: releaseName, rulesetName } },
      });
    } else {
      throw err;
    }
  });

  console.log('Firestore rules deployed successfully.');
}

main().catch((err) => {
  console.error('Deploy failed:', err.response ? err.response.data : err);
  process.exit(1);
});

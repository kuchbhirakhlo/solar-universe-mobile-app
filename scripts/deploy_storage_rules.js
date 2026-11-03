require('dns').setDefaultResultOrder('ipv4first');
/**
 * Deploys storage.rules via the Firebase Rules REST API directly using the
 * service account (bypasses `firebase deploy`, whose cached user CLI login
 * had expired — see deploy_firestore_rules.js for the same reasoning).
 */
const fs = require('fs');
const path = require('path');
const { GoogleAuth } = require('google-auth-library');

const PROJECT_ID = 'solaruniverse-fef74';
const BUCKET = 'solaruniverse-fef74.firebasestorage.app';
const RULES_PATH = path.join(__dirname, '..', 'storage.rules');

async function main() {
  const auth = new GoogleAuth({
    keyFile: path.join(__dirname, '..', 'serviceAccountKey.json'),
    scopes: ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/firebase'],
  });
  const client = await auth.getClient();

  const source = fs.readFileSync(RULES_PATH, 'utf8');

  const createRes = await client.request({
    url: `https://firebaserules.googleapis.com/v1/projects/${PROJECT_ID}/rulesets`,
    method: 'POST',
    data: {
      source: {
        files: [{ name: 'storage.rules', content: source }],
      },
    },
  });
  const rulesetName = createRes.data.name;
  console.log('Created ruleset:', rulesetName);

  const releaseId = `firebase.storage/${BUCKET}`;
  const releaseName = `projects/${PROJECT_ID}/releases/${releaseId}`;

  // Enabling Storage via the Firebase Console (the "Get Started" flow that
  // provisions the bucket) also auto-creates a default rules release, so in
  // practice PATCH (update) is what's needed, not POST (create) — POST
  // against an existing release returns 403 here, not the 409 you'd expect,
  // so don't rely on that to decide which verb to use. Try PATCH first.
  try {
    await client.request({
      url: `https://firebaserules.googleapis.com/v1/projects/${PROJECT_ID}/releases/${encodeURIComponent(releaseId)}`,
      method: 'PATCH',
      data: { release: { name: releaseName, rulesetName } },
    });
  } catch (err) {
    if (err.response && err.response.status === 404) {
      // No release yet — create one instead.
      await client.request({
        url: `https://firebaserules.googleapis.com/v1/projects/${PROJECT_ID}/releases`,
        method: 'POST',
        data: { name: releaseName, rulesetName },
      });
    } else {
      throw err;
    }
  }

  console.log('Storage rules deployed successfully.');
}

main().catch((err) => {
  console.error('Deploy failed:', err.response ? err.response.data : err);
  process.exit(1);
});

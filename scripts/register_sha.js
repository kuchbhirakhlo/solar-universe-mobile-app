require('dns').setDefaultResultOrder('ipv4first');
/**
 * Registers the local debug keystore's SHA-1/SHA-256 fingerprints against the
 * Android app in Firebase — needed for Phone Auth's Play-Integrity-based
 * silent verification (without this, Android falls back to a reCAPTCHA flow).
 * Safe to re-run (Firebase de-dupes identical fingerprints).
 *
 * Run: node scripts/register_sha.js
 */
const path = require('path');
const { GoogleAuth } = require('google-auth-library');

const PROJECT_ID = 'solaruniverse-fef74';
// The real Android app under fef74 (matches android/app/google-services.json
// and firebase_options.dart's android block) — the old value here,
// 1:1044682246730:android:..., was the ccbdb-era app id and never caught by
// the earlier project-id find/replace since it's a bare numeric id.
const ANDROID_APP_ID = '1:118071509177:android:8150cf5dd733bb8452db68';

const FINGERPRINTS = [
  // Debug keystore (%USERPROFILE%\.android\debug.keystore) — local dev builds.
  { sha: '95F7E024BFA8242DEBDC5DF65C4C601F8E6EB237', type: 'SHA_1' },
  { sha: '8C4F6A4EC39452B594A10FF3EA9190EC62A99A8C85EA467A587B95C2DF4B41E6', type: 'SHA_256' },
  // Release/upload keystore (android/app/upload-keystore.jks, alias
  // solaruniverse-upload) — regenerated 2026-09-21 with the real company
  // identity (the previous keystore here was a leftover Solarwin Technologies
  // file); these fingerprints are the new key's.
  { sha: '9BA4CA76E64D79EFA38C34065272CC87B6D60705', type: 'SHA_1' },
  { sha: 'B669DA1C154A72524C7435EF9DF14CADE41053492DA889A7DDC6F0D6125496FA', type: 'SHA_256' },
];

async function main() {
  const auth = new GoogleAuth({
    keyFile: path.join(__dirname, 'serviceAccountKey.json'),
    scopes: ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/firebase'],
  });
  const client = await auth.getClient();
  const base = `https://firebase.googleapis.com/v1beta1/projects/${PROJECT_ID}/androidApps/${ANDROID_APP_ID}`;

  const existing = await client.request({ url: `${base}/sha` });
  console.log('Existing fingerprints:', JSON.stringify(existing.data));

  for (const fp of FINGERPRINTS) {
    const already = (existing.data.certificates || []).some(
      (c) => c.shaHash.toUpperCase() === fp.sha.toUpperCase()
    );
    if (already) {
      console.log(`Already registered: ${fp.type} ${fp.sha}`);
      continue;
    }
    const res = await client.request({
      url: `${base}/sha`,
      method: 'POST',
      data: { shaHash: fp.sha, certType: fp.type },
    });
    console.log(`Registered ${fp.type}:`, JSON.stringify(res.data));
  }
}

main().catch((err) => {
  console.error('register_sha failed:', err.response ? JSON.stringify(err.response.data) : err);
  process.exit(1);
});

/**
 * One-time setup script: registers Android/iOS/Web apps under the
 * solaruniverse-fef74 Firebase project via the Firebase Management API
 * (using the service account directly — no interactive `flutterfire
 * configure` login available in this environment), then fetches each app's
 * SDK config so firebase_options.dart / google-services.json can be written
 * by hand from real values instead of guessed ones.
 */
const fs = require('fs');
const path = require('path');
const dns = require('dns');
// This machine's default DNS resolution order hangs indefinitely on the
// AAAA/IPv6 lookup for googleapis.com hosts (verified: dns.lookup with the
// default order never returns, but resolves in ~20ms once IPv4 is tried
// first) — force IPv4-first so requests actually complete.
dns.setDefaultResultOrder('ipv4first');
const { GoogleAuth } = require('google-auth-library');

const PROJECT_ID = 'solaruniverse-fef74';
const ANDROID_PACKAGE = 'com.solaruniverse.app';
const IOS_BUNDLE_ID = 'com.solaruniverse.app';

async function pollOperation(client, operationName) {
  // Firebase's app-create endpoints return a long-running Operation, not the
  // app itself — poll until done, matching the documented LRO pattern.
  for (let i = 0; i < 20; i++) {
    const res = await client.request({
      url: `https://firebase.googleapis.com/v1beta1/${operationName}`,
    });
    if (res.data.done) {
      if (res.data.error) throw new Error(JSON.stringify(res.data.error));
      return res.data.response;
    }
    await new Promise((r) => setTimeout(r, 2000));
  }
  throw new Error(`Operation ${operationName} did not complete in time`);
}

async function main() {
  const auth = new GoogleAuth({
    keyFile: path.join(__dirname, 'serviceAccountKey.json'),
    scopes: [
      'https://www.googleapis.com/auth/cloud-platform',
      'https://www.googleapis.com/auth/firebase',
    ],
  });
  const client = await auth.getClient();
  const base = `https://firebase.googleapis.com/v1beta1/projects/${PROJECT_ID}`;

  const result = {};

  // ── Android app ──────────────────────────────────────────────────────
  let androidAppId;
  const existingAndroid = await client.request({ url: `${base}/androidApps` }).catch((e) => {
    console.error('list androidApps failed:', e.response ? e.response.data : e.message);
    return { data: { apps: [] } };
  });
  const foundAndroid = (existingAndroid.data.apps || []).find(
    (a) => a.packageName === ANDROID_PACKAGE
  );
  if (foundAndroid) {
    androidAppId = foundAndroid.appId;
    console.log('Android app already exists:', androidAppId);
  } else {
    const createRes = await client.request({
      url: `${base}/androidApps`,
      method: 'POST',
      data: { packageName: ANDROID_PACKAGE, displayName: 'Solarwin Technologies' },
    });
    const appResource = await pollOperation(client, createRes.data.name);
    console.log('Created androidApp:', JSON.stringify(appResource));
    androidAppId = appResource.appId;
  }

  if (androidAppId) {
    const cfgRes = await client.request({
      url: `${base}/androidApps/${androidAppId}/config`,
    });
    const decoded = Buffer.from(cfgRes.data.configFileContents, 'base64').toString('utf8');
    fs.writeFileSync(path.join(__dirname, 'out_google-services.json'), decoded);
    console.log('Wrote out_google-services.json');
    const sdkRes = await client.request({ url: `${base}/androidApps/${androidAppId}` });
    result.android = { appId: androidAppId, ...sdkRes.data };
  }

  // ── iOS app ───────────────────────────────────────────────────────────
  let iosAppId;
  const existingIos = await client.request({ url: `${base}/iosApps` }).catch((e) => {
    console.error('list iosApps failed:', e.response ? e.response.data : e.message);
    return { data: { apps: [] } };
  });
  const foundIos = (existingIos.data.apps || []).find((a) => a.bundleId === IOS_BUNDLE_ID);
  if (foundIos) {
    iosAppId = foundIos.appId;
    console.log('iOS app already exists:', iosAppId);
  } else {
    const createRes = await client.request({
      url: `${base}/iosApps`,
      method: 'POST',
      data: { bundleId: IOS_BUNDLE_ID, displayName: 'Solarwin Technologies' },
    });
    const appResource = await pollOperation(client, createRes.data.name);
    console.log('Created iosApp:', JSON.stringify(appResource));
    iosAppId = appResource.appId;
  }
  if (iosAppId) {
    const cfgRes = await client.request({ url: `${base}/iosApps/${iosAppId}/config` });
    const decoded = Buffer.from(cfgRes.data.configFileContents, 'base64').toString('utf8');
    fs.writeFileSync(path.join(__dirname, 'out_GoogleService-Info.plist'), decoded);
    console.log('Wrote out_GoogleService-Info.plist');
    const sdkRes = await client.request({ url: `${base}/iosApps/${iosAppId}` });
    result.ios = { appId: iosAppId, ...sdkRes.data };
  }

  // ── Web app (for local `flutter run -d chrome` verification) ────────────
  let webAppId;
  const existingWeb = await client.request({ url: `${base}/webApps` }).catch((e) => {
    console.error('list webApps failed:', e.response ? e.response.data : e.message);
    return { data: { apps: [] } };
  });
  const foundWeb = (existingWeb.data.apps || []).find(
    (a) => a.displayName === 'Solarwin Technologies Web'
  );
  if (foundWeb) {
    webAppId = foundWeb.appId;
    console.log('Web app already exists:', webAppId);
  } else {
    const createRes = await client.request({
      url: `${base}/webApps`,
      method: 'POST',
      data: { displayName: 'Solarwin Technologies Web' },
    });
    const appResource = await pollOperation(client, createRes.data.name);
    console.log('Created webApp:', JSON.stringify(appResource));
    webAppId = appResource.appId;
  }
  if (webAppId) {
    const cfgRes = await client.request({ url: `${base}/webApps/${webAppId}/config` });
    result.web = cfgRes.data;
  }

  fs.writeFileSync(
    path.join(__dirname, 'out_apps.json'),
    JSON.stringify(result, null, 2)
  );
  console.log('\nWrote out_apps.json with full SDK configs.');
}

main().catch((err) => {
  console.error('register_apps failed:', err.response ? JSON.stringify(err.response.data) : err);
  process.exit(1);
});

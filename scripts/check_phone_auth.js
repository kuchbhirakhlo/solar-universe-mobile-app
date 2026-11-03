/**
 * Read-only: dumps the Firebase Auth phone-sign-in settings that commonly
 * break OTP in production (enabled providers, SMS region policy, quota,
 * authorized domains) and whether the Play Integrity API is enabled, plus
 * the SHA fingerprints registered on the Android app. Makes no writes.
 *
 * Run: node scripts/check_phone_auth.js
 */
require('dns').setDefaultResultOrder('ipv4first');
const { GoogleAuth } = require('google-auth-library');
const sa = require('./serviceAccountKey.json');
const P = sa.project_id;
const APP = '1:118071509177:android:8150cf5dd733bb8452db68';

(async () => {
  const c = await new GoogleAuth({
    credentials: sa,
    scopes: ['https://www.googleapis.com/auth/cloud-platform', 'https://www.googleapis.com/auth/firebase'],
  }).getClient();
  const get = async (url) => {
    try { return (await c.request({ url })).data; }
    catch (e) { return { _error: e.response ? e.response.data.error.message : e.message }; }
  };

  const cfg = await get(`https://identitytoolkit.googleapis.com/admin/v2/projects/${P}/config`);
  if (cfg.signIn) delete cfg.signIn.hashConfig;
  console.log('signIn:', JSON.stringify(cfg.signIn));
  console.log('smsRegionConfig:', JSON.stringify(cfg.smsRegionConfig));
  console.log('quota:', JSON.stringify(cfg.quota));
  console.log('authorizedDomains:', JSON.stringify(cfg.authorizedDomains));
  console.log('recaptchaConfig:', JSON.stringify(cfg.recaptchaConfig));
  console.log('error:', cfg._error);

  for (const api of ['playintegrity.googleapis.com', 'identitytoolkit.googleapis.com', 'androidcheck.googleapis.com']) {
    const s = await get(`https://serviceusage.googleapis.com/v1/projects/${P}/services/${api}`);
    console.log(api, s.state || s._error);
  }

  const sha = await get(`https://firebase.googleapis.com/v1beta1/projects/${P}/androidApps/${APP}/sha`);
  (sha.certificates || []).forEach((x) => console.log('SHA', x.certType, x.shaHash));
})();

# Cloning this app for a new company/brand

This documents the exact steps taken to turn a copy-pasted Aahana Enterprises app into this
Solarwin Technologies app — use it as a checklist next time this project (or this one) gets
copy-pasted into a new branded app. The biggest lesson from doing this once: **a copy-paste
leaves far more of the old brand behind than just config files** — real photos, real signature
images, and hardcoded UI text all need auditing, not just `applicationId` and colors.

## 0. Before you start

- Get from the client: their Firebase service account JSON (Project Settings → Service
  Accounts → Generate new private key), their logo file, and their live/reference website URL.
- **Check whether the new Firebase project is actually empty.** Don't assume it is just because
  it's "new" — query every collection with the service account first (see step 5). If it already
  has real data (another admin panel/CRM populating it), your job is to read/write that real
  schema, not seed fake content over it.

## 1. Copy the project folder

Straight folder copy of the source app (e.g. `aahanaenterprises/` → `newbrand/`). Don't clean
`build/`/`.dart_tool/` before or after copying — you'll delete them properly in step 9 anyway,
and having them around initially doesn't hurt.

## 2. Scrape the reference site for real content and colors

Use a real browser (not a plain HTTP fetch — most marketing sites are client-rendered SPAs and
a fetch-and-convert-to-markdown tool will only see the empty shell). Capture:
- Company info: address, phone, email, GSTN/registration numbers, business hours, established
  year, ratings/stats.
- Section copy: solutions/services descriptions, packages/pricing with real numbers, brand/
  partner list, FAQs (note if there are none — don't assume a nav link means content exists).
- **Brand colors from the site's own CSS**, not guessed from the logo. In the browser console:
  ```js
  getComputedStyle(document.documentElement) // walk --color-* custom properties
  ```
  This found the real primary/accent hex codes directly rather than eyeballing them from a
  screenshot.
- Cross-check any registration numbers (GSTN, vendor codes) against the OTHER company's app in
  your workspace if there is one — if they're identical, it's a template artifact on the live
  site, not a coincidence. Flag it, don't silently trust it.

## 3. New Firebase project — register apps without the interactive CLI

`flutterfire configure` needs an interactive browser login, which usually isn't available in an
automated/headless environment. Instead, use the Firebase Management API directly with the
service account:

1. Copy the service account JSON to `<project>/serviceAccountKey.json` and
   `<project>/scripts/serviceAccountKey.json` (both gitignored).
2. `cd scripts && npm install` (needs `firebase-admin` + `google-auth-library`).
3. **If scripts hang with `ERR_SOCKET_CONNECTION_TIMEOUT` on `oauth2.googleapis.com`**: this is
   a Node-on-Windows issue where the default DNS resolution order hangs on a dual A/AAAA
   lookup (`curl` is unaffected — verified via `dns.lookup` timing, ipv4-only resolves in
   ~20ms, default order never returns). Add this as the very first line of every script that
   calls a Google API:
   ```js
   require('dns').setDefaultResultOrder('ipv4first');
   ```
   (Must be the literal first line, not inside/after a `/**` block comment — that silently
   makes it dead code.)
4. Write a `register_apps.js` script that POSTs to
   `https://firebase.googleapis.com/v1beta1/projects/{projectId}/androidApps` (and
   `iosApps`/`webApps`), **polls the returned long-running Operation until `done: true`**
   (the initial POST response is an `Operation`, not the app itself), then GETs
   `.../androidApps/{appId}/config` to fetch the real `google-services.json` /
   `GoogleService-Info.plist` / web SDK config.
   - Register a **web app too**, even if the target is mobile-only — it's the only way to
     `flutter run -d chrome` for interactive verification in an environment with no attached
     Android emulator/device.
5. Copy the fetched config into `android/app/google-services.json` and
   `ios/Runner/GoogleService-Info.plist`.
6. Hand-write `lib/firebase_options.dart` with the real values (don't guess/template it) —
   include a real `web` case, not just android/ios, since Aahana's original only had the two.

## 4. Package / bundle rename

- `android/app/build.gradle.kts`: `namespace` and `applicationId`.
- Move the Kotlin file: `android/app/src/main/kotlin/<old/package/path>/MainActivity.kt` →
  `<new/package/path>/MainActivity.kt`, update its `package` line, remove the now-empty old
  directories.
- `android/app/src/main/AndroidManifest.xml`: `android:label`.
- `ios/Runner.xcodeproj/project.pbxproj`: every `PRODUCT_BUNDLE_IDENTIFIER` line (there are
  several — app + RunnerTests, per build config).
- `ios/Runner/Info.plist`: `CFBundleDisplayName` and `CFBundleName`.
- `pubspec.yaml`: `name:` (no dots allowed — pick something like `newbrand`) and `description`.
- Grep for `package:<old-pubspec-name>` across `lib/` and `test/` — every file with an absolute
  package import needs updating to match the new pubspec `name:`, or the app won't compile.
- Delete `build/` and the stale root-level `.iml` (and any `android/*.iml`) referencing the old
  name — regenerate via `flutter create --platforms=web .` if you need a fresh `.iml`/web folder.
- Fix `.idea/modules.xml` if it references the deleted `.iml` files.

## 5. Firestore — check before you seed

**Query every collection with the service account before writing anything.** A `listCollectionIds`
call plus a sample-doc read per collection takes a minute and prevents two mistakes: seeding fake
data over a real live database, and fabricating a demo staff account when real ones already exist.

If it's genuinely empty: write a `firestore_seed.js` matching the exact field names your Dart
`Model.fromMap()` factories expect (check those first — don't guess field names).

If it's NOT empty (a real admin panel already populates it):
- Read the model files (`PackageModel`, `BrandModel`, etc.) and confirm the real documents'
  field names actually match — they may already line up if it's the same template/vendor.
- **Fetch the currently-deployed rules** before touching `firestore.rules`:
  ```js
  // GET https://firebaserules.googleapis.com/v1/projects/{id}/releases/cloud.firestore
  // then GET the rulesetName it points to, to read releaseName.source.files[].content
  ```
  Compare against what you're about to deploy. Only **add** missing collection coverage — don't
  tighten anything an unknown other consumer might depend on. (Found a real gap this way: a
  `leads` collection with zero rule coverage at all, silently relying on default-deny.)
- Provision Firebase Auth for whatever real staff/admin docs already exist (see next step) —
  don't invent a demo account if real ones are sitting right there.

## 6. Staff auth provisioning (if the app has a staff/CRM portal)

- Update the provisioning script's `EMAIL_DOMAIN` constant (synthetic email suffix) and any
  hardcoded `PROJECT_ID` in the deploy scripts.
- Run it against whatever `staff` docs currently exist — it's idempotent, safe to re-run.
- **Don't invent a demo employee ID** if real staff records already exist in Firestore; wire up
  the real ones instead.

## 7. Storage — gate it, don't rip it out, if billing isn't enabled yet

Cloud Storage needs Blaze billing; Firestore/Auth don't. If the client hasn't enabled billing
yet but the app has document/photo upload features:
- Add one boolean flag (e.g. `AppConfig.storageUploadsEnabled = false`).
- At every screen that currently makes upload mandatory: gate the submit-blocking validation
  behind the flag.
- At every datasource method that calls `FirebaseStorage`: gate the actual network call behind
  the flag (return early instead of attempting a call against a bucket that doesn't exist).
- Write `storage.rules` into the repo anyway (matching the existing pattern) but don't deploy it
  — there's no default bucket to deploy against yet. Document the one-flag flip + one deploy
  command needed once billing is enabled.

## 8. Branding content — the part that's easy to under-scope

Don't stop at strings and colors. Audit for real assets baked in during the original build:

- **Grep for the old company name** (case-insensitive) across the *entire* project, not just
  `lib/` — check `firebase.json`, `.idea/*.xml`, `scripts/package.json` + lockfile, any `.iml`
  files. Config/metadata files get missed by a `lib/`-only search.
- **Grep for the old company name inside Dart string literals specifically** — a previous pass
  can fix `AppStrings.appName` and still leave a screen with a hardcoded
  `TextSpan(text: 'OldBrand ')` rendering the wrong name live on screen. This actually happened
  here (Staff Login header) and wasn't caught until a second explicit "check for old-brand
  stuff" pass.
- **Open every image asset that isn't the obvious logo file and actually look at it.** A
  "signature stamp" or "team photo" asset copied from the old project is not generic clip art —
  it can be a real company's real seal/signature or a real photo of real people at the old
  company's real office (with their real logo on the wall). Both of those happened in this
  clone: `stamp.jpeg` was the old company's actual authorized-signatory seal being printed on
  the new company's quotation PDFs, and `teamimage.jpeg` was a real photo of the old company's
  staff in front of their own signage, being shown as the new company's "Meet Our Team" section.
  **Delete these rather than reuse them** — there's no substitute image to fabricate a real
  company's team/signature with; just remove the section/feature until real assets are supplied.
- Check for orphaned unused assets while you're at it (`grep` the asset filename across `lib/`
  — if it's not referenced anywhere, it's dead weight, delete it rather than leave it sitting in
  the new project).
- Logo shape: if the client's logo is a wide wordmark (not square), the OS app icon needs a
  square glyph cropped out of it. Use Python/Pillow: find the icon graphic's pixel bounding box
  (scan for non-white/non-transparent pixels), crop it, paste centered onto a white square
  canvas. Watch for the wordmark text overlapping the icon graphic's x-range at a different
  y-band (common in "icon | Line1 / Line2" logo lockups) — a purely rectangular crop can't
  always cleanly separate them; a slightly asymmetric crop that avoids bleeding in a letter is
  an acceptable tradeoff over including stray text.
- **After swapping the source icon/splash images, you must actually run the generator commands** —
  updating `pubspec.yaml`'s `image_path` alone does nothing:
  ```
  dart run flutter_launcher_icons
  dart run flutter_native_splash:create
  ```
  This was missed once in this clone — the app compiled and ran fine, but the installed APK
  still showed the old company's real icon and splash screen, because
  `android/app/src/main/res/mipmap-*/ic_launcher.png` and the `drawable-*/splash.png` files are
  physically baked PNGs copied from the old project, not something that regenerates on a normal
  `flutter build`. **Verify by extracting the actual built APK** (`unzip app-debug.apk`) and
  opening the mipmap/drawable PNGs directly — checking the source `assets/images/` file or the
  `pubspec.yaml` config is not enough proof, since neither guarantees the generator actually ran.

## 9. Cleanup

- `flutter clean` — purges `.dart_tool`/`build`/iOS `ephemeral`, which otherwise keep stale
  build-cache references to the old package name around even after every source file is fixed.
- Rewrite `README.md` for the new brand — don't just find-and-replace the old one; the old
  README's dated history entries won't make sense for a different project's timeline.

## 10. Verification — in order of how much it actually proves

1. `flutter analyze` — catches nothing about branding, only catches broken code.
2. `flutter build apk --debug` — proves the package rename compiles end-to-end (namespace,
   manifest, Kotlin package path, `google-services.json` package match).
3. **Extract the built APK and check the actual baked resources** (`aapt dump badging` for
   package/label, `unzip` + open the mipmap/drawable PNGs) — this is what caught the stale-icon
   bug that steps 1–2 completely missed.
4. `flutter run -d chrome` (needs a registered web Firebase app, step 3) if no emulator/device is
   attached, to actually click through the UI and see real rendered text/colors, not just trust
   that the source files look right.
5. Verify Firestore state directly via the service account (REST or a script) after any rules
   deploy or staff provisioning — don't assume a deploy succeeded just because the script exited
   0.

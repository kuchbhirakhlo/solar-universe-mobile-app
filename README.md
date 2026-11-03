# Solar Universe

Mobile app for Solar Win Technologies, a solar EPC company in Lucknow, Uttar Pradesh
(est. 2013). Built with Flutter, forked from the `aahanaenterprises` app in this same
workspace — same architecture (Clean Architecture + `flutter_bloc` + feature-first folders +
`get_it` DI + `go_router`) and the same feature set (public marketing app + a Staff CRM
portal), rebranded and rewired to this company's own Firebase project.

Source of truth for content/branding: https://thesolaruniverse.vercel.app/

- **Package / bundle id**: `com.solaruniverse.app`
- **Firebase project**: `solaruniverse-fef74` — **this is the real, current project.**
  Everywhere below that says `solaruniverse-ccbdb` is describing a **stale, abandoned
  project** from before this app was repointed at `fef74` (confirmed 2026-09-21: the real
  staff/customers/enquiries data lives in `fef74`, verified directly via Firestore REST).
  `scripts/serviceAccountKey.json` and every deploy/provisioning script were still pointed
  at `ccbdb` and have been corrected to `fef74` — but `serviceAccountKey.json` itself is
  gitignored and still holds **ccbdb's** credentials; it must be replaced with a real
  service account key for `fef74` (Firebase Console → `solaruniverse-fef74` → Project
  Settings → Service Accounts → Generate new private key) before any script in `scripts/`
  will work again. Until that happens, **staff Firebase Auth accounts cannot be
  (re-)provisioned** — this was the direct cause of a real staff login failure
  (`SWT-TC-0001` had a correct Firestore doc in `fef74` but no matching Auth account there,
  because `provision_staff_auth.js` had created it in `ccbdb` instead).

If this app itself ever needs to be cloned into a new branded app, see
[CLONING_GUIDE.md](CLONING_GUIDE.md) — a step-by-step checklist written from doing exactly that
to produce this app, including mistakes actually made and how they were caught (a stale app
icon, another company's real photo/signature left in assets, etc.).

## Stack

Same as Aahana's app: `flutter_bloc`, `go_router` (with a `refreshListenable`-driven redirect
guard for the staff portal), Firebase (`firebase_core` + `cloud_firestore` + `firebase_auth`
+ `firebase_storage`), `get_it`, `pdf`/`printing` for quotation PDFs, `file_picker`/
`image_picker` for document/photo uploads.

## Important: this Firebase project already has a live admin panel/CRM

`solaruniverse-ccbdb` is **not** a blank project seeded for this app — it already has a real,
actively-used Firestore database (`admins`, `staff`, `customers`, `enquiries`, `leads`,
`quotations`, `admin_quotations`, `master_items`, `brands`, `pricing`, `projects`, `faq`,
`attendance`), populated by the same kind of admin panel/CRM that Aahana's project has,
apparently from the same vendor/template (staff Employee IDs use an `AAH-` prefix here too —
that's not a leftover Aahana branding bug, it's really how this shared admin-panel template
numbers employees regardless of client). **This app reads/writes that real schema — nothing
here was seeded with fake data.**

- `PackageModel`/`BrandModel`/`FaqModel`/`StaffModel`/`ProjectModel`'s field names already
  matched the real documents exactly (`title`/`capacity`/`price`/`panelType`/`inverter`/
  `warranty`/`features` for pricing, `name`/`logo`/`website` for brands, etc.) — no schema
  translation was needed, unlike Aahana's app which needed a larger rewrite for this.
- **Known data quirks in the live database, not fixed here** (flagging rather than silently
  cleaning up someone else's live/in-progress data):
  - `pricing` has 6 documents for what are really 3 distinct packages (each duplicated once,
    identical content, created in the same second) — will show duplicate cards in the Pricing
    screen.
  - `projects` has 2 identical "Rooftop Solar Installation – Kumar Residence, Kothrud, Pune"
    docs — this doesn't match a Lucknow-based company and looks like un-edited template demo
    data (mirrors the same placeholder project visible on the live marketing site).
  - `brands`' `logo` fields point at generic Unsplash stock photos, not real brand logos.
- **`firestore.rules` had a real gap**: `leads` (the public "full application form" collection)
  had zero rule coverage at all — Firestore denies by default, so the one existing `leads` doc
  must have been written some other way (Admin SDK / server-side). Added a `leads` block
  mirroring the existing `enquiries` pattern (public create, open read/update/delete, since the
  admin panel's Sales portal uses client-side sessions with no Firebase Auth token) and
  redeployed — this is the **only** change made to the live rules; everything else was already
  identical to what's described as "Aahana's current rules" and was left as-is.
  See [[feedback_shared_firestore_rules]]-style caution: don't tighten rules on collections
  another system also depends on without checking its query shapes first — this change only
  **added** coverage, never restricted anything.
- **Staff Firebase Auth accounts provisioned for the 2 real staff docs** that existed at build
  time (`scripts/provision_staff_auth.js`, synthetic email domain `staff.solaruniverse.app`):
  - `AAH-SV-0001` / Shubham Maurya — password as stored in Firestore at provisioning time.
  - `AAH-TC-0001` / rakesh — password as stored in Firestore at provisioning time.
  Re-run this script any time a new staff member is added or a password changes in Firestore —
  it's not automatic (same caveat as Aahana's app).
- **GSTN (`09ALEPY2620D1Z6`) and Vendor Code (`LKO2508133172`)** used in
  `static_content_data.dart` are copied verbatim from the live site's footer — but they are
  **byte-identical to Aahana Enterprises' own numbers** used elsewhere in this same workspace.
  Almost certainly an un-edited template value on the live site rather than Solar Win's real
  registration numbers. Update `static_content_data.dart` once the real numbers are confirmed.
- No CEO/founder name is published anywhere (it's a proprietorship) and no real team-size
  figure exists — `CompanyInfoEntity.ceoName`/`ceoQuote`/`ceoBio`/`teamMembers` use generic,
  non-personal placeholder text. These fields aren't rendered anywhere in the current UI
  (`about_screen.dart`), so this is low-stakes, but worth knowing if that screen is extended.

## Cloud Storage — now confirmed enabled and rules deployed (2026-09-21)

**Correction**: this section previously said Blaze billing wasn't enabled, checking against the
wrong (`ccbdb`) project. Verified directly against the real project, `solaruniverse-fef74`: the
default Storage bucket already exists (Blaze is on), and `storage.rules` — written and ready in
the repo for a while, but never actually deployed since every deploy script pointed at the wrong
project — has now been deployed via `node scripts/deploy_storage_rules.js`. Customer KYC
document uploads (Solar Customers → Register), the enquiry site photo (Create Enquiry), and the
Engineer's installation photos should all work for real now, not just fail gracefully.

`AppConfig.storageUploadsEnabled` still exists but only controls **UI-only** cosmetics
(mandatory-field styling / visible error messages) — see the "File uploads now self-activate"
section further down for why the upload calls themselves were already unconditional before this
fix.

## Running the app

1. `flutter pub get`
2. Firebase is already configured — `lib/firebase_options.dart`,
   `android/app/google-services.json`, and `ios/Runner/GoogleService-Info.plist` were generated
   directly via the Firebase Management API (using `scripts/serviceAccountKey.json`) rather
   than the interactive `flutterfire configure` CLI, since no browser login is available in
   this environment. Re-run `node scripts/register_apps.js` if these ever need regenerating.
3. `flutter run` (or `flutter build apk --debug`). Use the staff portal via More → Staff Login
   with `AAH-TC-0001` (or `AAH-SV-0001`) + the password stored in that staff doc.

`serviceAccountKey.json` (project root and `scripts/`) is gitignored — needed only by the
one-off scripts in `scripts/`, not by the app itself.

### A note on this machine's Node networking

Node's default DNS resolution order hangs indefinitely on this machine when a lookup returns
both an A and AAAA record for googleapis.com hosts (curl is unaffected — this is Node-specific,
verified via `dns.lookup` timing). Every script in `scripts/` starts with:
```js
require('dns').setDefaultResultOrder('ipv4first');
```
If you add a new script that talks to a Google API, include this line first or it will hang
with a misleading `ERR_SOCKET_CONNECTION_TIMEOUT`.

### `scripts/` — one-off admin scripts (Node, separate `package.json`)

- `register_apps.js` — registers Android/iOS/Web apps under the Firebase project via the
  Management API and writes their SDK configs to `out_*` files. Only needs re-running if the
  Firebase apps are ever deleted/recreated.
- `provision_staff_auth.js` — creates/updates the Firebase Auth account for each `staff` doc
  with `employeeId`+`password` set, and sets `{staff:true}`/`{admin:true}` custom claims.
  Re-run after adding staff or changing a password in Firestore.
- `deploy_firestore_rules.js` — deploys `firestore.rules` via the Firebase Rules REST API
  directly using the service account.
- `deploy_storage_rules.js` — same, for `storage.rules` (only useful once Blaze billing is on
  and a default bucket exists).
- `register_sha.js` — registers a debug keystore's SHA-1/SHA-256 fingerprints against the
  Android app (needed for Phone Auth's Play-Integrity-based silent verification). Re-run for
  any other keystore (e.g. a real release key before shipping) that needs to sign in customers.
- `deploy_firestore_indexes.js` — attempts to create composite indexes from
  `firestore.indexes.json` via the Firestore Admin REST API. **Currently fails with 403** — the
  service account lacks `datastore.indexes.create` (confirmed: it can't even read the project's
  IAM policy to check, let alone grant itself the role). See the section below for the actual
  fix.

### ⚠️ Missing Firestore composite indexes — breaks 5 real screens right now

`enquiries`/`customers`/`quotations`/`service_requests` (×2 query shapes) are all queried with a
`.where(X, isEqualTo: ...).orderBy('createdAt', descending: true)` shape, which Firestore
requires a composite index for. **None of the 5 exist yet** — confirmed by actually running each
query via the REST API and getting back `FAILED_PRECONDITION: The query requires an index` for
all of them, not just assumed. This means, right now, on the live app:
- Staff **Enquiries** list — broken (`createdByStaffId` + `createdAt`)
- **Solar Customers** list — broken (`createdByStaffId` + `createdAt`)
- **Quick Quotation** history — broken (`createdByStaffId` + `createdAt`)
- Customer **Service Requests** dashboard — broken (`customerId` + `createdAt`)
- Engineer **My Service Requests** list — broken (`assignedEngineerId` + `createdAt`)

The first 3 are a **pre-existing bug**, not something either service-requests feature
introduced — they were already broken before this session touched anything;
`deploy_firestore_indexes.js` was written expecting to fix them but has never successfully run
due to the permission gap above.

**Fix**: click each link below (each opens the Firebase Console pre-filled with the exact index
to create — no manual field entry needed) and click "Create Index". Each takes a few minutes to
build after clicking.
- [enquiries: createdByStaffId + createdAt](https://console.firebase.google.com/v1/r/project/solaruniverse-ccbdb/firestore/indexes?create_composite=ClRwcm9qZWN0cy9zb2xhcndpbnRlY2gtY2NiZGIvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2VucXVpcmllcy9pbmRleGVzL18QARoUChBjcmVhdGVkQnlTdGFmZklkEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg)
- [customers: createdByStaffId + createdAt](https://console.firebase.google.com/v1/r/project/solaruniverse-ccbdb/firestore/indexes?create_composite=ClRwcm9qZWN0cy9zb2xhcndpbnRlY2gtY2NiZGIvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2N1c3RvbWVycy9pbmRleGVzL18QARoUChBjcmVhdGVkQnlTdGFmZklkEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg)
- [quotations: createdByStaffId + createdAt](https://console.firebase.google.com/v1/r/project/solaruniverse-ccbdb/firestore/indexes?create_composite=ClVwcm9qZWN0cy9zb2xhcndpbnRlY2gtY2NiZGIvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3F1b3RhdGlvbnMvaW5kZXhlcy9fEAEaFAoQY3JlYXRlZEJ5U3RhZmZJZBABGg0KCWNyZWF0ZWRBdBACGgwKCF9fbmFtZV9fEAI)
- [service_requests: customerId + createdAt](https://console.firebase.google.com/v1/r/project/solaruniverse-ccbdb/firestore/indexes?create_composite=Cltwcm9qZWN0cy9zb2xhcndpbnRlY2gtY2NiZGIvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3NlcnZpY2VfcmVxdWVzdHMvaW5kZXhlcy9fEAEaDgoKY3VzdG9tZXJJZBABGg0KCWNyZWF0ZWRBdBACGgwKCF9fbmFtZV9fEAI)
- [service_requests: assignedEngineerId + createdAt](https://console.firebase.google.com/v1/r/project/solaruniverse-ccbdb/firestore/indexes?create_composite=Cltwcm9qZWN0cy9zb2xhcndpbnRlY2gtY2NiZGIvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3NlcnZpY2VfcmVxdWVzdHMvaW5kZXhlcy9fEAEaFgoSYXNzaWduZWRFbmdpbmVlcklkEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg)

Alternatively, grant the service account the `Cloud Datastore Index Admin` IAM role, then
`cd scripts && node deploy_firestore_indexes.js` creates/keeps all 5 in sync from
`firestore.indexes.json` going forward.

## Customer self-service portal (phone/OTP login)

Reachable via the new "My Account" icon in `AppTopBar` (next to Staff Login/Call), alongside
the existing public/staff areas. Flow: mobile number → Firebase Phone Auth OTP → look up
`customers` by `mobile` → existing profile goes straight to a dashboard (profile card + service
request history + "New Request"), no profile yet goes to a one-time "Create Solar Customer
Profile" form first. Every request this app creates always starts at `status: 'Open'` —
status/engineer/cost are admin-only fields, never written or edited from here.

- **Phone sign-in provider enabled** on `solaruniverse-ccbdb`, with a **test number for
  verification without real SMS**: `9999999999` → OTP `123456` (configured server-side, works
  in any environment, including this one with no physical device attached). Not a real customer
  — safe to use repeatedly for testing.
- **Debug keystore SHA-1/SHA-256 registered** (`scripts/register_sha.js`) for Play-Integrity
  silent verification on Android. Register a release keystore's fingerprints too before
  shipping a release build, or phone auth falls back to a clunkier reCAPTCHA flow for release
  users.
- **Known limitation, not fixed**: customer auth and staff auth both use the same
  `FirebaseAuth.instance` — only one can be signed in at a time per app install. In realistic
  usage (a customer's own phone vs. a staff member's own phone, used separately) this isn't
  expected to matter, but the same physical device can't hold a signed-in staff session and a
  signed-in customer session simultaneously. A real fix would need a second Firebase App
  instance, which wasn't in scope for this feature.
- `ServiceRequestOptions.types` (`lib/features/customer_service_requests/domain/entities/
  service_request_options.dart`) is a **placeholder list** (Maintenance/Repair/Installation/
  Inspection/Other) — the admin panel's real Create Service Request dropdown was only glimpsed
  with "Maintenance" selected, not the full option list. Update that one file once confirmed.
- **iOS not set up for phone auth** — this session only built/verified the Android path (no
  Mac/iOS toolchain here). iOS Phone Auth typically needs APNs configured (for silent push
  verification) or, as a fallback, the `GoogleService-Info.plist` `REVERSED_CLIENT_ID`
  registered as a URL scheme in `Info.plist` for the reCAPTCHA-flow callback. Neither is done —
  do this before testing the customer portal on iOS.
- Session restore is wired properly at splash (`splash_screen.dart` calls
  `GetCurrentCustomerUseCase` before routing) — unlike `StaffSession`'s equivalent
  `RestoreStaffSessionEvent`, which is defined but **never actually dispatched anywhere** (a
  known dead-code gap in the staff auth flow, left as-is since it's out of scope for this
  feature, but don't copy that pattern elsewhere).

## Quotation PDF — recolored to match the real web-generated PDF, new term

`QuotationPdfGenerator` (`lib/features/staff_quotations/data/pdf/quotation_pdf_generator.dart`)
still had `_navy`/`_green`/`_greenLight` hardcoded from the original Aahana-derived template —
never touched during the Solarwin rebrand. The user shared a screenshot of the actual
web-generated "Estimate to Customer" PDF, which corrected two wrong assumptions from an earlier
pass of this file (reverted):

- **The items table lists every component**, same as before (Solar Panels, Inverter, Mounting
  Structure, DC/AC Wire, Earthing, Lightning Arrestor, ACDB/DCDB, Installation) — "shows only the
  selected panel + inverter brand" turned out to mean a **new, separate** "Selected Equipment
  Brands" callout below the table (`_selectedBrands()`), not a filter on the table itself. Brand
  names are derived from the existing item specs (`"$brand · $type · ..."`, split on `' · '`) —
  no new data field, and no fabricated per-brand logo images (the reference PDF's own attempt to
  show a panel product photo renders as a broken-image icon there — text-only chips are more
  robust).
- **The "light, colorful" look is a 3-color badge system**, not just navy+orange: pink/red for
  Estimate No, blue for Date/Validity, green for System/Capacity/Scheme — matched exactly from
  the reference screenshot (`_metaBadge()`), replacing the plain 2-column text list this file
  used before. Customer name now sits in its own pink-tinted bordered banner ("ESTIMATE TO
  CUSTOMER" + name) instead of plain centered text. The Important Notice box is amber-tinted
  (was a bare left-border before).
- **New first term**: "Adjustable but not refundable Registration Fee." — the other 4 existing
  terms shifted from 1-4 to 2-5, text unchanged. Confirmed present in the reference PDF too.
- **Real bug caught by actually generating a PDF, not just compiling**: combining `borderRadius`
  with a directional `Border` (e.g. `Border(left: ...)`) throws at render time in the `pdf`
  package ("A borderRadius can only be given for a uniform Border") — `flutter analyze`/
  `flutter build` both stay green through this, it only surfaces when the PDF is actually
  generated. Verify PDF layout changes in this file by generating a real sample via a `flutter
  test` calling `QuotationPdfGenerator.generate()` directly and reading the bytes back — not
  compilation success — same lesson as this file's earlier stamp-image/₹-glyph fixes.
- **Flagging, not copying**: the reference PDF's own office address/phone
  ("410 BCC Shakti ... Chinhat, Lucknow", "+91 96962 06453, +91 91700 55811") are **Aahana
  Enterprises' real address and phone numbers**, not Solarwin's — the web admin panel's PDF
  template was evidently rebranded the same incomplete way this app's own assets once were (logo
  and email updated, address/phone left over). This app's PDF keeps Solarwin's real office info
  (`Kusum Deep Complex...`, `+91 98390 97080`) rather than copying the website's error — flag
  this to whoever maintains the web admin panel's PDF template.
- **Out of scope**: the admin web panel's own PDF-generation code is a separate, inaccessible
  codebase — only this mobile app's generator was updated; the two will only look identical to
  the extent this file's redesign matches what's actually deployed there.

**Second real bug, caught the same way (user sent the actual generated PDF, not just a
screenshot)**: `generate()` used `pw.Page` — a **fixed single page**. Content taller than one A4
page silently **clips at the bottom with no error or warning**; `flutter analyze`/`flutter
build` both stay green through this. The new colored badges/selected-brands section made this
file's total content taller than one page, so **Terms 4-5 and the entire "Authorised Signatory"
block were being cut off outright** — not a missing-content bug, a pagination bug. Fixed by
switching to `pw.MultiPage`, which paginates automatically (now correctly spans 2 pages, matching
the real reference PDF's own page break). **Any future layout change to this file needs its
generated output actually inspected end-to-end (both/all pages), not just page 1** — a change
that fits on page 1 can still silently break what's supposed to appear after it.

Also added the reference PDF's closing tagline ("Thank you for choosing Solarwin Technologies —
a 100% Solar Company.") to `_thankYouBanner()`, using "Solarwin" (one word, this app's actual
brand spelling everywhere else) rather than the reference's own "Solar Win" (two words) —
an inconsistency on the web template's side, not deliberately mirrored.

**Still intentionally absent**: the reference PDF has a real handwritten signature scribble
image over "Authorised Signatory" — this app prints a blank line there, same policy as before
(no real signature/stamp asset has ever been supplied for Solarwin; see the stamp.jpeg removal
in `CLONING_GUIDE.md`/earlier README history). If "missing signature" comes up again, it means
this — not a bug, a placeholder waiting on a real asset.

## Engineer role — restricted service-request portal + photo upload

`staff` now has a real "Engineer" role (`SWT-EN-0001`/`SWT-EN-0002`, e.g. Aviral Shukla) with no
mobile experience before this — they'd land on the full Sales dashboard
(Enquiries/Quotations/Customers), none of which is their job. New `StaffEntity.isEngineer`
getter (mirrors the existing `isFieldSales`) drives a router redirect
(`app_router.dart`): any Sales-only route redirects an Engineer to `/staff/service-requests`
instead — a self-contained screen (AppBar + Logout, no bottom nav, mirrors
`CustomerDashboardScreen`'s same simplification), not nested in the Sales `StaffShell`.

New `lib/features/staff_service_requests/` feature (reuses `ServiceRequestEntity`/
`ServiceRequestModel` from `customer_service_requests` — same collection, different query/write
scope):
- **List** (`staff_service_requests_screen.dart`): requests where `assignedEngineerId` equals
  the signed-in engineer's staff id.
- **Detail** (`service_request_detail_screen.dart`): status (Open/In Progress/Completed/
  Cancelled) + remark, both editable and saved via `update()` — **confirmed with the user this
  is allowed**, not just admin-managed like the customer side. Plus multi-photo upload
  (`PhotoUploadField(allowMultiple: true, ...)`, mirrors the Solar Customers eager-upload
  pattern) appending to a **new** `installationPhotos: [url, ...]` field on the doc — additive,
  doesn't collide with anything the admin panel reads/writes.
- **Gated behind `AppConfig.storageUploadsEnabled`** (still `false` — same Storage/Blaze
  blocker as everywhere else in this app) — photos can be picked but won't actually upload
  until Storage is enabled; the detail screen shows an inline note explaining this.
- Both write paths (status/remark `update()`, and the `installationPhotos` `arrayUnion`) were
  verified against a real (test) `service_requests` doc via the service account, then reverted
  to that doc's original values — not just assumed to work from reading the code.

## Android toolchain

Pinned to AGP 8.9.1 / Gradle 8.11.1 / Kotlin 2.1.0 — same reasoning as Aahana's app (`file_picker`
doesn't self-apply the Kotlin Gradle plugin under AGP 9+, and this Flutter SDK version doesn't
implicitly handle that). See Aahana's own README/memory if this needs revisiting.

## App icon

`assets/images/SolarwinLogo.png` is the real wordmark logo — wide (1237×370), not square, so
it can't drive the OS app icon directly. `assets/images/launch_icon.png` /
`launch_icon_adaptive.png` are the sun/globe/bulb/panel glyph cropped out of it via a one-off
Python/Pillow script, padded onto white square canvases (main icon and a smaller
Android-adaptive-safe-zone version). The crop is asymmetric on the right side (the source
logo's icon graphic and the "Technologies" wordmark overlap in x-range at different heights,
so a clean symmetric crop wasn't possible without either clipping the rightmost sun ray or
bleeding in part of a letter) — a minor cosmetic compromise, not a bug.

## Quotation PDF authorised signature

`assets/images/solarwinsign.png` (a real signature the user supplied) is now embedded in
`QuotationPdfGenerator`'s footer, above "Authorised Signatory" — see `_footer()`. Note: any
newly added asset file needs `flutter clean && flutter pub get` before `flutter test`/`flutter
run` will find it if the asset manifest was cached from before the file existed (`Unable to
load asset` even though the path is correct and the directory is already declared in
`pubspec.yaml` — happened here, fixed by `flutter clean`).

## Release signing — real upload keystore provisioned

The release build was signing with the **debug** keystore (`TODO: Add your own signing config`
left in place from project creation) — fixed:

- `android/app/upload-keystore.jks` — the real release/upload keystore (RSA 2048, 10000-day
  validity, alias `solaruniverse-upload`). **Gitignored, never committed.**
- `android/key.properties` — the passwords + alias `build.gradle.kts` reads at build time.
  **Gitignored, never committed.** If this file is missing (e.g. a fresh checkout that hasn't
  been given the keystore yet), the release build automatically falls back to the debug key
  rather than failing outright — don't rely on that fallback for a real release build.
- **The keystore password was generated once, shown to the user in chat, and is not retained
  anywhere else by this tooling — back it up immediately (password manager, secure note) if you
  haven't already.** Losing both the keystore file and its password permanently blocks future
  updates to this app under the same Play Store listing (Google's Play App Signing mitigates
  losing the file itself once you're enrolled, but not the password needed to sign each upload
  before Play re-signs it).
- Registered the release keystore's SHA-1/SHA-256 with Firebase (`scripts/register_sha.js` —
  now registers both debug and release fingerprints) so Phone Auth's Play-Integrity
  verification works on real release builds, not just local debug ones.
- Verified the fix for real: built a release APK and checked its signing certificate with
  `apksigner verify --print-certs` — confirmed `CN=Solarwin Technologies...`, a completely
  different certificate from the debug build's `CN=Android Debug`, not just "the build
  succeeded."

## Production sanity check

**Re-run 2026-09-21 against the real project** (`solaruniverse-fef74` — see the correction note
at the top of this README; every finding below is against `fef74`, not the old `ccbdb`
assumptions this table used to state). Re-runnable any time via `node scripts/sanity_check.js`
(read-only, makes no writes).

| Area | Status |
|---|---|
| Staff login | ✅ Fixed this session — `provision_staff_auth.js` had been creating Auth accounts in the wrong (`ccbdb`) project; re-ran against `fef74` with a corrected service account key, verified end-to-end with a real sign-in request |
| Firestore composite indexes | ⚠️ Only 2 of 5 exist (`enquiries`, `customers`) — confirmed live via the Indexes API. `quotations` and both `service_requests` indexes are still missing. `deploy_firestore_indexes.js` fails with `PERMISSION_DENIED` (service account lacks `datastore.indexes.create`) — grant it the **Cloud Datastore Index Admin** IAM role on `solaruniverse-fef74`, then re-run that script, or create the 3 missing indexes by hand in the Firebase Console's Indexes tab using the field paths in `firestore.indexes.json` |
| Firebase Storage | ✅ **Enabled** — default bucket exists on `fef74` (contradicts this file's older note that Blaze wasn't enabled; that was written against the wrong project). Storage rules were **not deployed** at all until this session — deployed just now via `deploy_storage_rules.js` |
| Firestore rules | ✅ Real rules are deployed on `fef74` (public read on marketing collections, authenticated write) — not independently re-audited field-by-field this session |
| Firebase Phone Auth | ✅ Enabled on `fef74` |
| Release signing | ⚠️ **Real** upload keystore exists (`android/app/upload-keystore.jks` + `key.properties`, not the debug key) — but its certificate identity is `CN=Solarwin Technologies` (copied from the earlier clone this app was based on). Cosmetic, not a security issue (Play App Signing re-signs with Google's own key for actual distribution) — **but check first whether this keystore has already been used for a Play Console upload** before regenerating it; if it has, regenerating breaks the upload-key relationship, if it hasn't, regenerating with the correct company name is one `keytool -genkey` away |
| Test OTP number (`9999999999`/`123456`) | ⚠️ Not re-verified this session (API call for it errored) — assume still configured server-side unless checked; low risk, but remove before a public launch if that matters |
| Privacy Policy | ❌ **Required by Play Console, not yet created** — this app collects phone numbers, names, addresses, and photos; see `play_store_assets/store_listing.md` for what the policy needs to cover |
| No `print`/`debugPrint` leaking secrets | ✅ Re-checked — no plaintext password logging found |
| AndroidManifest permissions | ✅ Minimal, nothing excessive |

## Play Store listing assets

Regenerated 2026-09-21 in `play_store_assets/` with the real branding (the previous versions of
all three files here were leftover "Solarwin Technologies" content from the earlier clone and
did not describe this app):
- `icon-512.png` — 512×512 app icon, resized from the real launcher icon (the cropped sun/arc
  glyph, not the old lightbulb-and-globe mark)
- `feature-graphic-1024x500.png` — a new promotional banner (forest-green gradient, the real
  logo, the actual hero headline and service-area copy)
- `store_listing.md` — title/short/full description text (all under Play Console's character
  limits, verified), rewritten with real facts (15+ years, 5,000+ kW, UP/Bihar/Jharkhand, real
  contact details) instead of Solarwin's old copy, plus guidance on screenshots (need a real
  device — not generated here), category, and the required Privacy Policy / Data safety section
  content

## File uploads now self-activate once Blaze billing is enabled — no new release needed

Previously, `AppConfig.storageUploadsEnabled = false` gated the upload *attempt* itself in all
3 datasources — meaning even after the admin enables Blaze billing, uploads would stay broken
until someone flipped the flag to `true` and shipped a new Play Store release. Changed so the
real `FirebaseStorage` call is **always attempted**:

- `StaffCustomersDataSourceImpl.uploadDocument()` / `StaffServiceRequestsDataSourceImpl
  .uploadInstallationPhoto()` — standalone calls, already safe to let fail: the repository's
  existing `try/catch` turns a Storage failure into `Left(ServerFailure(...))` for just that one
  call, without touching the separate `createCustomer()`/`updateStatusAndRemark()` writes.
- `StaffEnquiriesDataSourceImpl.createEnquiry()` — **needed an actual code change, not just
  removing the flag check**: the site-photo upload happens *inline*, before the enquiry
  Firestore write, in the same method. Without its own try/catch, an uncaught Storage failure
  here would have aborted the entire enquiry creation (losing the lead), not just the photo.
  Fixed by wrapping just the upload attempt in a local `try/catch` — any failure (Blaze off,
  network issue, anything) now just means no photo attached, the enquiry itself still always
  saves.

Net effect: the **moment Blaze billing is turned on**, all 3 upload paths start succeeding with
**zero code changes and no second Play Store release** — this app can already be live before
that happens. `AppConfig.storageUploadsEnabled` still exists, but now only controls UI-only
behavior (whether document/photo fields show as mandatory and whether a failed-upload error is
displayed) — see its updated doc comment in `lib/core/constants/app_config.dart`.

## Release AAB built for Play Store

Built and verified: `flutter build appbundle --release` →
`build/app/outputs/bundle/release/app-release.aab`, signed with the real upload keystore (see
the release-signing section above) — confirmed via `jarsigner -verify -certs`
(`CN=Solarwin Technologies...`, not a debug/self-signed-by-Flutter cert). The "invalid
certificate chain" / "self-signed" / "no timestamp" warnings `jarsigner` prints are normal and
expected for an Android upload key — Play App Signing re-signs the app with Google's own key
for actual distribution; this isn't a problem to fix.

**Before actually publishing this AAB**, the still-open items from the production sanity
section above still apply — most importantly the **Privacy Policy URL** (Play Console won't
accept a submission without one) and the still-pending `quotations` Firestore index.

## Production login troubleshooting (added 2026-10-06)

- **Staff login fails with "Invalid Employee ID or password"** even though the staff member
  exists in the admin panel → the Firebase Auth account doesn't exist yet. The admin panel only
  writes the Firestore `staff` doc; the app signs in through Firebase Auth. Run
  `node scripts/provision_staff_auth.js` after adding staff or changing a password, then
  `node scripts/check_staff_login.js` (read-only) to confirm every staff doc has a matching Auth
  account and that sign-in + the Firestore read both succeed. (Caused the real client complaint
  on 2026-10-06: `TSU-SM-0001` and `TSU-EN-0001` had no Auth accounts.)
- **Phone OTP fails only on Play-installed builds** → Play App Signing re-signs the app, so
  Firebase needs the **Play signing key's SHA-1 *and* SHA-256** (Play Console → Test and release
  → App integrity → App signing). `node scripts/check_phone_auth.js` lists what's registered;
  `scripts/register_sha.js` adds fingerprints. The Play Integrity API must also be enabled for the
  Google Cloud project behind `solaruniverse-fef74`, and SMS beyond the free quota needs Blaze.
- The OTP screens now show the raw Firebase error code in the message (e.g. `(app-not-authorized)`)
  instead of a generic "Something went wrong", so production failures can be diagnosed from a screenshot.

## Staff enquiry status updates (added 2026-10-11)

Staff can tap an enquiry (Staff → Enquiries) to change its stage, exactly like the CRM's sales
portal: stage dropdown (the 9 sales stages — `Converted` is admin-only), a **required** remark, and
a history timeline. The write mirrors `updateEnquiryStatus` in the website's `db.ts`:
`status`, `remark`, and `statusHistory: arrayUnion({status, remark, updatedBy: <staff name>,
updatedAt: <ISO string>})`; assignment fields are never touched. Stage strings are the CRM's
title-case values (`Interested`, `Paper Received`…); the app previously wrote ALL-CAPS, which the
CRM's chips/counters didn't match — reads are case-insensitive (`EnquiryStages.normalize`) so old
docs still display correctly. Code: `lib/features/staff_enquiries/` (`enquiry_stages.dart`,
`enquiry_detail_screen.dart`, `updateEnquiryStatus` in the datasource/repository/bloc).

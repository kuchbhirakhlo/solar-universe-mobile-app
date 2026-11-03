/// Feature flags that don't fit the CRM's real Firestore schema and aren't
/// user-facing strings — kept separate from [AppStrings].
class AppConfig {
  AppConfig._();

  /// Cloud Storage isn't enabled on this Firebase project yet (needs Blaze
  /// billing, enabled by the admin — timing outside this app's control).
  ///
  /// This flag no longer gates whether an upload is *attempted* — every
  /// datasource now always tries the real `FirebaseStorage` call and
  /// tolerates failure gracefully (customer/enquiry/service-request records
  /// still save correctly either way). That means uploads start working
  /// automatically the moment Blaze billing is turned on, with **no new app
  /// release required** — this app could already be live on the Play Store
  /// when that happens.
  ///
  /// This flag only controls **UI-only** behavior: whether document/photo
  /// fields are shown as mandatory and whether a failed-upload error message
  /// is surfaced. Flip to `true` (and ship a new release) once you want
  /// staff to see documents as required again and get a visible error if an
  /// upload genuinely fails — purely cosmetic, not required for uploads to
  /// function.
  static const bool storageUploadsEnabled = false;
}

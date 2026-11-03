class AppStrings {
  AppStrings._();

  // ─── App ────────────────────────────────────────────────────────────────────
  static const String appName = 'Solar Universe';
  static const String appTagline = 'Powering Homes & Businesses with Smarter Solar Energy';

  // ─── Contact ──────────────────────────────────────────────────────────────────
  // Real numbers/email scraped from https://thesolaruniverse.vercel.app/'s own
  // header/footer — the previous values here were leftover from a different
  // company's app copy-pasted during an earlier clone.
  static const String primaryContactNumber = '+917607237555';
  static const String secondaryContactNumber = '+919999158697';
  static const String primaryContactDisplay = '+91 76072 37555';
  static const String contactEmail = 'asarvindshl1@gmail.com';

  // ─── Common / Shared ─────────────────────────────────────────────────────────
  static const String continueLabel = 'Continue';
  static const String cancel = 'Cancel';
  static const String retry = 'Retry';
  static const String noData = 'No data available';
  static const String loading = 'Loading...';

  // ─── Enquiry Form ─────────────────────────────────────────────────────────────
  static const String enquiryOfferBadge = 'FREE SITE SURVEY OFFER';
  static const String enquiryTitle = 'Get Free Solar Quote';
  static const String enquirySubtitle =
      'Submit this brief questionnaire. Our specialists will survey your site '
      'roof details and prepare a custom layout.';
  static const String enquirySubmitLabel = 'REGISTER FOR FREE SITE SURVEY';
  static const String enquirySuccessMessage =
      'Thank you! Our team will contact you shortly.';
  static const String contactSubmitLabel = 'SEND DIRECT MESSAGE';

  // ─── Error / Validation Messages ─────────────────────────────────────────────
  static const String errorNetwork = 'No internet connection';
  static const String errorUnknown = 'Something went wrong. Please try again.';
  static const String errorNameRequired = 'Name is required';
  static const String errorNameTooShort = 'Name must be at least 3 characters';
  static const String errorMobileRequired = 'Mobile number is required';
  static const String errorMobileInvalid = 'Enter a valid 10-digit mobile number';
  static const String errorCityRequired = 'City is required';
  static const String errorMessageRequired = 'This field is required';
  static const String errorOffline =
      'You appear to be offline. Please check your connection and try again.';

  // ─── Firestore Collection Keys (real admin-managed schema) ───────────────────
  // brands / pricing / projects / faq / enquiries / staff / admins / customers /
  // quotations / attendance are referenced as literal strings at each call site
  // (see content_datasource.dart, enquiry_datasource.dart, staff_auth_datasource.dart,
  // and the staff feature's datasources) to keep them next to their exact field
  // mappings — no shared constants here to avoid drift between two sources of truth.

  // ─── Staff Auth ───────────────────────────────────────────────────────────────
  // Synthetic email domain used to sign staff into Firebase Auth via
  // Employee ID + password (see scripts/provision_staff_auth.js for how the
  // matching Auth accounts are provisioned).
  static const String staffAuthEmailDomain = 'staff.solaruniverse.app';

  // ─── Font Family ──────────────────────────────────────────────────────────────
  static const String fontFamily = 'REM';
}

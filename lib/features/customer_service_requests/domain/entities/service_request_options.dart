/// Service Type dropdown options for a new request.
///
/// PLACEHOLDER — the admin panel's Create Service Request form has a
/// dropdown that was only glimpsed with "Maintenance" selected; the full
/// option list wasn't available to confirm against. Update this one list
/// once the real admin dropdown values are confirmed — nothing else needs
/// to change (this is the only place these strings are defined).
class ServiceRequestOptions {
  ServiceRequestOptions._();

  static const List<String> types = [
    'Maintenance',
    'Repair',
    'Installation',
    'Inspection',
    'Other',
  ];

  static const String defaultType = 'Maintenance';

  /// Every request created from this app starts here — status changes are
  /// admin-only (managed from the web panel), never editable from the app.
  static const String initialStatus = 'Open';
}

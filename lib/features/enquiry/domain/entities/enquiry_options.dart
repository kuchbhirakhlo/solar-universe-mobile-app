/// Values matched to the admin's existing `enquiries` collection format
/// (see solarType/capacity fields on existing leads), so new leads sit
/// consistently alongside what the admin panel already shows.
class EnquiryOptions {
  EnquiryOptions._();

  static const List<String> systemTypes = [
    'On Grid',
    'Off Grid',
    'Hybrid',
  ];

  static const List<String> capacities = [
    '1KW',
    '2KW',
    '3KW',
    '5KW',
    'Above 5KW',
  ];

  static const String defaultSystemType = 'On Grid';
  static const String defaultCapacity = '1KW';
}

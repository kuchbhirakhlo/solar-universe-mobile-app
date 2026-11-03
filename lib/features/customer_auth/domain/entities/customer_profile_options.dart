/// Dropdown options for customer self-registration. Reuses
/// `EnquiryOptions.systemTypes`' 3 values but a discrete-kW capacity list
/// (matching real `customers` doc values like "5KW", "3KW") instead of the
/// public lead form's broader buckets ("Above 5KW") — a real customer
/// profile needs a specific capacity, not a bucket. Mirrors
/// `create_customer_screen.dart`'s `_staffCapacities` for the same reason.
class CustomerProfileOptions {
  CustomerProfileOptions._();

  static const List<String> systemTypes = ['On Grid', 'Off Grid', 'Hybrid'];

  static const List<String> capacities = [
    '1KW', '2KW', '3KW', '4KW', '5KW', '6KW', '7KW', '8KW', '9KW', '10KW',
  ];

  static const String defaultSystemType = 'On Grid';
  static const String defaultCapacity = '3KW';
}

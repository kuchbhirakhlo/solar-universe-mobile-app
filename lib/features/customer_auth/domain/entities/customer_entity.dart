import 'package:equatable/equatable.dart';

/// A solar customer's own profile, as seen from the customer-facing app.
/// Mirrors the real `customers` Firestore collection (shared with the staff
/// portal's `StaffCustomerEntity`) but omits `documents`/`createdByStaffId` —
/// those are staff-flow-only fields a self-registered customer never has.
class CustomerEntity extends Equatable {
  final String id;
  final String name;
  final String mobile;
  final String email;
  final String address;
  final String systemType;
  final String capacity;
  final String installationStatus;
  final String createdAt;

  const CustomerEntity({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.address,
    required this.systemType,
    required this.capacity,
    required this.installationStatus,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        mobile,
        email,
        address,
        systemType,
        capacity,
        installationStatus,
        createdAt,
      ];
}

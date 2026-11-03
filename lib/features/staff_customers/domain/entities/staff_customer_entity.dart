import 'package:equatable/equatable.dart';
import 'customer_documents_entity.dart';

class StaffCustomerEntity extends Equatable {
  final String id;
  final String name;
  final String mobile;
  final String email;
  final String address;
  final String systemType;
  final String capacity;
  final String installationStatus;
  final CustomerDocumentsEntity documents;
  final String? createdByStaffId;
  final String createdAt;

  const StaffCustomerEntity({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.address,
    required this.systemType,
    required this.capacity,
    required this.installationStatus,
    required this.documents,
    this.createdByStaffId,
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
        documents,
        createdByStaffId,
        createdAt,
      ];
}

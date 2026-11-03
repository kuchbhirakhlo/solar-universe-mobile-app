import '../../domain/entities/customer_documents_entity.dart';
import '../../domain/entities/staff_customer_entity.dart';

class StaffCustomerModel extends StaffCustomerEntity {
  const StaffCustomerModel({
    required super.id,
    required super.name,
    required super.mobile,
    required super.email,
    required super.address,
    required super.systemType,
    required super.capacity,
    required super.installationStatus,
    required super.documents,
    super.createdByStaffId,
    required super.createdAt,
  });

  factory StaffCustomerModel.fromMap(String id, Map<String, dynamic> map) {
    return StaffCustomerModel(
      id: id,
      name: map['name'] as String? ?? '',
      mobile: map['mobile'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      systemType: map['systemType'] as String? ?? '',
      capacity: map['capacity'] as String? ?? '',
      installationStatus: map['installationStatus'] as String? ?? 'In Progress',
      documents: CustomerDocumentsEntity.fromMap(
        Map<String, dynamic>.from(map['documents'] as Map? ?? const {}),
      ),
      createdByStaffId: map['createdByStaffId'] as String?,
      createdAt: map['createdAt'] as String? ?? '',
    );
  }
}

import '../../domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.name,
    required super.mobile,
    required super.email,
    required super.address,
    required super.systemType,
    required super.capacity,
    required super.installationStatus,
    required super.createdAt,
  });

  factory CustomerModel.fromMap(String id, Map<String, dynamic> map) {
    return CustomerModel(
      id: id,
      name: map['name'] as String? ?? '',
      mobile: map['mobile'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      systemType: map['systemType'] as String? ?? '',
      capacity: map['capacity'] as String? ?? '',
      installationStatus: map['installationStatus'] as String? ?? 'Pending',
      createdAt: map['createdAt'] as String? ?? '',
    );
  }
}

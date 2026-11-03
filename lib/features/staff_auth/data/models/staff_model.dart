import '../../domain/entities/staff_entity.dart';

class StaffModel extends StaffEntity {
  const StaffModel({
    required super.id,
    required super.employeeId,
    required super.name,
    required super.phone,
    required super.email,
    required super.role,
  });

  factory StaffModel.fromMap(String id, Map<String, dynamic> map) {
    return StaffModel(
      id: id,
      employeeId: map['employeeId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? '',
    );
  }
}

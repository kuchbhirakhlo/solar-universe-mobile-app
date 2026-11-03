import 'package:equatable/equatable.dart';

class StaffEntity extends Equatable {
  final String id;
  final String employeeId;
  final String name;
  final String phone;
  final String email;
  final String role;

  const StaffEntity({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
  });

  bool get isFieldSales => role.toLowerCase().contains('field');
  bool get isEngineer => role.toLowerCase().contains('engineer');

  @override
  List<Object?> get props => [id, employeeId, name, phone, email, role];
}

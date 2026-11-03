import 'package:equatable/equatable.dart';

class ContactMessageEntity extends Equatable {
  final String name;
  final String phone;
  final String email;
  final String message;

  const ContactMessageEntity({
    required this.name,
    required this.phone,
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [name, phone, email, message];
}

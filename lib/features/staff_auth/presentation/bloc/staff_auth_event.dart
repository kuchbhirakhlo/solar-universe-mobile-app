import 'package:equatable/equatable.dart';

abstract class StaffAuthEvent extends Equatable {
  const StaffAuthEvent();

  @override
  List<Object?> get props => [];
}

class RestoreStaffSessionEvent extends StaffAuthEvent {
  const RestoreStaffSessionEvent();
}

class SignInStaffEvent extends StaffAuthEvent {
  final String employeeId;
  final String password;

  const SignInStaffEvent(this.employeeId, this.password);

  @override
  List<Object?> get props => [employeeId, password];
}

class SignOutStaffEvent extends StaffAuthEvent {
  const SignOutStaffEvent();
}

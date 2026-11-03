import 'package:equatable/equatable.dart';
import '../../domain/entities/staff_entity.dart';

enum StaffAuthStatus { unknown, authenticating, authenticated, unauthenticated }

class StaffAuthState extends Equatable {
  final StaffAuthStatus status;
  final StaffEntity? staff;
  final String? errorMessage;

  const StaffAuthState({
    this.status = StaffAuthStatus.unknown,
    this.staff,
    this.errorMessage,
  });

  StaffAuthState copyWith({
    StaffAuthStatus? status,
    StaffEntity? staff,
    String? errorMessage,
  }) {
    return StaffAuthState(
      status: status ?? this.status,
      staff: staff ?? this.staff,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, staff, errorMessage];
}

import '../repositories/staff_auth_repository.dart';

class SignOutStaffUseCase {
  final StaffAuthRepository repository;
  SignOutStaffUseCase(this.repository);

  Future<void> call() => repository.signOut();
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff_entity.dart';
import '../repositories/staff_auth_repository.dart';

class SignInStaffUseCase {
  final StaffAuthRepository repository;
  SignInStaffUseCase(this.repository);

  Future<Either<Failure, StaffEntity>> call(String employeeId, String password) =>
      repository.signIn(employeeId, password);
}

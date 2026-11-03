import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/staff_entity.dart';

abstract class StaffAuthRepository {
  Future<Either<Failure, StaffEntity>> signIn(String employeeId, String password);
  Future<void> signOut();
  Future<StaffEntity?> getCurrentStaff();
}

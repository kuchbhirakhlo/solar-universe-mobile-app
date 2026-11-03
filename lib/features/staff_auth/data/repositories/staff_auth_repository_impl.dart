import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/repositories/staff_auth_repository.dart';
import '../datasources/staff_auth_datasource.dart';

class StaffAuthRepositoryImpl implements StaffAuthRepository {
  final StaffAuthDataSource dataSource;
  final NetworkInfo networkInfo;

  StaffAuthRepositoryImpl(this.dataSource, this.networkInfo);

  @override
  Future<Either<Failure, StaffEntity>> signIn(String employeeId, String password) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final staff = await dataSource.signIn(employeeId, password);
      return Right(staff);
    } on FirebaseAuthException catch (e) {
      return Left(ValidationFailure(_messageFor(e.code)));
    } catch (_) {
      return const Left(ValidationFailure('Invalid Employee ID or password.'));
    }
  }

  String _messageFor(String code) {
    switch (code) {
      case 'user-not-found':
      case 'invalid-credential':
      case 'invalid-email':
      case 'wrong-password':
        return 'Invalid Employee ID or password.';
      case 'user-disabled':
        return 'This account has been disabled. Contact your admin.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Sign-in failed. Please try again.';
    }
  }

  @override
  Future<void> signOut() => dataSource.signOut();

  @override
  Future<StaffEntity?> getCurrentStaff() => dataSource.getCurrentStaff();
}

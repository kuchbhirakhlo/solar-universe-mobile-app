import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_auth_repository.dart';

class VerifyCustomerOtpUseCase {
  final CustomerAuthRepository repository;
  VerifyCustomerOtpUseCase(this.repository);

  /// Returns the matching [CustomerEntity] if a profile already exists for
  /// this phone number, or `Right(null)` if verification succeeded but no
  /// profile exists yet (caller should route to profile setup).
  Future<Either<Failure, CustomerEntity?>> call({
    required String verificationId,
    required String smsCode,
    required String mobile,
  }) =>
      repository.verifyOtp(verificationId: verificationId, smsCode: smsCode, mobile: mobile);
}

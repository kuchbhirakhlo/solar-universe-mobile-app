import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_auth_repository.dart';
import '../datasources/customer_auth_datasource.dart';

class CustomerAuthRepositoryImpl implements CustomerAuthRepository {
  final CustomerAuthDataSource dataSource;

  CustomerAuthRepositoryImpl(this.dataSource);

  String _messageFor(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Enter a valid 10-digit mobile number.';
      case 'invalid-verification-code':
        return 'Incorrect OTP. Please check and try again.';
      case 'session-expired':
      case 'code-expired':
        return 'This OTP has expired. Please request a new one.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'quota-exceeded':
        return 'SMS quota exceeded for now. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network and try again.';
      case 'app-not-authorized':
      case 'missing-client-identifier':
      case 'invalid-app-credential':
      case 'captcha-check-failed':
      case 'web-internal-error':
        // App-verification (SHA fingerprint / Play Integrity) failures — a
        // build/config problem, not something the customer can fix.
        return 'Phone verification is not available right now. Please contact support. ($code)';
      default:
        // Keep the real Firebase code visible so a production failure can be
        // diagnosed from a screenshot instead of a generic message.
        return 'Something went wrong. Please try again. ($code)';
    }
  }

  @override
  Future<Either<Failure, String>> sendOtp({
    required String mobile,
    required void Function(CustomerEntity? profile) onAutoVerified,
  }) async {
    try {
      final verificationId = await dataSource.sendOtp(
        mobile: mobile,
        onAutoVerified: onAutoVerified,
      );
      return Right(verificationId);
    } on FirebaseAuthException catch (e) {
      return Left(ValidationFailure(_messageFor(e.code)));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, CustomerEntity?>> verifyOtp({
    required String verificationId,
    required String smsCode,
    required String mobile,
  }) async {
    try {
      await dataSource.confirmOtp(verificationId: verificationId, smsCode: smsCode);
      final profile = await dataSource.findProfileByMobile(mobile);
      return Right(profile);
    } on FirebaseAuthException catch (e) {
      return Left(ValidationFailure(_messageFor(e.code)));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> createProfile(NewCustomerProfile profile) async {
    try {
      final customer = await dataSource.createProfile(profile);
      return Right(customer);
    } catch (_) {
      return const Left(ServerFailure('Could not create your profile. Please try again.'));
    }
  }

  @override
  Future<CustomerRestoreResult> getCurrentCustomer() async {
    final mobile = dataSource.currentVerifiedMobile;
    if (mobile == null) return const CustomerRestoreResult();
    final profile = await dataSource.getCurrentProfile();
    return CustomerRestoreResult(verifiedMobile: mobile, profile: profile);
  }

  @override
  Future<void> signOut() => dataSource.signOut();
}

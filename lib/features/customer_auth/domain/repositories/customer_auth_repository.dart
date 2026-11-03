import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer_entity.dart';

/// Fields a customer fills in to self-register — no `documents` (no upload
/// step on this form, per the reference screenshot) and no
/// `installationStatus` (server-assigned, not customer-chosen; see
/// [CustomerAuthRepository.createProfile]).
class NewCustomerProfile {
  final String name;
  final String mobile;
  final String email;
  final String address;
  final String systemType;
  final String capacity;

  const NewCustomerProfile({
    required this.name,
    required this.mobile,
    required this.email,
    required this.address,
    required this.systemType,
    required this.capacity,
  });
}

/// The state of a session-restore check at app start — three distinct real
/// states, not two: never signed in, signed in but no profile yet, or fully
/// set up. (Unlike staff, where a Firebase Auth account only ever exists
/// for someone with a matching `staff` doc — here phone verification and
/// profile creation are two separate steps, so "verified, no profile" is a
/// real in-between state that can persist across app restarts.)
class CustomerRestoreResult {
  final String? verifiedMobile;
  final CustomerEntity? profile;

  const CustomerRestoreResult({this.verifiedMobile, this.profile});

  bool get isSignedIn => verifiedMobile != null;
}

abstract class CustomerAuthRepository {
  /// Sends an OTP to [mobile] (bare 10-digit). Returns the verification ID
  /// needed to confirm the code, unless Android auto-verifies instantly —
  /// in that case [onAutoVerified] fires instead and the caller should treat
  /// it the same as a successful [verifyOtp].
  Future<Either<Failure, String>> sendOtp({
    required String mobile,
    required void Function(CustomerEntity? profile) onAutoVerified,
  });

  Future<Either<Failure, CustomerEntity?>> verifyOtp({
    required String verificationId,
    required String smsCode,
    required String mobile,
  });

  Future<Either<Failure, CustomerEntity>> createProfile(NewCustomerProfile profile);

  Future<CustomerRestoreResult> getCurrentCustomer();

  Future<void> signOut();
}

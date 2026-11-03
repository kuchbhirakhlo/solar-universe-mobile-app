import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_auth_repository.dart';

class SendCustomerOtpUseCase {
  final CustomerAuthRepository repository;
  SendCustomerOtpUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String mobile,
    required void Function(CustomerEntity? profile) onAutoVerified,
  }) =>
      repository.sendOtp(mobile: mobile, onAutoVerified: onAutoVerified);
}

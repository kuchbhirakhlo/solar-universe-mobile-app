import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_auth_repository.dart';

class CreateCustomerProfileUseCase {
  final CustomerAuthRepository repository;
  CreateCustomerProfileUseCase(this.repository);

  Future<Either<Failure, CustomerEntity>> call(NewCustomerProfile profile) =>
      repository.createProfile(profile);
}

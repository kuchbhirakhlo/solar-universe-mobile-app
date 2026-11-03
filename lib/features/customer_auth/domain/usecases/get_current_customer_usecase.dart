import '../repositories/customer_auth_repository.dart';

class GetCurrentCustomerUseCase {
  final CustomerAuthRepository repository;
  GetCurrentCustomerUseCase(this.repository);

  Future<CustomerRestoreResult> call() => repository.getCurrentCustomer();
}

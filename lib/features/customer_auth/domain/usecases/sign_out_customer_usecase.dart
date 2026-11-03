import '../repositories/customer_auth_repository.dart';

class SignOutCustomerUseCase {
  final CustomerAuthRepository repository;
  SignOutCustomerUseCase(this.repository);

  Future<void> call() => repository.signOut();
}

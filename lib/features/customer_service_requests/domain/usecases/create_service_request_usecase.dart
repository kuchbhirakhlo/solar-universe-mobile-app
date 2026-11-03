import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/customer_service_requests_repository.dart';

class CreateServiceRequestUseCase {
  final CustomerServiceRequestsRepository repository;
  CreateServiceRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(NewServiceRequest request) =>
      repository.createRequest(request);
}

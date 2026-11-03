import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/service_request_entity.dart';
import '../repositories/customer_service_requests_repository.dart';

class GetMyServiceRequestsUseCase {
  final CustomerServiceRequestsRepository repository;
  GetMyServiceRequestsUseCase(this.repository);

  Future<Either<Failure, List<ServiceRequestEntity>>> call(String customerId) =>
      repository.getMyRequests(customerId);
}

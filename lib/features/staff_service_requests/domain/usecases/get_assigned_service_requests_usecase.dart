import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../customer_service_requests/domain/entities/service_request_entity.dart';
import '../repositories/staff_service_requests_repository.dart';

class GetAssignedServiceRequestsUseCase {
  final StaffServiceRequestsRepository repository;
  GetAssignedServiceRequestsUseCase(this.repository);

  Future<Either<Failure, List<ServiceRequestEntity>>> call(
    String engineerId, {
    String employeeId = '',
  }) =>
      repository.getAssignedRequests(engineerId, employeeId: employeeId);
}

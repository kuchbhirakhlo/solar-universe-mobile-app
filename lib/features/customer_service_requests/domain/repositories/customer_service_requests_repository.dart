import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/service_request_entity.dart';

/// What a customer fills in to raise a new request — no status/engineer/cost
/// fields, those are admin-only (see `ServiceRequestOptions.initialStatus`).
class NewServiceRequest {
  final String customerId;
  final String customerName;
  final String customerMobile;
  final String serviceType;
  final String description;
  final String remark;

  const NewServiceRequest({
    required this.customerId,
    required this.customerName,
    required this.customerMobile,
    required this.serviceType,
    required this.description,
    this.remark = '',
  });
}

abstract class CustomerServiceRequestsRepository {
  Future<Either<Failure, List<ServiceRequestEntity>>> getMyRequests(String customerId);

  Future<Either<Failure, void>> createRequest(NewServiceRequest request);
}

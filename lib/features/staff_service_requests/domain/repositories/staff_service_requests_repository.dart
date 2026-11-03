import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../customer_service_requests/domain/entities/service_request_entity.dart';

/// Reuses `ServiceRequestEntity` from `customer_service_requests` — same
/// Firestore collection/schema, this feature just queries/writes it from
/// the engineer's side (assigned-to-me, status/remark/photos) instead of
/// the customer's (mine-by-customerId, create-only).
abstract class StaffServiceRequestsRepository {
  Future<Either<Failure, List<ServiceRequestEntity>>> getAssignedRequests(
    String engineerId, {
    String employeeId = '',
  });

  Future<Either<Failure, void>> updateStatusAndRemark({
    required String requestId,
    required String status,
    required String remark,
  });

  /// Uploads one photo and appends its URL to `installationPhotos` — a new
  /// field, additive to the schema, not written/read by anything else.
  /// No-ops (returns success without a network call) when
  /// `AppConfig.storageUploadsEnabled` is false.
  Future<Either<Failure, void>> uploadInstallationPhoto({
    required String requestId,
    required String filePath,
  });
}

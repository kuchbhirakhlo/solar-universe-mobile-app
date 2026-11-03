import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../customer_service_requests/domain/entities/service_request_entity.dart';
import '../../domain/repositories/staff_service_requests_repository.dart';
import '../datasources/staff_service_requests_datasource.dart';

class StaffServiceRequestsRepositoryImpl implements StaffServiceRequestsRepository {
  final StaffServiceRequestsDataSource dataSource;
  final NetworkInfo networkInfo;

  StaffServiceRequestsRepositoryImpl(this.dataSource, this.networkInfo);

  @override
  Future<Either<Failure, List<ServiceRequestEntity>>> getAssignedRequests(
    String engineerId, {
    String employeeId = '',
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final requests = await dataSource.getAssignedRequests(
        engineerId,
        employeeId: employeeId,
      );
      return Right(requests);
    } catch (_) {
      return const Left(ServerFailure('Could not load your assigned service requests.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateStatusAndRemark({
    required String requestId,
    required String status,
    required String remark,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await dataSource.updateStatusAndRemark(requestId: requestId, status: status, remark: remark);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Could not update this service request.'));
    }
  }

  @override
  Future<Either<Failure, void>> uploadInstallationPhoto({
    required String requestId,
    required String filePath,
  }) async {
    try {
      await dataSource.uploadInstallationPhoto(requestId: requestId, filePath: filePath);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Could not upload this photo.'));
    }
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/service_request_entity.dart';
import '../../domain/repositories/customer_service_requests_repository.dart';
import '../datasources/customer_service_requests_datasource.dart';

class CustomerServiceRequestsRepositoryImpl implements CustomerServiceRequestsRepository {
  final CustomerServiceRequestsDataSource dataSource;
  final NetworkInfo networkInfo;

  CustomerServiceRequestsRepositoryImpl(this.dataSource, this.networkInfo);

  @override
  Future<Either<Failure, List<ServiceRequestEntity>>> getMyRequests(String customerId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final requests = await dataSource.getMyRequests(customerId);
      return Right(requests);
    } catch (_) {
      return const Left(ServerFailure('Could not load your service requests.'));
    }
  }

  @override
  Future<Either<Failure, void>> createRequest(NewServiceRequest request) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await dataSource.createRequest(request);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure('Could not submit your service request. Please try again.'));
    }
  }
}

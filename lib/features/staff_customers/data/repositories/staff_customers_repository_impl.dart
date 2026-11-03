import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/staff_customer_entity.dart';
import '../../domain/repositories/staff_customers_repository.dart';
import '../datasources/staff_customers_datasource.dart';

class StaffCustomersRepositoryImpl implements StaffCustomersRepository {
  final StaffCustomersDataSource dataSource;
  final NetworkInfo networkInfo;
  final String Function() currentStaffId;

  StaffCustomersRepositoryImpl(this.dataSource, this.networkInfo, this.currentStaffId);

  @override
  Future<Either<Failure, List<StaffCustomerEntity>>> getCustomers() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await dataSource.getCustomers(staffId: currentStaffId()));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  String reserveCustomerId() => dataSource.reserveCustomerId();

  @override
  Future<Either<Failure, void>> createCustomer(
    NewStaffCustomer customer, {
    required String customerId,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await dataSource.createCustomer(customer, customerId: customerId, staffId: currentStaffId());
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> uploadDocument({
    required String customerId,
    required String docType,
    required String filePath,
    bool multi = false,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await dataSource.uploadDocument(
        customerId: customerId,
        docType: docType,
        filePath: filePath,
        multi: multi,
      );
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}

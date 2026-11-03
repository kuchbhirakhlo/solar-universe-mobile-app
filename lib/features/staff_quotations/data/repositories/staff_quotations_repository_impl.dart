import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/quotation_entity.dart';
import '../../domain/repositories/staff_quotations_repository.dart';
import '../datasources/staff_quotations_datasource.dart';

class StaffQuotationsRepositoryImpl implements StaffQuotationsRepository {
  final StaffQuotationsDataSource dataSource;
  final NetworkInfo networkInfo;
  final String Function() currentStaffId;
  final String Function() currentStaffName;

  StaffQuotationsRepositoryImpl(
    this.dataSource,
    this.networkInfo,
    this.currentStaffId,
    this.currentStaffName,
  );

  @override
  Future<Either<Failure, List<QuotationEntity>>> getQuotations() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await dataSource.getQuotations(staffId: currentStaffId()));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, QuotationEntity>> createQuotation(NewQuotation quotation) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final result = await dataSource.createQuotation(
        quotation,
        preparedBy: currentStaffName(),
        staffId: currentStaffId(),
      );
      return Right(result);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}

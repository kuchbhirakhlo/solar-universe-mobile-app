import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/company_info_entity.dart';
import '../../domain/entities/faq_entity.dart';
import '../../domain/entities/package_entity.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/solution_entity.dart';
import '../../domain/repositories/content_repository.dart';
import '../datasources/content_datasource.dart';

class ContentRepositoryImpl implements ContentRepository {
  final ContentDataSource dataSource;
  final NetworkInfo networkInfo;

  ContentRepositoryImpl(this.dataSource, this.networkInfo);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await action());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  // Company info and solutions are static (no Firestore round-trip), so they
  // don't need a connectivity check.
  @override
  Future<Either<Failure, CompanyInfoEntity>> getCompanyInfo() async =>
      Right(await dataSource.getCompanyInfo());

  @override
  Future<Either<Failure, List<SolutionEntity>>> getSolutions() async =>
      Right(await dataSource.getSolutions());

  @override
  Future<Either<Failure, List<PackageEntity>>> getPackages() => _guard(dataSource.getPackages);

  @override
  Future<Either<Failure, List<ProjectEntity>>> getProjects() => _guard(dataSource.getProjects);

  @override
  Future<Either<Failure, List<FaqEntity>>> getFaqs() => _guard(dataSource.getFaqs);

  @override
  Future<Either<Failure, List<BrandEntity>>> getBrands() => _guard(dataSource.getBrands);
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/brand_entity.dart';
import '../entities/company_info_entity.dart';
import '../entities/faq_entity.dart';
import '../entities/package_entity.dart';
import '../entities/project_entity.dart';
import '../entities/solution_entity.dart';

abstract class ContentRepository {
  Future<Either<Failure, CompanyInfoEntity>> getCompanyInfo();
  Future<Either<Failure, List<SolutionEntity>>> getSolutions();
  Future<Either<Failure, List<PackageEntity>>> getPackages();
  Future<Either<Failure, List<ProjectEntity>>> getProjects();
  Future<Either<Failure, List<FaqEntity>>> getFaqs();
  Future<Either<Failure, List<BrandEntity>>> getBrands();
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/company_info_entity.dart';
import '../repositories/content_repository.dart';

class GetCompanyInfoUseCase {
  final ContentRepository repository;
  GetCompanyInfoUseCase(this.repository);

  Future<Either<Failure, CompanyInfoEntity>> call() => repository.getCompanyInfo();
}

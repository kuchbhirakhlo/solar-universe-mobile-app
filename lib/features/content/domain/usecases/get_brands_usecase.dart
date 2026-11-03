import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/brand_entity.dart';
import '../repositories/content_repository.dart';

class GetBrandsUseCase {
  final ContentRepository repository;
  GetBrandsUseCase(this.repository);

  Future<Either<Failure, List<BrandEntity>>> call() => repository.getBrands();
}

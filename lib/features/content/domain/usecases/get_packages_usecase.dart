import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/package_entity.dart';
import '../repositories/content_repository.dart';

class GetPackagesUseCase {
  final ContentRepository repository;
  GetPackagesUseCase(this.repository);

  Future<Either<Failure, List<PackageEntity>>> call() => repository.getPackages();
}

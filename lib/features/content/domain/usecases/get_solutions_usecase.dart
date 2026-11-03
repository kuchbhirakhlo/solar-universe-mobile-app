import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/solution_entity.dart';
import '../repositories/content_repository.dart';

class GetSolutionsUseCase {
  final ContentRepository repository;
  GetSolutionsUseCase(this.repository);

  Future<Either<Failure, List<SolutionEntity>>> call() => repository.getSolutions();
}

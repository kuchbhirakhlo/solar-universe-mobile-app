import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/project_entity.dart';
import '../repositories/content_repository.dart';

class GetProjectsUseCase {
  final ContentRepository repository;
  GetProjectsUseCase(this.repository);

  Future<Either<Failure, List<ProjectEntity>>> call() => repository.getProjects();
}

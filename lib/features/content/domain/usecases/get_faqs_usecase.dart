import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/faq_entity.dart';
import '../repositories/content_repository.dart';

class GetFaqsUseCase {
  final ContentRepository repository;
  GetFaqsUseCase(this.repository);

  Future<Either<Failure, List<FaqEntity>>> call() => repository.getFaqs();
}

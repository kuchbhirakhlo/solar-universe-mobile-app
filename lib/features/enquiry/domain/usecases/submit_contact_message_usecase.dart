import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/contact_message_entity.dart';
import '../repositories/enquiry_repository.dart';

class SubmitContactMessageUseCase {
  final EnquiryRepository repository;
  SubmitContactMessageUseCase(this.repository);

  Future<Either<Failure, void>> call(ContactMessageEntity message) =>
      repository.submitContactMessage(message);
}

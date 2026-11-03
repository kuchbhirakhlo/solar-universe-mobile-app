import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/enquiry_entity.dart';
import '../repositories/enquiry_repository.dart';

class SubmitEnquiryUseCase {
  final EnquiryRepository repository;
  SubmitEnquiryUseCase(this.repository);

  Future<Either<Failure, void>> call(EnquiryEntity enquiry) =>
      repository.submitEnquiry(enquiry);
}

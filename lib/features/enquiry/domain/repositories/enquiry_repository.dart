import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/contact_message_entity.dart';
import '../entities/enquiry_entity.dart';

abstract class EnquiryRepository {
  Future<Either<Failure, void>> submitEnquiry(EnquiryEntity enquiry);
  Future<Either<Failure, void>> submitContactMessage(ContactMessageEntity message);
}

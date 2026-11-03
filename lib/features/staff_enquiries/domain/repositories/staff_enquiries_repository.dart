import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/staged_file.dart';
import '../entities/staff_enquiry_entity.dart';

class NewStaffEnquiry {
  final String name;
  final String phone;
  final String city;
  final String solarType;
  final String capacity;
  final String message;
  final String salesType;
  final StagedFile? sitePhoto;
  final DateTime enquiryDateTime;

  const NewStaffEnquiry({
    required this.name,
    required this.phone,
    required this.city,
    required this.solarType,
    required this.capacity,
    required this.message,
    required this.salesType,
    this.sitePhoto,
    required this.enquiryDateTime,
  });
}

abstract class StaffEnquiriesRepository {
  Future<Either<Failure, List<StaffEnquiryEntity>>> getEnquiries();
  Future<Either<Failure, void>> createEnquiry(NewStaffEnquiry enquiry);
  Future<Either<Failure, void>> updateEnquiryStatus({
    required String enquiryId,
    required String status,
    required String remark,
  });
}

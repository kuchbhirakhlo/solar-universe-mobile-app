import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/staff_enquiry_entity.dart';
import '../../domain/repositories/staff_enquiries_repository.dart';
import '../datasources/staff_enquiries_datasource.dart';

class StaffEnquiriesRepositoryImpl implements StaffEnquiriesRepository {
  final StaffEnquiriesDataSource dataSource;
  final NetworkInfo networkInfo;
  final String Function() currentStaffId;
  final String Function() currentStaffName;

  StaffEnquiriesRepositoryImpl(
    this.dataSource,
    this.networkInfo,
    this.currentStaffId,
    this.currentStaffName,
  );

  @override
  Future<Either<Failure, List<StaffEnquiryEntity>>> getEnquiries() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await dataSource.getEnquiries(staffId: currentStaffId()));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> createEnquiry(NewStaffEnquiry enquiry) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await dataSource.createEnquiry(
        enquiry,
        staffId: currentStaffId(),
        staffName: currentStaffName(),
      );
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateEnquiryStatus({
    required String enquiryId,
    required String status,
    required String remark,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await dataSource.updateEnquiryStatus(
        enquiryId: enquiryId,
        status: status,
        remark: remark,
        updatedBy: currentStaffName(),
      );
      return const Right(null);
    } on FirebaseException catch (e) {
      // Keep the real code visible ("permission-denied", "unavailable"...) so a
      // failing phone can be diagnosed from a screenshot.
      return Left(ServerFailure('Could not update this enquiry (${e.code}). Please try again.'));
    } catch (_) {
      return const Left(ServerFailure('Could not update this enquiry. Please try again.'));
    }
  }
}

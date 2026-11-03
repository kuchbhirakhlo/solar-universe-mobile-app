import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/contact_message_entity.dart';
import '../../domain/entities/enquiry_entity.dart';
import '../../domain/repositories/enquiry_repository.dart';
import '../datasources/enquiry_datasource.dart';

class EnquiryRepositoryImpl implements EnquiryRepository {
  final EnquiryDataSource dataSource;
  final NetworkInfo networkInfo;

  EnquiryRepositoryImpl(this.dataSource, this.networkInfo);

  @override
  Future<Either<Failure, void>> submitEnquiry(EnquiryEntity enquiry) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await dataSource.submitEnquiry(enquiry);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> submitContactMessage(ContactMessageEntity message) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      await dataSource.submitContactMessage(message);
      return const Right(null);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}

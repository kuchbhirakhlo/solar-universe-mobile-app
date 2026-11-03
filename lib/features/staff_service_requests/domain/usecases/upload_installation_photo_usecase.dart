import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/staff_service_requests_repository.dart';

class UploadInstallationPhotoUseCase {
  final StaffServiceRequestsRepository repository;
  UploadInstallationPhotoUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String requestId,
    required String filePath,
  }) =>
      repository.uploadInstallationPhoto(requestId: requestId, filePath: filePath);
}

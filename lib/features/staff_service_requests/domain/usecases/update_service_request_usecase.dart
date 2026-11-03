import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/staff_service_requests_repository.dart';

class UpdateServiceRequestUseCase {
  final StaffServiceRequestsRepository repository;
  UpdateServiceRequestUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String requestId,
    required String status,
    required String remark,
  }) =>
      repository.updateStatusAndRemark(requestId: requestId, status: status, remark: remark);
}

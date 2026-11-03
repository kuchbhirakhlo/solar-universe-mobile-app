import '../entities/staff_entity.dart';
import '../repositories/staff_auth_repository.dart';

class GetCurrentStaffUseCase {
  final StaffAuthRepository repository;
  GetCurrentStaffUseCase(this.repository);

  Future<StaffEntity?> call() => repository.getCurrentStaff();
}

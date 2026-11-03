import 'package:equatable/equatable.dart';

abstract class StaffServiceRequestsEvent extends Equatable {
  const StaffServiceRequestsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAssignedServiceRequestsEvent extends StaffServiceRequestsEvent {
  final String engineerId;
  final String employeeId;
  const LoadAssignedServiceRequestsEvent(this.engineerId, {this.employeeId = ''});
  @override
  List<Object?> get props => [engineerId, employeeId];
}

class UpdateAssignedServiceRequestEvent extends StaffServiceRequestsEvent {
  final String requestId;
  final String status;
  final String remark;
  final String engineerId;
  final String employeeId;
  const UpdateAssignedServiceRequestEvent({
    required this.requestId,
    required this.status,
    required this.remark,
    required this.engineerId,
    this.employeeId = '',
  });
  @override
  List<Object?> get props => [requestId, status, remark, engineerId, employeeId];
}

class UploadInstallationPhotoEvent extends StaffServiceRequestsEvent {
  final String requestId;
  final String filePath;
  final String engineerId;
  final String employeeId;
  const UploadInstallationPhotoEvent({
    required this.requestId,
    required this.filePath,
    required this.engineerId,
    this.employeeId = '',
  });
  @override
  List<Object?> get props => [requestId, filePath, engineerId, employeeId];
}

/// Clears actionStatus back to idle — this bloc is a singleton, same reason
/// `customer_service_requests` needs its own reset event.
class ResetServiceRequestActionStatusEvent extends StaffServiceRequestsEvent {
  const ResetServiceRequestActionStatusEvent();
}

/// Drops the singleton list so the next engineer login cannot reuse a
/// previous empty/error state.
class ResetAssignedServiceRequestsEvent extends StaffServiceRequestsEvent {
  const ResetAssignedServiceRequestsEvent();
}

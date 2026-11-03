import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_assigned_service_requests_usecase.dart';
import '../../domain/usecases/update_service_request_usecase.dart';
import '../../domain/usecases/upload_installation_photo_usecase.dart';
import 'staff_service_requests_event.dart';
import 'staff_service_requests_state.dart';

/// Singleton (like `StaffEnquiriesBloc`) — the list refreshes itself after a
/// status/remark update or a photo upload, and the detail screen (a
/// separately routed, pushed screen) shares this same instance/state
/// rather than getting a fresh one.
class StaffServiceRequestsBloc extends Bloc<StaffServiceRequestsEvent, StaffServiceRequestsState> {
  final GetAssignedServiceRequestsUseCase getAssignedRequests;
  final UpdateServiceRequestUseCase updateRequest;
  final UploadInstallationPhotoUseCase uploadPhoto;

  StaffServiceRequestsBloc(this.getAssignedRequests, this.updateRequest, this.uploadPhoto)
      : super(const StaffServiceRequestsState()) {
    on<LoadAssignedServiceRequestsEvent>(_onLoad);
    on<UpdateAssignedServiceRequestEvent>(_onUpdate);
    on<UploadInstallationPhotoEvent>(_onUploadPhoto);
    on<ResetServiceRequestActionStatusEvent>(_onResetActionStatus);
    on<ResetAssignedServiceRequestsEvent>(_onResetList);
  }

  Future<void> _onLoad(
    LoadAssignedServiceRequestsEvent event,
    Emitter<StaffServiceRequestsState> emit,
  ) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading, loadError: null));
    final result = await getAssignedRequests(
      event.engineerId,
      employeeId: event.employeeId,
    );
    result.fold(
      (failure) => emit(state.copyWith(loadStatus: LoadStatus.error, loadError: failure.message)),
      (requests) => emit(state.copyWith(loadStatus: LoadStatus.loaded, requests: requests)),
    );
  }

  Future<void> _onUpdate(
    UpdateAssignedServiceRequestEvent event,
    Emitter<StaffServiceRequestsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: ActionStatus.working, actionError: null));
    final result = await updateRequest(
      requestId: event.requestId,
      status: event.status,
      remark: event.remark,
    );
    await result.fold(
      (failure) async => emit(state.copyWith(
        actionStatus: ActionStatus.error,
        actionError: failure.message,
      )),
      (_) async {
        emit(state.copyWith(actionStatus: ActionStatus.success, actionError: null));
        add(LoadAssignedServiceRequestsEvent(event.engineerId, employeeId: event.employeeId));
      },
    );
  }

  Future<void> _onUploadPhoto(
    UploadInstallationPhotoEvent event,
    Emitter<StaffServiceRequestsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: ActionStatus.working, actionError: null));
    final result = await uploadPhoto(requestId: event.requestId, filePath: event.filePath);
    await result.fold(
      (failure) async => emit(state.copyWith(
        actionStatus: ActionStatus.error,
        actionError: failure.message,
      )),
      (_) async {
        emit(state.copyWith(actionStatus: ActionStatus.success, actionError: null));
        add(LoadAssignedServiceRequestsEvent(event.engineerId, employeeId: event.employeeId));
      },
    );
  }

  void _onResetActionStatus(
    ResetServiceRequestActionStatusEvent event,
    Emitter<StaffServiceRequestsState> emit,
  ) {
    emit(state.copyWith(actionStatus: ActionStatus.idle, actionError: null));
  }

  void _onResetList(
    ResetAssignedServiceRequestsEvent event,
    Emitter<StaffServiceRequestsState> emit,
  ) {
    emit(const StaffServiceRequestsState());
  }
}

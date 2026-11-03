import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_service_request_usecase.dart';
import '../../domain/usecases/get_my_service_requests_usecase.dart';
import 'customer_service_requests_event.dart';
import 'customer_service_requests_state.dart';

/// Registered as a singleton (like `StaffEnquiriesBloc`) so the dashboard's
/// list refreshes itself right after a new request is submitted, and the
/// Create Service Request screen shares submit-status with whatever's
/// listening on the dashboard underneath it.
class CustomerServiceRequestsBloc
    extends Bloc<CustomerServiceRequestsEvent, CustomerServiceRequestsState> {
  final GetMyServiceRequestsUseCase getMyRequests;
  final CreateServiceRequestUseCase createRequest;

  CustomerServiceRequestsBloc(this.getMyRequests, this.createRequest)
      : super(const CustomerServiceRequestsState()) {
    on<LoadMyServiceRequestsEvent>(_onLoad);
    on<SubmitServiceRequestEvent>(_onSubmit);
    on<ResetServiceRequestSubmitStatusEvent>(_onResetSubmitStatus);
  }

  Future<void> _onLoad(
    LoadMyServiceRequestsEvent event,
    Emitter<CustomerServiceRequestsState> emit,
  ) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading, loadError: null));
    final result = await getMyRequests(event.customerId);
    result.fold(
      (failure) => emit(state.copyWith(loadStatus: LoadStatus.error, loadError: failure.message)),
      (requests) => emit(state.copyWith(loadStatus: LoadStatus.loaded, requests: requests)),
    );
  }

  Future<void> _onSubmit(
    SubmitServiceRequestEvent event,
    Emitter<CustomerServiceRequestsState> emit,
  ) async {
    emit(state.copyWith(submitStatus: SubmitStatus.submitting, submitError: null));
    final result = await createRequest(event.request);
    await result.fold(
      (failure) async => emit(state.copyWith(
        submitStatus: SubmitStatus.error,
        submitError: failure.message,
      )),
      (_) async {
        emit(state.copyWith(submitStatus: SubmitStatus.submitted, submitError: null));
        // Refresh the list immediately so the dashboard shows the new
        // request without the customer needing to pull-to-refresh.
        add(LoadMyServiceRequestsEvent(event.request.customerId));
      },
    );
  }

  void _onResetSubmitStatus(
    ResetServiceRequestSubmitStatusEvent event,
    Emitter<CustomerServiceRequestsState> emit,
  ) {
    emit(state.copyWith(submitStatus: SubmitStatus.idle, submitError: null));
  }
}

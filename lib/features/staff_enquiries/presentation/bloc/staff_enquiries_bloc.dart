import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/staff_enquiries_repository.dart';
import 'staff_enquiries_event.dart';
import 'staff_enquiries_state.dart';

class StaffEnquiriesBloc extends Bloc<StaffEnquiriesEvent, StaffEnquiriesState> {
  final StaffEnquiriesRepository repository;

  StaffEnquiriesBloc(this.repository) : super(const StaffEnquiriesState()) {
    on<LoadStaffEnquiriesEvent>(_onLoad);
    on<SubmitStaffEnquiryEvent>(_onSubmit);
    on<ResetSubmitStatusEvent>(
      (event, emit) => emit(state.copyWith(submitStatus: SubmitStatus.initial)),
    );
    on<UpdateEnquiryStatusEvent>(_onUpdateStatus);
    on<ResetEnquiryActionEvent>(
      (event, emit) => emit(state.copyWith(actionStatus: EnquiryActionStatus.idle)),
    );
  }

  Future<void> _onLoad(LoadStaffEnquiriesEvent event, Emitter<StaffEnquiriesState> emit) async {
    emit(state.copyWith(listStatus: ListStatus.loading));
    final result = await repository.getEnquiries();
    result.fold(
      (failure) =>
          emit(state.copyWith(listStatus: ListStatus.failure, listError: failure.message)),
      (list) => emit(state.copyWith(listStatus: ListStatus.success, enquiries: list)),
    );
  }

  Future<void> _onSubmit(SubmitStaffEnquiryEvent event, Emitter<StaffEnquiriesState> emit) async {
    emit(state.copyWith(submitStatus: SubmitStatus.submitting));
    final result = await repository.createEnquiry(event.enquiry);
    await result.fold(
      (failure) async {
        emit(state.copyWith(submitStatus: SubmitStatus.failure, submitError: failure.message));
      },
      (_) async {
        emit(state.copyWith(submitStatus: SubmitStatus.success));
        add(const LoadStaffEnquiriesEvent());
      },
    );
  }

  Future<void> _onUpdateStatus(
    UpdateEnquiryStatusEvent event,
    Emitter<StaffEnquiriesState> emit,
  ) async {
    emit(state.copyWith(actionStatus: EnquiryActionStatus.working));
    final result = await repository.updateEnquiryStatus(
      enquiryId: event.enquiryId,
      status: event.status,
      remark: event.remark,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(actionStatus: EnquiryActionStatus.error, actionError: failure.message),
      ),
      (_) {
        emit(state.copyWith(actionStatus: EnquiryActionStatus.success));
        add(const LoadStaffEnquiriesEvent());
      },
    );
  }
}

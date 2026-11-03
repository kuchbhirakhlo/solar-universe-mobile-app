import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/staff_customers_repository.dart';
import 'staff_customers_event.dart';
import 'staff_customers_state.dart';

class StaffCustomersBloc extends Bloc<StaffCustomersEvent, StaffCustomersState> {
  final StaffCustomersRepository repository;

  StaffCustomersBloc(this.repository) : super(const StaffCustomersState()) {
    on<LoadStaffCustomersEvent>(_onLoad);
    on<SubmitStaffCustomerEvent>(_onSubmit);
    on<UploadCustomerDocumentEvent>(_onUpload);
    on<ResetCustomerSubmitStatusEvent>(
      (event, emit) => emit(state.copyWith(submitStatus: SubmitStatus.initial)),
    );
  }

  Future<void> _onLoad(LoadStaffCustomersEvent event, Emitter<StaffCustomersState> emit) async {
    emit(state.copyWith(listStatus: ListStatus.loading));
    final result = await repository.getCustomers();
    result.fold(
      (failure) =>
          emit(state.copyWith(listStatus: ListStatus.failure, listError: failure.message)),
      (list) => emit(state.copyWith(listStatus: ListStatus.success, customers: list)),
    );
  }

  Future<void> _onSubmit(
    SubmitStaffCustomerEvent event,
    Emitter<StaffCustomersState> emit,
  ) async {
    emit(state.copyWith(submitStatus: SubmitStatus.submitting));
    final result = await repository.createCustomer(event.customer, customerId: event.customerId);
    await result.fold(
      (failure) async {
        emit(state.copyWith(submitStatus: SubmitStatus.failure, submitError: failure.message));
      },
      (_) async {
        emit(state.copyWith(submitStatus: SubmitStatus.success));
        add(const LoadStaffCustomersEvent());
      },
    );
  }

  Future<void> _onUpload(
    UploadCustomerDocumentEvent event,
    Emitter<StaffCustomersState> emit,
  ) async {
    emit(state.copyWith(uploadStatus: SubmitStatus.submitting));
    final result = await repository.uploadDocument(
      customerId: event.customerId,
      docType: event.docType,
      filePath: event.filePath,
      multi: event.multi,
    );
    await result.fold(
      (failure) async {
        emit(state.copyWith(uploadStatus: SubmitStatus.failure, uploadError: failure.message));
      },
      (_) async {
        emit(state.copyWith(uploadStatus: SubmitStatus.success));
        add(const LoadStaffCustomersEvent());
      },
    );
  }
}

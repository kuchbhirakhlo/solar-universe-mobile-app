import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/submit_contact_message_usecase.dart';
import '../../domain/usecases/submit_enquiry_usecase.dart';
import 'enquiry_event.dart';
import 'enquiry_state.dart';

class EnquiryBloc extends Bloc<EnquiryEvent, EnquiryState> {
  final SubmitEnquiryUseCase submitEnquiry;
  final SubmitContactMessageUseCase submitContactMessage;

  EnquiryBloc(this.submitEnquiry, this.submitContactMessage) : super(const EnquiryState()) {
    on<SubmitEnquiryEvent>(_onSubmitEnquiry);
    on<SubmitContactMessageEvent>(_onSubmitContactMessage);
    on<ResetEnquiryStatusEvent>((event, emit) => emit(const EnquiryState()));
  }

  Future<void> _onSubmitEnquiry(SubmitEnquiryEvent event, Emitter<EnquiryState> emit) async {
    emit(state.copyWith(enquiryStatus: SubmitStatus.submitting));
    final result = await submitEnquiry(event.enquiry);
    result.fold(
      (failure) => emit(state.copyWith(
        enquiryStatus: SubmitStatus.failure,
        enquiryError: failure.message,
      )),
      (_) => emit(state.copyWith(enquiryStatus: SubmitStatus.success)),
    );
  }

  Future<void> _onSubmitContactMessage(
    SubmitContactMessageEvent event,
    Emitter<EnquiryState> emit,
  ) async {
    emit(state.copyWith(contactStatus: SubmitStatus.submitting));
    final result = await submitContactMessage(event.message);
    result.fold(
      (failure) => emit(state.copyWith(
        contactStatus: SubmitStatus.failure,
        contactError: failure.message,
      )),
      (_) => emit(state.copyWith(contactStatus: SubmitStatus.success)),
    );
  }
}

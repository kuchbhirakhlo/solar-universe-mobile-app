import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/session/customer_session.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/create_customer_profile_usecase.dart';
import '../../domain/usecases/send_customer_otp_usecase.dart';
import '../../domain/usecases/sign_out_customer_usecase.dart';
import '../../domain/usecases/verify_customer_otp_usecase.dart';
import 'customer_auth_event.dart';
import 'customer_auth_state.dart';

class CustomerAuthBloc extends Bloc<CustomerAuthEvent, CustomerAuthState> {
  final SendCustomerOtpUseCase sendOtp;
  final VerifyCustomerOtpUseCase verifyOtp;
  final CreateCustomerProfileUseCase createProfile;
  final SignOutCustomerUseCase signOutCustomer;
  final CustomerSession session;

  CustomerAuthBloc(
    this.sendOtp,
    this.verifyOtp,
    this.createProfile,
    this.signOutCustomer,
    this.session,
  ) : super(const CustomerAuthState()) {
    on<SendCustomerOtpEvent>(_onSendOtp);
    on<ResendCustomerOtpEvent>(_onResendOtp);
    on<VerifyCustomerOtpEvent>(_onVerifyOtp);
    on<CreateCustomerProfileEvent>(_onCreateProfile);
    on<SignOutCustomerEvent>(_onSignOut);
  }

  void _handleAutoVerified(CustomerEntity? profile) {
    // Fires from a background Android SMS-Retriever auto-verification —
    // there's no in-flight `emit` to attach this to (the event handler that
    // started it has already returned control), so update the session
    // directly; the router's redirect (driven by CustomerSession, a
    // ChangeNotifier) picks it up immediately regardless of bloc state.
    session.setVerified(session.verifiedMobile ?? state.mobile);
    session.setProfile(profile);
  }

  Future<void> _onSendOtp(SendCustomerOtpEvent event, Emitter<CustomerAuthState> emit) async {
    emit(state.copyWith(
      status: CustomerAuthStatus.sendingOtp,
      mobile: event.mobile,
      errorMessage: null,
    ));
    final result = await sendOtp(mobile: event.mobile, onAutoVerified: _handleAutoVerified);
    result.fold(
      (failure) => emit(state.copyWith(
        status: CustomerAuthStatus.initial,
        errorMessage: failure.message,
      )),
      (verificationId) => emit(state.copyWith(
        status: CustomerAuthStatus.otpSent,
        verificationId: verificationId,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onResendOtp(ResendCustomerOtpEvent event, Emitter<CustomerAuthState> emit) async {
    final mobile = state.mobile;
    if (mobile == null) return;
    await _onSendOtp(SendCustomerOtpEvent(mobile), emit);
  }

  Future<void> _onVerifyOtp(VerifyCustomerOtpEvent event, Emitter<CustomerAuthState> emit) async {
    final verificationId = state.verificationId;
    final mobile = state.mobile;
    if (verificationId == null || mobile == null) return;
    emit(state.copyWith(status: CustomerAuthStatus.verifying, errorMessage: null));
    final result = await verifyOtp(
      verificationId: verificationId,
      smsCode: event.smsCode,
      mobile: mobile,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: CustomerAuthStatus.otpSent,
        errorMessage: failure.message,
      )),
      (profile) {
        session.setVerified(mobile);
        session.setProfile(profile);
        emit(state.copyWith(
          status: profile == null ? CustomerAuthStatus.needsProfile : CustomerAuthStatus.authenticated,
          customer: profile,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> _onCreateProfile(
    CreateCustomerProfileEvent event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(state.copyWith(status: CustomerAuthStatus.creatingProfile, errorMessage: null));
    final result = await createProfile(event.profile);
    result.fold(
      (failure) => emit(state.copyWith(
        status: CustomerAuthStatus.needsProfile,
        errorMessage: failure.message,
      )),
      (customer) {
        session.setProfile(customer);
        emit(state.copyWith(
          status: CustomerAuthStatus.authenticated,
          customer: customer,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> _onSignOut(SignOutCustomerEvent event, Emitter<CustomerAuthState> emit) async {
    await signOutCustomer();
    session.clear();
    emit(const CustomerAuthState());
  }
}

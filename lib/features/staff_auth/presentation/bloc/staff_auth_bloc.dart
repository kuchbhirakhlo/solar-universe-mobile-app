import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/staff_location_tracker.dart';
import '../../../../core/session/staff_session.dart';
import '../../domain/usecases/get_current_staff_usecase.dart';
import '../../domain/usecases/sign_in_staff_usecase.dart';
import '../../domain/usecases/sign_out_staff_usecase.dart';
import 'staff_auth_event.dart';
import 'staff_auth_state.dart';

class StaffAuthBloc extends Bloc<StaffAuthEvent, StaffAuthState> {
  final SignInStaffUseCase signInStaff;
  final SignOutStaffUseCase signOutStaff;
  final GetCurrentStaffUseCase getCurrentStaff;
  final StaffSession session;
  final StaffLocationTracker locationTracker;
  final void Function()? onSignedOut;

  StaffAuthBloc(
    this.signInStaff,
    this.signOutStaff,
    this.getCurrentStaff,
    this.session,
    this.locationTracker, {
    this.onSignedOut,
  }) : super(const StaffAuthState()) {
    on<RestoreStaffSessionEvent>(_onRestore);
    on<SignInStaffEvent>(_onSignIn);
    on<SignOutStaffEvent>(_onSignOut);
  }

  /// Rebuilds the in-memory StaffSession from the Firebase Auth user that the
  /// SDK persisted across app restarts, so staff stay signed in until they
  /// explicitly log out. (Attendance is a separate per-day prompt, not a login.)
  Future<void> _onRestore(RestoreStaffSessionEvent event, Emitter<StaffAuthState> emit) async {
    final staff = await getCurrentStaff();
    session.setStaff(staff);
    if (staff == null) {
      emit(state.copyWith(status: StaffAuthStatus.unauthenticated));
      return;
    }
    unawaited(locationTracker.start(staff));
    emit(state.copyWith(status: StaffAuthStatus.authenticated, staff: staff));
  }

  Future<void> _onSignIn(SignInStaffEvent event, Emitter<StaffAuthState> emit) async {
    emit(state.copyWith(status: StaffAuthStatus.authenticating));
    final result = await signInStaff(event.employeeId, event.password);
    await result.fold(
      (failure) async {
        emit(state.copyWith(
          status: StaffAuthStatus.unauthenticated,
          errorMessage: failure.message,
        ));
      },
      (staff) async {
        session.setStaff(staff);
        unawaited(locationTracker.start(staff));
        emit(state.copyWith(status: StaffAuthStatus.authenticated, staff: staff));
      },
    );
  }

  Future<void> _onSignOut(SignOutStaffEvent event, Emitter<StaffAuthState> emit) async {
    await locationTracker.clear();
    await signOutStaff();
    session.setStaff(null);
    onSignedOut?.call();
    emit(const StaffAuthState(status: StaffAuthStatus.unauthenticated));
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/session/customer_session.dart';
import '../../../../core/session/staff_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../injection.dart';
import '../../../customer_auth/domain/usecases/get_current_customer_usecase.dart';
import '../../../staff_auth/presentation/bloc/staff_auth_bloc.dart';
import '../../../staff_auth/presentation/bloc/staff_auth_event.dart';
import '../../../staff_auth/presentation/bloc/staff_auth_state.dart';
import '../../../onboarding/data/onboarding_prefs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Restored here, not via a bloc event dispatched from nowhere (that's
    // the exact dead-code gap `StaffSession`'s `RestoreStaffSessionEvent`
    // has — it's defined but never actually dispatched). By the time this
    // finishes, the router's redirect guard sees accurate
    // verified/has-profile state for any `/customer/*` deep link.
    final restore = await sl<GetCurrentCustomerUseCase>().call();
    sl<CustomerSession>()
      ..setVerified(restore.verifiedMobile)
      ..setProfile(restore.profile);

    // Staff stay signed in across restarts: Firebase Auth persists the user,
    // this rebuilds the in-memory StaffSession from it (and restarts location
    // tracking) before the router decides where to go. Failures just mean the
    // staff member sees the normal app / login screen.
    final staffBloc = sl<StaffAuthBloc>();
    try {
      staffBloc.add(const RestoreStaffSessionEvent());
      await staffBloc.stream
          .firstWhere((s) => s.status != StaffAuthStatus.unknown)
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // Timed out or errored — fall through unauthenticated.
    } finally {
      await staffBloc.close();
    }

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    if (sl<StaffSession>().isSignedIn) {
      // The router sends Engineers on to their service-requests screen.
      context.go(RouteNames.staffDashboard);
      return;
    }
    final seenOnboarding = await OnboardingPrefs.hasSeenOnboarding();
    if (!mounted) return;
    context.go(seenOnboarding ? RouteNames.home : RouteNames.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandYellow,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 260,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset('assets/images/solar_universe_logo.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.appTagline,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textHeading),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

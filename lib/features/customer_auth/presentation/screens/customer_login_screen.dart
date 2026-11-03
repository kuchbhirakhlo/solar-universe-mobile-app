import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection.dart';
import '../bloc/customer_auth_bloc.dart';
import '../bloc/customer_auth_event.dart';
import '../bloc/customer_auth_state.dart';

/// `CustomerAuthBloc` is registered as a singleton (not a factory) and this
/// uses `BlocProvider.value` (not `create`) deliberately: the login → OTP
/// flow spans two separately-routed screens (`context.push` to the OTP
/// screen, a fresh widget subtree with no inherited provider), and both
/// need to observe the *same* bloc instance to share `verificationId` /
/// pending mobile state. `.value` also means neither screen's provider
/// auto-closes the bloc on dispose — `create` would, and since the login
/// screen stays mounted (just covered) under a pushed OTP screen while both
/// hold a provider for the same instance, an auto-close from either could
/// kill it out from under the other.
class CustomerLoginScreen extends StatelessWidget {
  const CustomerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CustomerAuthBloc>(),
      child: const _CustomerLoginView(),
    );
  }
}

class _CustomerLoginView extends StatefulWidget {
  const _CustomerLoginView();

  @override
  State<_CustomerLoginView> createState() => _CustomerLoginViewState();
}

class _CustomerLoginViewState extends State<_CustomerLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CustomerAuthBloc>().add(SendCustomerOtpEvent(_mobileController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Login')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
          listener: (context, state) {
            switch (state.status) {
              case CustomerAuthStatus.otpSent:
                context.push(RouteNames.customerOtp);
                break;
              case CustomerAuthStatus.needsProfile:
                context.go(RouteNames.customerProfileSetup);
                break;
              case CustomerAuthStatus.authenticated:
                context.go(RouteNames.customerDashboard);
                break;
              default:
                break;
            }
          },
          builder: (context, state) {
            final isLoading = state.status == CustomerAuthStatus.sendingOtp;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.xxxl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'My Account',
                        style: AppTypography.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your solar installation and raise service requests.',
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              label: 'Mobile Number',
                              hint: '10-digit mobile number',
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              validator: Validators.mobile,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submit(),
                              prefixIcon: const Icon(Icons.phone_android_rounded, size: 18),
                            ),
                            if (state.errorMessage != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                state.errorMessage!,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xxl),
                            PrimaryButton(
                              label: 'SEND OTP',
                              isLoading: isLoading,
                              onPressed: _submit,
                              icon: const Icon(Icons.sms_rounded, size: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

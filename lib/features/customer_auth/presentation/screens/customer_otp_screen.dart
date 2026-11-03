import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection.dart';
import '../bloc/customer_auth_bloc.dart';
import '../bloc/customer_auth_event.dart';
import '../bloc/customer_auth_state.dart';

/// Pushed from [CustomerLoginScreen] as a separate route — go_router gives
/// it a fresh widget subtree with no inherited provider, so this wraps with
/// `BlocProvider.value` pointing at the same singleton `CustomerAuthBloc`
/// (see the comment on `CustomerLoginScreen` for why `.value`, not `create`)
/// to keep sharing the verificationId + pending mobile number that live in
/// its state.
class CustomerOtpScreen extends StatelessWidget {
  const CustomerOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CustomerAuthBloc>(),
      child: const _CustomerOtpView(),
    );
  }
}

class _CustomerOtpView extends StatefulWidget {
  const _CustomerOtpView();

  @override
  State<_CustomerOtpView> createState() => _CustomerOtpScreenState();
}

class _CustomerOtpScreenState extends State<_CustomerOtpView> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CustomerAuthBloc>().add(VerifyCustomerOtpEvent(_otpController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
          listener: (context, state) {
            switch (state.status) {
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
            final isVerifying = state.status == CustomerAuthStatus.verifying;
            final isResending = state.status == CustomerAuthStatus.sendingOtp;
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
                      Text(
                        'Enter the 6-digit code sent to',
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+91 ${state.mobile ?? ''}',
                        style: AppTypography.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              label: 'OTP',
                              hint: '6-digit code',
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submit(),
                              validator: (v) {
                                if (v == null || v.trim().length != 6) {
                                  return 'Enter the 6-digit OTP';
                                }
                                return null;
                              },
                              prefixIcon: const Icon(Icons.lock_clock_rounded, size: 18),
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
                              label: 'VERIFY & CONTINUE',
                              isLoading: isVerifying,
                              onPressed: _submit,
                              icon: const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextButton(
                              onPressed: isResending
                                  ? null
                                  : () => context
                                      .read<CustomerAuthBloc>()
                                      .add(const ResendCustomerOtpEvent()),
                              child: Text(isResending ? 'Resending...' : 'Resend OTP'),
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

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
import '../bloc/staff_auth_bloc.dart';
import '../bloc/staff_auth_event.dart';
import '../bloc/staff_auth_state.dart';

class StaffLoginScreen extends StatelessWidget {
  const StaffLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StaffAuthBloc>(),
      child: const _StaffLoginView(),
    );
  }
}

class _StaffLoginView extends StatefulWidget {
  const _StaffLoginView();

  @override
  State<_StaffLoginView> createState() => _StaffLoginViewState();
}

class _StaffLoginViewState extends State<_StaffLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<StaffAuthBloc>().add(
          SignInStaffEvent(_employeeIdController.text.trim(), _passwordController.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<StaffAuthBloc, StaffAuthState>(
          listener: (context, state) {
            // The Daily Attendance popup (Mark Present / On Leave Today) is
            // shown by StaffShell once the staff area mounts, not here.
            if (state.status == StaffAuthStatus.authenticated) {
              context.go(RouteNames.staffDashboard);
            }
          },
          builder: (context, state) {
            final isLoading = state.status == StaffAuthStatus.authenticating;
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
                            Icons.change_history_rounded,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTypography.displaySmall,
                          children: [
                            const TextSpan(text: 'Solar '),
                            TextSpan(
                              text: 'Universe',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sales Staff Portal Login',
                        style: AppTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Sales Staff Login', style: AppTypography.headlineSmall),
                            const SizedBox(height: 4),
                            Text(
                              'Enter the Employee ID and password issued to you by the '
                              'administrator.',
                              style: AppTypography.bodySmall,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            AppTextField(
                              label: 'Employee ID',
                              hint: 'e.g. TSU-FS-0001',
                              controller: _employeeIdController,
                              validator: (v) => Validators.required(v, 'Employee ID'),
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(Icons.badge_outlined, size: 18),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppTextField(
                              label: 'Password',
                              hint: '••••••••',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: (v) => Validators.required(v, 'Password'),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submit(),
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            if (state.status == StaffAuthStatus.unauthenticated &&
                                state.errorMessage != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                state.errorMessage!,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xxl),
                            PrimaryButton(
                              label: 'SIGN IN SALES PORTAL',
                              isLoading: isLoading,
                              onPressed: _submit,
                              icon: const Icon(Icons.login_rounded, size: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Center(
                        child: Text(
                          'Telecaller & Field Salesman access',
                          style: AppTypography.labelSmall,
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

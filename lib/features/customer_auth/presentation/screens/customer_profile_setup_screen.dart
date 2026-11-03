import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/session/customer_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection.dart';
import '../../domain/entities/customer_profile_options.dart';
import '../../domain/repositories/customer_auth_repository.dart';
import '../bloc/customer_auth_bloc.dart';
import '../bloc/customer_auth_event.dart';
import '../bloc/customer_auth_state.dart';

/// Matches the reference "Create Solar Customer Profile" design — minus the
/// Deployment Stage dropdown, which is admin-managed (a self-registering
/// customer doesn't get to declare their own installation status; see
/// `CustomerAuthDataSourceImpl.createProfile`, which always writes
/// `'Pending'`). Mobile is pre-filled from the just-verified phone number
/// and locked — it's already proven, no reason to let it be edited here.
class CustomerProfileSetupScreen extends StatelessWidget {
  const CustomerProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CustomerAuthBloc>(),
      child: const _CustomerProfileSetupView(),
    );
  }
}

class _CustomerProfileSetupView extends StatefulWidget {
  const _CustomerProfileSetupView();

  @override
  State<_CustomerProfileSetupView> createState() => _CustomerProfileSetupViewState();
}

class _CustomerProfileSetupViewState extends State<_CustomerProfileSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  late final _mobileController = TextEditingController(text: _mobile);
  String _systemType = CustomerProfileOptions.defaultSystemType;
  String _capacity = CustomerProfileOptions.defaultCapacity;

  String get _mobile => sl<CustomerSession>().verifiedMobile ?? '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CustomerAuthBloc>().add(
          CreateCustomerProfileEvent(
            NewCustomerProfile(
              name: _nameController.text.trim(),
              mobile: _mobile,
              email: _emailController.text.trim(),
              address: _addressController.text.trim(),
              systemType: _systemType,
              capacity: _capacity,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Your Profile')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<CustomerAuthBloc, CustomerAuthState>(
          listener: (context, state) {
            if (state.status == CustomerAuthStatus.authenticated) {
              context.go(RouteNames.customerDashboard);
            }
          },
          builder: (context, state) {
            final isLoading = state.status == CustomerAuthStatus.creatingProfile;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Create Solar Customer Profile', style: AppTypography.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      'One-time setup so we can show your installation and service history.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppTextField(
                      label: 'Mobile Number',
                      readOnly: true,
                      controller: _mobileController,
                      prefixIcon: const Icon(Icons.verified_rounded, size: 18, color: AppColors.success),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Full Name',
                      hint: 'e.g. Ramesh Joshi',
                      controller: _nameController,
                      required: true,
                      validator: Validators.name,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Email Address',
                      hint: 'e.g. ramesh.joshi@gmail.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppDropdownField<String>(
                            label: 'System Type',
                            value: _systemType,
                            items: CustomerProfileOptions.systemTypes,
                            labelBuilder: (v) => v,
                            onChanged: (v) => setState(() => _systemType = v!),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppDropdownField<String>(
                            label: 'Capacity (KW)',
                            value: _capacity,
                            items: CustomerProfileOptions.capacities,
                            labelBuilder: (v) => v,
                            onChanged: (v) => setState(() => _capacity = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Physical Address',
                      hint: 'Street details, pincode, flat...',
                      controller: _addressController,
                      required: true,
                      validator: (v) => Validators.required(v, 'Address'),
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
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
                      label: 'CREATE CUSTOMER FOLDER',
                      isLoading: isLoading,
                      onPressed: _submit,
                      icon: const Icon(Icons.folder_shared_rounded, size: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

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
import '../../domain/entities/service_request_options.dart';
import '../../domain/repositories/customer_service_requests_repository.dart';
import '../bloc/customer_service_requests_bloc.dart';
import '../bloc/customer_service_requests_event.dart';
import '../bloc/customer_service_requests_state.dart';

/// No Status or Assign Engineer fields here — both are admin-only, managed
/// from the web panel; every request created from this app always starts at
/// `ServiceRequestOptions.initialStatus` ('Open').
///
/// Pushed as its own top-level route (mirrors `CreateEnquiryScreen`/
/// `CreateCustomerScreen`'s `staffEnquiriesNew`/`staffCustomersNew` pattern)
/// — not nested under the dashboard's shell, so it needs its own provider
/// for the shared singleton bloc rather than assuming one is inherited.
class CreateServiceRequestScreen extends StatelessWidget {
  const CreateServiceRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CustomerServiceRequestsBloc>(),
      child: const _CreateServiceRequestView(),
    );
  }
}

class _CreateServiceRequestView extends StatefulWidget {
  const _CreateServiceRequestView();

  @override
  State<_CreateServiceRequestView> createState() => _CreateServiceRequestScreenState();
}

class _CreateServiceRequestScreenState extends State<_CreateServiceRequestView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _remarkController = TextEditingController();
  String _serviceType = ServiceRequestOptions.defaultType;

  @override
  void dispose() {
    _descriptionController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final customer = sl<CustomerSession>().profile;
    if (customer == null) return;
    context.read<CustomerServiceRequestsBloc>().add(
          SubmitServiceRequestEvent(
            NewServiceRequest(
              customerId: customer.id,
              customerName: customer.name,
              customerMobile: customer.mobile,
              serviceType: _serviceType,
              description: _descriptionController.text.trim(),
              remark: _remarkController.text.trim(),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Service Request')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<CustomerServiceRequestsBloc, CustomerServiceRequestsState>(
          listener: (context, state) {
            if (state.submitStatus == SubmitStatus.submitted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service request created successfully.')),
              );
              // This bloc is a singleton (see its class doc comment) — reset
              // submitStatus so re-opening this screen later doesn't see a
              // stale 'submitted' status and pop itself again immediately.
              // Dispatched via the GetIt instance directly, not
              // context.read — safer to call before navigating away, since
              // nothing here depends on this context still being mounted.
              sl<CustomerServiceRequestsBloc>().add(
                const ResetServiceRequestSubmitStatusEvent(),
              );
              // Explicit context.go() to the exact route, not context.pop()
              // — this route can be reached from more than one place (the
              // dashboard, potentially deep-linked directly), and popping
              // depends on whatever happens to be underneath on the
              // navigation stack at the time, which was landing on the
              // wrong screen. go() guarantees exactly where this lands
              // regardless of stack history, and it also forces a fresh
              // CustomerDashboardScreen build so the new request's
              // LoadMyServiceRequestsEvent fires immediately. Done last —
              // this deactivates the context, so nothing after this line
              // can safely use it.
              context.go(RouteNames.customerDashboard);
            } else if (state.submitStatus == SubmitStatus.error &&
                state.submitError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.submitError!)),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state.submitStatus == SubmitStatus.submitting;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Create New Service Request', style: AppTypography.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      'Tell us what you need help with — our team will review and get in touch.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppDropdownField<String>(
                      label: 'Service Type',
                      value: _serviceType,
                      items: ServiceRequestOptions.types,
                      labelBuilder: (v) => v,
                      onChanged: (v) => setState(() => _serviceType = v!),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Description',
                      hint: 'Describe the service required...',
                      controller: _descriptionController,
                      required: true,
                      validator: (v) => Validators.required(v, 'Description'),
                      maxLines: 4,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Remark',
                      hint: 'Add any remarks or notes about this request...',
                      controller: _remarkController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      label: 'CREATE SERVICE REQUEST',
                      isLoading: isSubmitting,
                      onPressed: _submit,
                      icon: const Icon(Icons.build_rounded, size: 18, color: Colors.white),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/launcher_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection.dart';
import '../../domain/entities/enquiry_entity.dart';
import '../../domain/entities/enquiry_options.dart';
import '../bloc/enquiry_bloc.dart';
import '../bloc/enquiry_event.dart';
import '../bloc/enquiry_state.dart';

Future<void> showEnquiryFormSheet(
  BuildContext context, {
  required String source,
  String? initialSystemType,
  String? initialCapacity,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => sl<EnquiryBloc>(),
      child: EnquiryFormSheet(
        source: source,
        initialSystemType: initialSystemType,
        initialCapacity: initialCapacity,
      ),
    ),
  );
}

class EnquiryFormSheet extends StatefulWidget {
  final String source;
  final String? initialSystemType;
  final String? initialCapacity;

  const EnquiryFormSheet({
    super.key,
    required this.source,
    this.initialSystemType,
    this.initialCapacity,
  });

  @override
  State<EnquiryFormSheet> createState() => _EnquiryFormSheetState();
}

class _EnquiryFormSheetState extends State<EnquiryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _cityController = TextEditingController();
  final _messageController = TextEditingController();

  late String _systemType;
  late String _capacity;

  @override
  void initState() {
    super.initState();
    // Fall back to the default whenever the caller passes a value that isn't
    // one of the fixed dropdown options (e.g. a solution title or a package
    // capacity string that doesn't exactly match) — DropdownButtonFormField
    // requires the value to be present in its items.
    _systemType = EnquiryOptions.systemTypes.contains(widget.initialSystemType)
        ? widget.initialSystemType!
        : EnquiryOptions.defaultSystemType;
    _capacity = EnquiryOptions.capacities.contains(widget.initialCapacity)
        ? widget.initialCapacity!
        : EnquiryOptions.defaultCapacity;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _cityController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<EnquiryBloc>().add(
          SubmitEnquiryEvent(
            EnquiryEntity(
              name: _nameController.text.trim(),
              mobile: _mobileController.text.trim(),
              city: _cityController.text.trim(),
              systemType: _systemType,
              capacity: _capacity,
              message: _messageController.text.trim(),
              source: widget.source,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            clipBehavior: Clip.antiAlias,
            child: BlocConsumer<EnquiryBloc, EnquiryState>(
              listener: (context, state) {
                if (state.enquiryStatus == SubmitStatus.success) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.enquirySuccessMessage)),
                  );
                }
              },
              builder: (context, state) {
                final isSubmitting = state.enquiryStatus == SubmitStatus.submitting;
                return Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      _buildHeader(context),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pageHorizontal,
                          AppSpacing.lg,
                          AppSpacing.pageHorizontal,
                          AppSpacing.xxl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.enquiryTitle, style: AppTypography.headlineLarge),
                            const SizedBox(height: AppSpacing.sm),
                            Text(AppStrings.enquirySubtitle, style: AppTypography.bodyMedium),
                            const SizedBox(height: AppSpacing.xxl),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Name',
                                    required: true,
                                    hint: 'e.g. Ramesh Deshmukh',
                                    controller: _nameController,
                                    validator: Validators.name,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: AppTextField(
                                    label: 'Mobile',
                                    required: true,
                                    hint: '10-digit mobile',
                                    controller: _mobileController,
                                    validator: Validators.mobile,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppTextField(
                              label: 'City',
                              required: true,
                              hint: 'e.g. Pune',
                              controller: _cityController,
                              validator: Validators.city,
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
                                    items: EnquiryOptions.systemTypes,
                                    labelBuilder: (v) => v,
                                    onChanged: (v) => setState(() => _systemType = v!),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: AppDropdownField<String>(
                                    label: 'Capacity',
                                    value: _capacity,
                                    items: EnquiryOptions.capacities,
                                    labelBuilder: (v) => v,
                                    onChanged: (v) => setState(() => _capacity = v!),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppTextField(
                              label: 'Message / Special Requests',
                              hint: 'Describe specific energy parameters or query...',
                              controller: _messageController,
                              maxLines: 3,
                              textInputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            if (state.enquiryStatus == SubmitStatus.failure) ...[
                              _buildErrorBanner(state.enquiryError ?? AppStrings.errorUnknown),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                            PrimaryButton(
                              label: AppStrings.enquirySubmitLabel,
                              isLoading: isSubmitting,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
          ),
          TextButton(
            onPressed: () => LauncherHelper.call(AppStrings.primaryContactNumber),
            child: const Text('Call us'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: Colors.white, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppStrings.enquiryOfferBadge,
              style: AppTypography.labelLarge.copyWith(color: Colors.white),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

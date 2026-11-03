import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/session/staff_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/staged_file.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/file_upload_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection.dart';
import '../../../enquiry/domain/entities/enquiry_options.dart';
import '../../domain/repositories/staff_enquiries_repository.dart';
import '../bloc/staff_enquiries_bloc.dart';
import '../bloc/staff_enquiries_event.dart';
import '../bloc/staff_enquiries_state.dart';

// Discrete 1-10KW capacities for staff-entered enquiries — kept local to this
// screen (not EnquiryOptions.capacities) since that list is shared with the
// public lead form / solutions screen, which intentionally uses broader
// buckets ("Above 5KW") for a general audience.
const List<String> _staffCapacities = [
  '1KW', '2KW', '3KW', '4KW', '5KW', '6KW', '7KW', '8KW', '9KW', '10KW',
];

class CreateEnquiryScreen extends StatelessWidget {
  const CreateEnquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<StaffEnquiriesBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Create New Enquiry')),
        backgroundColor: AppColors.background,
        body: const _CreateEnquiryForm(),
      ),
    );
  }
}

class _CreateEnquiryForm extends StatefulWidget {
  const _CreateEnquiryForm();

  @override
  State<_CreateEnquiryForm> createState() => _CreateEnquiryFormState();
}

class _CreateEnquiryFormState extends State<_CreateEnquiryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _messageController = TextEditingController();

  // No longer user-selectable (the Telecaller/Field Salesman channel cards
  // were removed per feedback) — instead pulled straight from the signed-in
  // staff member's own `role` field (staff/{uid}.role in Firestore), which
  // is the real CRM's source of truth for this — e.g. "Field Sales",
  // "Tally Sales", "Manager", "Office coordinator", not a fixed guess.
  String get _salesType => sl<StaffSession>().current?.role ?? 'Field Sales';
  String _systemType = EnquiryOptions.defaultSystemType;
  String _capacity = _staffCapacities.first;
  DateTime _enquiryDateTime = DateTime.now();
  List<StagedFile> _sitePhoto = [];
  bool _submitAttempted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _enquiryDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_enquiryDateTime),
    );
    if (time == null) return;
    setState(() {
      _enquiryDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _submit() {
    setState(() => _submitAttempted = true);
    if (!_formKey.currentState!.validate()) return;
    if (AppConfig.storageUploadsEnabled && _sitePhoto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A site photo is required before submitting this enquiry.')),
      );
      return;
    }
    context.read<StaffEnquiriesBloc>().add(
          SubmitStaffEnquiryEvent(
            NewStaffEnquiry(
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              city: _cityController.text.trim(),
              solarType: _systemType,
              capacity: _capacity,
              message: _messageController.text.trim(),
              salesType: _salesType,
              enquiryDateTime: _enquiryDateTime,
              sitePhoto: _sitePhoto.isEmpty ? null : _sitePhoto.first,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffEnquiriesBloc, StaffEnquiriesState>(
      listener: (context, state) {
        if (state.submitStatus == SubmitStatus.success) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enquiry created successfully.')),
          );
          context.read<StaffEnquiriesBloc>().add(const ResetSubmitStatusEvent());
        } else if (state.submitStatus == SubmitStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.submitError ?? 'Failed to create enquiry.')),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state.submitStatus == SubmitStatus.submitting;
        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            children: [
              Text(
                'Record the customer\'s solar requirement.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppTextField(
                label: 'Customer Name',
                required: true,
                hint: 'e.g. Ramesh Deshmukh',
                controller: _nameController,
                validator: Validators.name,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Phone Number',
                required: true,
                hint: '10-digit mobile',
                controller: _phoneController,
                validator: Validators.mobile,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'City',
                required: true,
                hint: 'e.g. Pune',
                controller: _cityController,
                validator: Validators.city,
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
                      items: _staffCapacities,
                      labelBuilder: (v) => v,
                      onChanged: (v) => setState(() => _capacity = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('ENQUIRY DATE & TIME', style: AppTypography.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        DateFormat('dd MMM yyyy · hh:mm a').format(_enquiryDateTime),
                        style: AppTypography.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Message / Notes',
                hint: 'Requirement details, follow-up notes, site conditions...',
                controller: _messageController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.lg),
              PhotoUploadField(
                label: AppConfig.storageUploadsEnabled ? 'Site Photo' : 'Site Photo (optional)',
                required: AppConfig.storageUploadsEnabled,
                cameraOnly: true,
                files: _sitePhoto,
                onChanged: (f) => setState(() => _sitePhoto = f),
                errorText: AppConfig.storageUploadsEnabled && _submitAttempted && _sitePhoto.isEmpty
                    ? 'A site photo is required to submit this enquiry'
                    : null,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: 'CREATE ENQUIRY',
                isLoading: isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}

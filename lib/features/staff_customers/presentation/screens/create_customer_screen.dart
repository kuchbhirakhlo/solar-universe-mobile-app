import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/staged_file.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/file_upload_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../injection.dart';
import '../../../enquiry/domain/entities/enquiry_options.dart';
import '../../domain/repositories/staff_customers_repository.dart';
import '../bloc/staff_customers_bloc.dart';
import '../bloc/staff_customers_event.dart';
import '../bloc/staff_customers_state.dart';

// Discrete 1-10KW capacities for staff-entered customers — kept local to this
// screen (not EnquiryOptions.capacities) since that list is shared with the
// public lead form / solutions screen, which intentionally uses broader
// buckets ("Above 5KW") for a general audience. Mirrors create_enquiry_screen.dart.
const List<String> _staffCapacities = [
  '1KW', '2KW', '3KW', '4KW', '5KW', '6KW', '7KW', '8KW', '9KW', '10KW',
];

class CreateCustomerScreen extends StatelessWidget {
  const CreateCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<StaffCustomersBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Register Solar Customer')),
        backgroundColor: AppColors.background,
        body: const _CreateCustomerForm(),
      ),
    );
  }
}

/// Tracks one document field's local preview list alongside which of those
/// files have actually finished uploading to Storage. Each file uploads as
/// soon as it's picked (see [_CreateCustomerFormState._uploadNew]) rather
/// than waiting for the Register button — Register only ever writes the
/// customer's metadata, which is fast, instead of every document at once.
class _DocState {
  List<StagedFile> staged = [];
  final Set<String> uploadedPaths = {};
  bool uploading = false;
  String? error;

  bool get isSatisfied =>
      staged.isNotEmpty && staged.every((f) => uploadedPaths.contains(f.path));
}

class _CreateCustomerForm extends StatefulWidget {
  const _CreateCustomerForm();

  @override
  State<_CreateCustomerForm> createState() => _CreateCustomerFormState();
}

class _CreateCustomerFormState extends State<_CreateCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  String _systemType = EnquiryOptions.defaultSystemType;
  String _capacity = _staffCapacities.first;

  // Reserved once, up front, so every document can upload to its final path
  // as soon as it's picked — well before the customer doc formally exists.
  late final String _customerId = sl<StaffCustomersRepository>().reserveCustomerId();

  final _pan = _DocState();
  final _aadhaarFront = _DocState();
  final _aadhaarBack = _DocState();
  final _electricityBill = _DocState();
  final _bankProof = _DocState();
  final _rooftopPhotos = _DocState();
  final _propertyDocuments = _DocState();

  bool _submitAttempted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Called whenever a field's staged list changes — uploads whichever
  /// staged files haven't been uploaded yet (newly picked ones), leaving
  /// already-uploaded ones alone. Runs per-field uploads sequentially, but
  /// different fields upload concurrently with each other.
  Future<void> _onFieldChanged(
    _DocState state,
    String docType,
    List<StagedFile> files, {
    required bool multi,
  }) async {
    setState(() {
      state.staged = files;
      state.error = null;
    });
    final newOnes = files.where((f) => !state.uploadedPaths.contains(f.path)).toList();
    if (newOnes.isEmpty) return;

    setState(() => state.uploading = true);
    for (final file in newOnes) {
      final result = await sl<StaffCustomersRepository>().uploadDocument(
        customerId: _customerId,
        docType: docType,
        filePath: file.path,
        multi: multi,
      );
      if (!mounted) return;
      result.fold(
        (failure) => setState(() => state.error = failure.message),
        (_) => setState(() => state.uploadedPaths.add(file.path)),
      );
    }
    if (mounted) setState(() => state.uploading = false);
  }

  bool get _anyUploading => [
        _pan,
        _aadhaarFront,
        _aadhaarBack,
        _electricityBill,
        _bankProof,
        _rooftopPhotos,
        _propertyDocuments,
      ].any((s) => s.uploading);

  String? _err(_DocState state, String label) {
    // Storage isn't enabled yet — documents are optional until then (see
    // AppConfig.storageUploadsEnabled), so never block on them here.
    if (!AppConfig.storageUploadsEnabled) return null;
    if (!_submitAttempted) return null;
    if (state.staged.isEmpty) return '$label is required';
    if (state.error != null) return '$label failed to upload — try again';
    if (!state.isSatisfied) return '$label is still uploading';
    return null;
  }

  void _submit() {
    setState(() => _submitAttempted = true);
    if (!_formKey.currentState!.validate()) return;
    if (AppConfig.storageUploadsEnabled) {
      final allDocs = [
        _pan,
        _aadhaarFront,
        _aadhaarBack,
        _electricityBill,
        _bankProof,
        _rooftopPhotos,
        _propertyDocuments,
      ];
      if (allDocs.any((s) => !s.isSatisfied)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please attach all required documents and wait for uploads to finish.'),
          ),
        );
        return;
      }
    }
    context.read<StaffCustomersBloc>().add(
          SubmitStaffCustomerEvent(
            NewStaffCustomer(
              name: _nameController.text.trim(),
              mobile: _mobileController.text.trim(),
              email: _emailController.text.trim(),
              address: _addressController.text.trim(),
              systemType: _systemType,
              capacity: _capacity,
            ),
            customerId: _customerId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StaffCustomersBloc, StaffCustomersState>(
      listener: (context, state) {
        if (state.submitStatus == SubmitStatus.success) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer registered successfully.')),
          );
          context.read<StaffCustomersBloc>().add(const ResetCustomerSubmitStatusEvent());
        } else if (state.submitStatus == SubmitStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.submitError ?? 'Failed to register customer.')),
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
              AppTextField(
                label: 'Customer Name',
                required: true,
                hint: 'e.g. Ramesh Deshmukh',
                controller: _nameController,
                validator: Validators.name,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Mobile Number',
                required: true,
                hint: '10-digit mobile',
                controller: _mobileController,
                validator: Validators.mobile,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Email Address',
                hint: 'you@example.com (optional)',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Address',
                required: true,
                hint: 'Full installation address',
                controller: _addressController,
                validator: (v) => Validators.required(v, 'Address'),
                maxLines: 2,
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
              const SizedBox(height: AppSpacing.xxl),
              SectionHeader(
                title: AppConfig.storageUploadsEnabled ? 'Required Documents' : 'Documents (optional)',
              ),
              Text(
                AppConfig.storageUploadsEnabled
                    ? 'All documents below are mandatory — each one uploads as soon as you attach it.'
                    : 'Document uploads are temporarily disabled — you can register the customer without them.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              _docField(
                label: 'PAN Card',
                docType: 'pan',
                state: _pan,
              ),
              const SizedBox(height: AppSpacing.lg),
              _docField(
                label: 'Aadhaar Card — Front',
                docType: 'aadhaarFront',
                state: _aadhaarFront,
              ),
              const SizedBox(height: AppSpacing.lg),
              _docField(
                label: 'Aadhaar Card — Back',
                docType: 'aadhaarBack',
                state: _aadhaarBack,
              ),
              const SizedBox(height: AppSpacing.lg),
              _docField(
                label: 'Electricity Bill',
                docType: 'electricityBill',
                state: _electricityBill,
              ),
              const SizedBox(height: AppSpacing.lg),
              _docField(
                label: 'Cancelled Cheque OR Bank Passbook Front Page',
                docType: 'bankProof',
                state: _bankProof,
              ),
              const SizedBox(height: AppSpacing.lg),
              _photoField(
                label: 'Rooftop Feasibility Photos',
                docType: 'rooftop',
                state: _rooftopPhotos,
              ),
              const SizedBox(height: AppSpacing.lg),
              _docField(
                label: 'Property Documents (House Tax / Registry / Khatauni / Other)',
                docType: 'property',
                state: _propertyDocuments,
                allowMultiple: true,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: isSubmitting
                    ? 'REGISTERING...'
                    : _anyUploading
                        ? 'UPLOADING...'
                        : 'REGISTER CUSTOMER',
                isLoading: isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        );
      },
    );
  }

  Widget _docField({
    required String label,
    required String docType,
    required _DocState state,
    bool allowMultiple = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DocumentUploadField(
          label: label,
          required: true,
          allowMultiple: allowMultiple,
          files: state.staged,
          onChanged: (f) => _onFieldChanged(state, docType, f, multi: allowMultiple),
          errorText: _err(state, label),
        ),
        _uploadStatusLine(state),
      ],
    );
  }

  Widget _photoField({
    required String label,
    required String docType,
    required _DocState state,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PhotoUploadField(
          label: label,
          required: true,
          allowMultiple: true,
          files: state.staged,
          onChanged: (f) => _onFieldChanged(state, docType, f, multi: true),
          errorText: _err(state, label),
        ),
        _uploadStatusLine(state),
      ],
    );
  }

  Widget _uploadStatusLine(_DocState state) {
    if (state.uploading) {
      return const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
            SizedBox(width: AppSpacing.xs),
            Text('Uploading...', style: TextStyle(fontSize: 11, color: AppColors.primary)),
          ],
        ),
      );
    }
    if (state.staged.isNotEmpty && state.isSatisfied) {
      return const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, size: 12, color: AppColors.success),
            SizedBox(width: AppSpacing.xs),
            Text('Uploaded', style: TextStyle(fontSize: 11, color: AppColors.success)),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

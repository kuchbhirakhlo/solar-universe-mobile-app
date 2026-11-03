import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/file_pick_helper.dart';
import '../../../../core/widgets/loader.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection.dart';
import '../../domain/entities/customer_documents_entity.dart';
import '../../domain/entities/staff_customer_entity.dart';
import '../bloc/staff_customers_bloc.dart';
import '../bloc/staff_customers_event.dart';
import '../bloc/staff_customers_state.dart';

class StaffCustomersScreen extends StatelessWidget {
  const StaffCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<StaffCustomersBloc>()..add(const LoadStaffCustomersEvent()),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solar Customer Profiles', style: AppTypography.headlineLarge),
                      Text(
                        'Maintain customer folders, installation stages, and KYC files.',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: '+ Add Solar Customer',
              onPressed: () => context.push(RouteNames.staffCustomersNew),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: BlocBuilder<StaffCustomersBloc, StaffCustomersState>(
                builder: (context, state) {
                  if (state.listStatus == ListStatus.loading ||
                      state.listStatus == ListStatus.initial) {
                    return const Loader();
                  }
                  if (state.listStatus == ListStatus.failure) {
                    return Center(child: Text(state.listError ?? 'Unable to load customers.'));
                  }
                  if (state.customers.isEmpty) {
                    return const Center(child: Text('No solar customers registered yet.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        context.read<StaffCustomersBloc>().add(const LoadStaffCustomersEvent()),
                    child: ListView.separated(
                      itemCount: state.customers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) => _CustomerCard(customer: state.customers[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final StaffCustomerEntity customer;

  const _CustomerCard({required this.customer});

  Color _statusColor(String s) {
    switch (s) {
      case 'Completed':
        return AppColors.success;
      case 'In Progress':
        return AppColors.info;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.mdAll,
      onTap: () => _openCustomerSheet(context, customer),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name, style: AppTypography.titleLarge),
                  Text(customer.mobile, style: AppTypography.bodySmall),
                  Text('${customer.systemType} · ${customer.capacity}', style: AppTypography.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(customer.installationStatus).withOpacity(0.12),
                borderRadius: AppRadius.fullAll,
              ),
              child: Text(
                customer.installationStatus,
                style: AppTypography.labelSmall.copyWith(color: _statusColor(customer.installationStatus)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _singleDocTypes = [
  ('pan', 'PAN Card'),
  ('aadhaarFront', 'Aadhaar Card — Front'),
  ('aadhaarBack', 'Aadhaar Card — Back'),
  ('electricityBill', 'Electricity Bill'),
  ('bankProof', 'Cancelled Cheque / Bank Passbook'),
];

void _openCustomerSheet(BuildContext context, StaffCustomerEntity customer) {
  final bloc = context.read<StaffCustomersBloc>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => BlocProvider.value(
      value: bloc,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return BlocBuilder<StaffCustomersBloc, StaffCustomersState>(
            builder: (context, state) {
              final current = state.customers.firstWhere(
                (c) => c.id == customer.id,
                orElse: () => customer,
              );
              final docs = current.documents;
              final isUploading = state.uploadStatus == SubmitStatus.submitting;
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                children: [
                  Text(current.name, style: AppTypography.headlineMedium),
                  Text(current.address, style: AppTypography.bodySmall),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    children: [
                      Text('KYC Documents', style: AppTypography.titleLarge),
                      const SizedBox(width: AppSpacing.sm),
                      if (!docs.isComplete)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.warningContainer,
                            borderRadius: AppRadius.fullAll,
                          ),
                          child: Text(
                            'Incomplete',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.warning),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final (key, label) in _singleDocTypes)
                    _DocumentRow(
                      customerId: current.id,
                      docType: key,
                      label: label,
                      uploadedUrl: _fieldFor(docs, key),
                      isUploading: isUploading,
                    ),
                  _MultiDocumentRow(
                    customerId: current.id,
                    docType: 'rooftopPhotos',
                    label: 'Rooftop Feasibility Photos',
                    urls: docs.rooftopPhotos,
                    isUploading: isUploading,
                    isPhoto: true,
                  ),
                  _MultiDocumentRow(
                    customerId: current.id,
                    docType: 'propertyDocuments',
                    label: 'Property Documents',
                    urls: docs.propertyDocuments,
                    isUploading: isUploading,
                    isPhoto: false,
                  ),
                ],
              );
            },
          );
        },
      ),
    ),
  );
}

String? _fieldFor(CustomerDocumentsEntity docs, String key) {
  switch (key) {
    case 'pan':
      return docs.pan;
    case 'aadhaarFront':
      return docs.aadhaarFront;
    case 'aadhaarBack':
      return docs.aadhaarBack;
    case 'electricityBill':
      return docs.electricityBill;
    case 'bankProof':
      return docs.bankProof;
    default:
      return null;
  }
}

class _DocumentRow extends StatelessWidget {
  final String customerId;
  final String docType;
  final String label;
  final String? uploadedUrl;
  final bool isUploading;

  const _DocumentRow({
    required this.customerId,
    required this.docType,
    required this.label,
    required this.uploadedUrl,
    required this.isUploading,
  });

  Future<void> _pickAndUpload(BuildContext context) async {
    final result = await FilePickHelper.pickDocuments(allowMultiple: false);
    if (result.files.isEmpty || !context.mounted) return;
    context.read<StaffCustomersBloc>().add(
          UploadCustomerDocumentEvent(
            customerId: customerId,
            docType: docType,
            filePath: result.files.first.path,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final uploaded = uploadedUrl != null && uploadedUrl!.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            uploaded ? Icons.check_circle_rounded : Icons.upload_file_rounded,
            color: uploaded ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppTypography.titleMedium)),
          TextButton(
            onPressed: isUploading ? null : () => _pickAndUpload(context),
            child: Text(uploaded ? 'Replace' : 'Upload'),
          ),
        ],
      ),
    );
  }
}

class _MultiDocumentRow extends StatelessWidget {
  final String customerId;
  final String docType;
  final String label;
  final List<String> urls;
  final bool isUploading;
  final bool isPhoto;

  const _MultiDocumentRow({
    required this.customerId,
    required this.docType,
    required this.label,
    required this.urls,
    required this.isUploading,
    required this.isPhoto,
  });

  Future<void> _pickAndUpload(BuildContext context) async {
    final result = isPhoto
        ? await FilePickHelper.pickImages(allowMultiple: false, source: ImageSource.camera)
        : await FilePickHelper.pickDocuments(allowMultiple: false);
    if (result.files.isEmpty || !context.mounted) return;
    context.read<StaffCustomersBloc>().add(
          UploadCustomerDocumentEvent(
            customerId: customerId,
            docType: docType,
            filePath: result.files.first.path,
            multi: true,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final uploaded = urls.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            uploaded ? Icons.check_circle_rounded : Icons.upload_file_rounded,
            color: uploaded ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.titleMedium),
                if (uploaded) Text('${urls.length} file(s)', style: AppTypography.bodySmall),
              ],
            ),
          ),
          TextButton(
            onPressed: isUploading ? null : () => _pickAndUpload(context),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

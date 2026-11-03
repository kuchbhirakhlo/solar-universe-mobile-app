import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/session/staff_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/staged_file.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/file_upload_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection.dart';
import '../../../customer_service_requests/domain/entities/service_request_entity.dart';
import '../../../customer_service_requests/presentation/widgets/service_request_status_badge.dart';
import '../bloc/staff_service_requests_bloc.dart';
import '../bloc/staff_service_requests_event.dart';
import '../bloc/staff_service_requests_state.dart';

// The 3 real statuses seen live (Open at creation, In Progress / Completed
// in the admin panel's table) plus Cancelled as a defensive option — an
// engineer picks from this fixed list rather than typing a status string
// freehand, so it can never drift from what ServiceRequestStatusBadge knows
// how to color.
const _statusOptions = ['Open', 'In Progress', 'Completed', 'Cancelled'];

/// Pushed with the tapped `ServiceRequestEntity` as `extra` (see
/// `staff_service_requests_screen.dart`). Wrapped in its own
/// `BlocProvider.value` for the same reason every other pushed screen in
/// this app sharing a singleton bloc is — a fresh route subtree has no
/// inherited provider.
class ServiceRequestDetailScreen extends StatelessWidget {
  final ServiceRequestEntity request;
  const ServiceRequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<StaffServiceRequestsBloc>(),
      child: _ServiceRequestDetailView(initialRequest: request),
    );
  }
}

class _ServiceRequestDetailView extends StatefulWidget {
  final ServiceRequestEntity initialRequest;
  const _ServiceRequestDetailView({required this.initialRequest});

  @override
  State<_ServiceRequestDetailView> createState() => _ServiceRequestDetailViewState();
}

class _ServiceRequestDetailViewState extends State<_ServiceRequestDetailView> {
  late String _status = widget.initialRequest.status;
  late final _remarkController = TextEditingController(text: widget.initialRequest.remark);
  List<StagedFile> _pendingPhotos = [];

  String get _engineerId => sl<StaffSession>().current?.id ?? '';
  String get _employeeId => sl<StaffSession>().current?.employeeId ?? '';

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  void _save() {
    context.read<StaffServiceRequestsBloc>().add(
          UpdateAssignedServiceRequestEvent(
            requestId: widget.initialRequest.id,
            status: _status,
            remark: _remarkController.text.trim(),
            engineerId: _engineerId,
            employeeId: _employeeId,
          ),
        );
  }

  void _onPhotosChanged(List<StagedFile> files) {
    final newOnes = files.where((f) => !_pendingPhotos.any((p) => p.path == f.path));
    setState(() => _pendingPhotos = files);
    for (final file in newOnes) {
      context.read<StaffServiceRequestsBloc>().add(
            UploadInstallationPhotoEvent(
              requestId: widget.initialRequest.id,
              filePath: file.path,
              engineerId: _engineerId,
              employeeId: _employeeId,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Request')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<StaffServiceRequestsBloc, StaffServiceRequestsState>(
          listener: (context, state) {
            if (state.actionStatus == ActionStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Updated successfully.')),
              );
              context.read<StaffServiceRequestsBloc>().add(
                    const ResetServiceRequestActionStatusEvent(),
                  );
            } else if (state.actionStatus == ActionStatus.error && state.actionError != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.actionError!)));
            }
          },
          builder: (context, state) {
            // Freshest copy once the list has reloaded (picks up newly
            // uploaded photo URLs); falls back to what was tapped from the
            // list before that first reload completes.
            final current = state.byId(widget.initialRequest.id) ?? widget.initialRequest;
            final isWorking = state.actionStatus == ActionStatus.working;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(current.customerName, style: AppTypography.titleLarge),
                          ),
                          ServiceRequestStatusBadge(status: current.status),
                        ],
                      ),
                      Text('+91 ${current.customerMobile}', style: AppTypography.bodySmall),
                      const SizedBox(height: AppSpacing.sm),
                      Text(current.serviceType, style: AppTypography.titleMedium),
                      const SizedBox(height: 2),
                      Text(current.description, style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('Update Status', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                AppDropdownField<String>(
                  label: 'Status',
                  value: _status,
                  items: _statusOptions,
                  labelBuilder: (v) => v,
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Remark',
                  hint: 'Notes about this visit...',
                  controller: _remarkController,
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('Installation Photos', style: AppTypography.headlineSmall),
                const SizedBox(height: 4),
                if (!AppConfig.storageUploadsEnabled)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      'Photo storage isn\'t enabled yet — photos can be picked but won\'t upload '
                      'until it is.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
                    ),
                  ),
                PhotoUploadField(
                  label: 'Upload Photos',
                  allowMultiple: true,
                  files: _pendingPhotos,
                  onChanged: _onPhotosChanged,
                ),
                if (current.installationPhotos.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text('${current.installationPhotos.length} photo(s) uploaded', style: AppTypography.labelMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: current.installationPhotos
                        .map((url) => ClipRRect(
                              borderRadius: AppRadius.smAll,
                              child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(
                  label: 'SAVE UPDATE',
                  isLoading: isWorking,
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded, size: 18, color: Colors.white),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

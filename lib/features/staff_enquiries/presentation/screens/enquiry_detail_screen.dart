import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/launcher_helper.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection.dart';
import '../../domain/enquiry_stages.dart';
import '../../domain/entities/staff_enquiry_entity.dart';
import '../bloc/staff_enquiries_bloc.dart';
import '../bloc/staff_enquiries_event.dart';
import '../bloc/staff_enquiries_state.dart';
import '../widgets/enquiry_stage_badge.dart';

/// Update an enquiry's stage with a required remark and see its history —
/// the mobile version of the CRM sales portal's status modal.
class EnquiryDetailScreen extends StatelessWidget {
  final StaffEnquiryEntity enquiry;

  const EnquiryDetailScreen({super.key, required this.enquiry});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<StaffEnquiriesBloc>(),
      child: _EnquiryDetailView(initial: enquiry),
    );
  }
}

class _EnquiryDetailView extends StatefulWidget {
  final StaffEnquiryEntity initial;

  const _EnquiryDetailView({required this.initial});

  @override
  State<_EnquiryDetailView> createState() => _EnquiryDetailViewState();
}

class _EnquiryDetailViewState extends State<_EnquiryDetailView> {
  final _formKey = GlobalKey<FormState>();
  final _remarkController = TextEditingController();
  late String _status = EnquiryStages.normalize(widget.initial.status);

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  /// Sales staff can't set "Converted" (admin-only in the CRM), but an
  /// enquiry that is already Converted or has a legacy stage like "New" must
  /// still be a valid dropdown value, so the current stage is kept in the list.
  List<String> _options(String current) {
    final base = [...EnquiryStages.staffSelectable];
    final normalized = EnquiryStages.normalize(current);
    if (!base.contains(normalized)) base.insert(0, normalized);
    return base;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<StaffEnquiriesBloc>().add(
          UpdateEnquiryStatusEvent(
            enquiryId: widget.initial.id,
            status: _status,
            remark: _remarkController.text.trim(),
          ),
        );
  }

  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return DateFormat('d MMM yyyy, h:mm a').format(d.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enquiry')),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<StaffEnquiriesBloc, StaffEnquiriesState>(
          listener: (context, state) {
            if (state.actionStatus == EnquiryActionStatus.success) {
              _remarkController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enquiry updated.')),
              );
              context.read<StaffEnquiriesBloc>().add(const ResetEnquiryActionEvent());
            } else if (state.actionStatus == EnquiryActionStatus.error &&
                state.actionError != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.actionError!)));
              context.read<StaffEnquiriesBloc>().add(const ResetEnquiryActionEvent());
            }
          },
          builder: (context, state) {
            final current = state.byId(widget.initial.id) ?? widget.initial;
            final working = state.actionStatus == EnquiryActionStatus.working;
            final history = current.statusHistory.reversed.toList();
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(current.name, style: AppTypography.titleLarge)),
                          EnquiryStageBadge(status: current.status),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      InkWell(
                        onTap: () => LauncherHelper.call(current.phone),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.call_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                current.phone,
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textTertiary),
                          const SizedBox(width: 6),
                          Text(current.city, style: AppTypography.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        [current.solarType, current.capacity, current.salesType]
                            .where((e) => e.isNotEmpty)
                            .join('  ·  '),
                        style: AppTypography.labelMedium,
                      ),
                      if (current.message.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(current.message, style: AppTypography.bodySmall),
                      ],
                      if (current.createdByStaffName != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text('Logged by ${current.createdByStaffName}', style: AppTypography.labelSmall),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('Update Stage', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppDropdownField<String>(
                        label: 'Stage',
                        value: _status,
                        items: _options(current.status),
                        labelBuilder: (v) => v,
                        onChanged: (v) => setState(() => _status = v ?? _status),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: 'New Remark',
                        required: true,
                        hint: 'What happened? e.g. called customer, paper received...',
                        controller: _remarkController,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter a remark for this status update.'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'SAVE UPDATE',
                  isLoading: working,
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded, size: 18, color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('History', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                if (history.isEmpty)
                  Text('No updates recorded yet.', style: AppTypography.bodySmall)
                else
                  for (final h in history)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: AppRadius.smAll,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              EnquiryStageBadge(status: h.status),
                              const Spacer(),
                              Text(_formatDate(h.updatedAt), style: AppTypography.labelSmall),
                            ],
                          ),
                          if (h.remark.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(h.remark, style: AppTypography.bodyMedium),
                          ],
                          if (h.updatedBy.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('By: ${h.updatedBy}', style: AppTypography.labelSmall),
                          ],
                        ],
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

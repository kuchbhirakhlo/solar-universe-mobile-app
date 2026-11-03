import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loader.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection.dart';
import '../../domain/enquiry_stages.dart';
import '../../domain/entities/staff_enquiry_entity.dart';
import '../bloc/staff_enquiries_bloc.dart';
import '../bloc/staff_enquiries_event.dart';
import '../bloc/staff_enquiries_state.dart';
import '../widgets/enquiry_stage_badge.dart';

// Filter list: the CRM's stages (title-case, see EnquiryStages) plus the legacy
// 'New' that older enquiries created by this app still carry. Matching is
// case-insensitive, so docs stored as ALL-CAPS before 2026-10 still filter.
final _stages = ['All', 'New', ...EnquiryStages.all];

class StaffEnquiriesScreen extends StatefulWidget {
  const StaffEnquiriesScreen({super.key});

  @override
  State<StaffEnquiriesScreen> createState() => _StaffEnquiriesScreenState();
}

class _StaffEnquiriesScreenState extends State<StaffEnquiriesScreen> {
  String _stage = 'All';

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<StaffEnquiriesBloc>()..add(const LoadStaffEnquiriesEvent()),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enquiries', style: AppTypography.headlineLarge),
                      Text('Tap an enquiry to update its stage.', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                DropdownButton<String>(
                  value: _stage,
                  underline: const SizedBox.shrink(),
                  items: _stages
                      .map((s) => DropdownMenuItem(value: s, child: Text('Stage: $s')))
                      .toList(),
                  onChanged: (v) => setState(() => _stage = v ?? 'All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: '+ Create New Enquiry',
              isFullWidth: true,
              onPressed: () => context.push(RouteNames.staffEnquiriesNew),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: BlocBuilder<StaffEnquiriesBloc, StaffEnquiriesState>(
                builder: (context, state) {
                  if (state.listStatus == ListStatus.loading ||
                      state.listStatus == ListStatus.initial) {
                    return const Loader();
                  }
                  if (state.listStatus == ListStatus.failure) {
                    return Center(child: Text(state.listError ?? 'Unable to load enquiries.'));
                  }
                  final filtered = _stage == 'All'
                      ? state.enquiries
                      : state.enquiries
                          .where((e) => EnquiryStages.normalize(e.status) == _stage)
                          .toList();
                  if (filtered.isEmpty) {
                    return const Center(child: Text('No enquiries found.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        context.read<StaffEnquiriesBloc>().add(const LoadStaffEnquiriesEvent()),
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) => _EnquiryCard(enquiry: filtered[i]),
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

class _EnquiryCard extends StatelessWidget {
  final StaffEnquiryEntity enquiry;

  const _EnquiryCard({required this.enquiry});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => context.push(RouteNames.staffEnquiryDetail, extra: enquiry),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(enquiry.name, style: AppTypography.titleLarge)),
              EnquiryStageBadge(status: enquiry.status),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.call_rounded, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(enquiry.phone, style: AppTypography.bodySmall),
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(enquiry.city, style: AppTypography.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            children: [
              _Tag(label: enquiry.solarType),
              _Tag(label: enquiry.capacity),
              _Tag(label: enquiry.salesType),
            ],
          ),
          if ((enquiry.remark ?? enquiry.message).isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              enquiry.remark ?? enquiry.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall,
            ),
          ],
          if (enquiry.createdByStaffName != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Rep: ${enquiry.createdByStaffName}', style: AppTypography.labelSmall),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppTypography.labelSmall),
    );
  }
}

import '../../../staff_enquiries/domain/enquiry_stages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/session/staff_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loader.dart';
import '../../../../core/widgets/two_column_grid.dart';
import '../../../../injection.dart';
import '../../../staff_enquiries/domain/entities/staff_enquiry_entity.dart';
import '../bloc/staff_dashboard_bloc.dart';
import '../bloc/staff_dashboard_event.dart';
import '../bloc/staff_dashboard_state.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final staff = sl<StaffSession>().current;
    return BlocProvider(
      create: (_) => sl<StaffDashboardBloc>()..add(const LoadStaffDashboardEvent()),
      child: BlocBuilder<StaffDashboardBloc, StaffDashboardState>(
        builder: (context, state) {
            if (state.status == StaffDashboardStatus.loading ||
                state.status == StaffDashboardStatus.initial) {
              return const Loader();
            }
            if (state.status == StaffDashboardStatus.failure) {
              return Center(
                child: Text(state.errorMessage ?? 'Unable to load dashboard.'),
              );
            }
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<StaffDashboardBloc>().add(const LoadStaffDashboardEvent()),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                children: [
                  Text(
                    'Welcome back, ${staff?.name.split(' ').first ?? 'Staff'} 👋',
                    style: AppTypography.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You are signed in as ${staff?.role ?? 'Staff'}. Log new leads, follow up '
                    'on the pipeline, and register solar customers.',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  TwoColumnGrid(
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    children: [
                      _StatCard(
                        icon: Icons.inbox_rounded,
                        color: AppColors.info,
                        value: '${state.totalEnquiries}',
                        label: 'Total Enquiries',
                      ),
                      _StatCard(
                        icon: Icons.person_rounded,
                        color: AppColors.primary,
                        value: '${state.myEnquiries}',
                        label: 'My Enquiries',
                      ),
                      _StatCard(
                        icon: Icons.groups_rounded,
                        color: AppColors.accent,
                        value: '${state.solarCustomers}',
                        label: 'Solar Customers',
                      ),
                      _StatCard(
                        icon: Icons.check_circle_rounded,
                        color: AppColors.warning,
                        value: '${state.convertedLeads}',
                        label: 'Converted Leads',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  InkWell(
                    onTap: () => context.push(RouteNames.staffEnquiriesNew),
                    borderRadius: AppRadius.mdAll,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: AppRadius.mdAll,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create New Enquiry',
                                  style: AppTypography.titleLarge.copyWith(color: Colors.white),
                                ),
                                Text(
                                  'Log a lead as Telecaller or Field Salesman.',
                                  style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  InkWell(
                    onTap: () => context.push(RouteNames.staffCustomersNew),
                    borderRadius: AppRadius.mdAll,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: AppRadius.mdAll,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_add_alt_rounded, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Register a Customer', style: AppTypography.titleLarge),
                                Text(
                                  'Add a new solar customer profile and documents.',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_rounded, color: AppColors.textTertiary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Enquiries', style: AppTypography.titleLarge),
                      TextButton(
                        onPressed: () => context.go(RouteNames.staffEnquiries),
                        child: const Text('View Pipeline →'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (state.recentEnquiries.isEmpty)
                    AppCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                          child: Text('No enquiries yet.', style: AppTypography.bodyMedium),
                        ),
                      ),
                    )
                  else
                    for (final e in state.recentEnquiries) _RecentEnquiryTile(enquiry: e),
                ],
              ),
            );
          },
        ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: AppRadius.smAll),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTypography.headlineLarge),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

class _RecentEnquiryTile extends StatelessWidget {
  final StaffEnquiryEntity enquiry;

  const _RecentEnquiryTile({required this.enquiry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(enquiry.name, style: AppTypography.titleMedium),
                Text('${enquiry.solarType} · ${enquiry.capacity}', style: AppTypography.bodySmall),
              ],
            ),
          ),
          _StatusChip(status: enquiry.status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = EnquiryStages.color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.fullAll,
      ),
      child: Text(EnquiryStages.normalize(status), style: AppTypography.labelSmall.copyWith(color: color)),
    );
  }
}

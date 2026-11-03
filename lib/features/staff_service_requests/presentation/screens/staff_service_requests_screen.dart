import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/session/staff_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loader.dart';
import '../../../../core/widgets/location_status_banner.dart';
import '../../../../injection.dart';
import '../../../customer_service_requests/domain/entities/service_request_entity.dart';
import '../../../customer_service_requests/presentation/widgets/service_request_status_badge.dart';
import '../../../staff_auth/presentation/bloc/staff_auth_bloc.dart';
import '../../../staff_auth/presentation/bloc/staff_auth_event.dart';
import '../bloc/staff_service_requests_bloc.dart';
import '../bloc/staff_service_requests_event.dart';
import '../bloc/staff_service_requests_state.dart';

/// Engineer's home screen — self-contained (AppBar + Logout), no bottom nav
/// / Sales `StaffShell`, mirroring `CustomerDashboardScreen`'s same
/// simplification for a role with exactly one screen to show. Reached only
/// via the router's `isEngineer` redirect (see app_router.dart) — Sales
/// staff never see this.
class StaffServiceRequestsScreen extends StatelessWidget {
  const StaffServiceRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final engineer = sl<StaffSession>().current;
    final engineerId = engineer?.id ?? '';
    final employeeId = engineer?.employeeId ?? '';
    return BlocProvider.value(
      value: sl<StaffServiceRequestsBloc>()
        ..add(LoadAssignedServiceRequestsEvent(engineerId, employeeId: employeeId)),
      child: _StaffServiceRequestsView(engineerId: engineerId, employeeId: employeeId),
    );
  }
}

class _StaffServiceRequestsView extends StatelessWidget {
  final String engineerId;
  final String employeeId;
  const _StaffServiceRequestsView({required this.engineerId, required this.employeeId});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      sl<StaffAuthBloc>().add(const SignOutStaffEvent());
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final engineer = sl<StaffSession>().current;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleSpacing: AppSpacing.pageHorizontal,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Service Requests', style: TextStyle(color: Colors.white)),
            if (engineer != null)
              Text(
                '${engineer.name} · ${engineer.role}',
                style: AppTypography.labelSmall.copyWith(color: Colors.white70),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          const LocationStatusBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<StaffServiceRequestsBloc>().add(
                      LoadAssignedServiceRequestsEvent(engineerId, employeeId: employeeId),
                    );
              },
              child: BlocBuilder<StaffServiceRequestsBloc, StaffServiceRequestsState>(
                builder: (context, state) {
                  if (state.loadStatus == LoadStatus.loading || state.loadStatus == LoadStatus.initial) {
                    return const Loader();
                  }
                  if (state.loadStatus == LoadStatus.error) {
                    return ListView(
                      children: [
                        const SizedBox(height: AppSpacing.xxxl),
                        Center(
                          child: Text(
                            state.loadError ?? 'Unable to load service requests.',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    );
                  }
                  if (state.requests.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: AppSpacing.xxxl),
                        EmptyState(
                          icon: Icons.build_circle_outlined,
                          title: 'No service requests assigned',
                          subtitle: 'Anything assigned to you by the admin will show up here.',
                        ),
                      ],
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                    children: state.requests
                        .map((r) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: _RequestCard(request: r),
                            ))
                        .toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequestEntity request;
  const _RequestCard({required this.request});

  String _formattedDate(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    return DateFormat('d MMM yyyy').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(RouteNames.staffServiceRequestDetail, extra: request),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(request.customerName, style: AppTypography.titleLarge)),
              ServiceRequestStatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 2),
          Text('+91 ${request.customerMobile}', style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(request.serviceType, style: AppTypography.titleMedium),
          Text(
            request.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formattedDate(request.createdAt), style: AppTypography.labelSmall),
              if (request.installationPhotos.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.photo_library_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${request.installationPhotos.length} photo(s)', style: AppTypography.labelSmall),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

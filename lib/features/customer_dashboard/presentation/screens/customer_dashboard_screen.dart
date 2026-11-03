import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/session/customer_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loader.dart';
import '../../../../injection.dart';
import '../../../customer_auth/domain/entities/customer_entity.dart';
import '../../../customer_auth/presentation/bloc/customer_auth_bloc.dart';
import '../../../customer_auth/presentation/bloc/customer_auth_event.dart';
import '../../../customer_service_requests/domain/entities/service_request_entity.dart';
import '../../../customer_service_requests/presentation/bloc/customer_service_requests_bloc.dart';
import '../../../customer_service_requests/presentation/bloc/customer_service_requests_event.dart';
import '../../../customer_service_requests/presentation/bloc/customer_service_requests_state.dart';
import '../../../customer_service_requests/presentation/widgets/service_request_status_badge.dart';

/// No bottom nav / separate shell — this is the only screen a signed-in
/// customer lands on; "New Service Request" is a pushed top-level route
/// (mirrors `staffEnquiriesNew`/`staffCustomersNew`, not a shell tab).
class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customer = sl<CustomerSession>().profile;
    return BlocProvider.value(
      value: sl<CustomerServiceRequestsBloc>()
        ..add(LoadMyServiceRequestsEvent(customer?.id ?? '')),
      child: _CustomerDashboardView(customer: customer),
    );
  }
}

class _CustomerDashboardView extends StatelessWidget {
  final CustomerEntity? customer;
  const _CustomerDashboardView({required this.customer});

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
      sl<CustomerAuthBloc>().add(const SignOutCustomerEvent());
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = this.customer;
    return PopScope(
      // This screen is reached via context.go() (a full stack replace, see
      // the router's redirect logic) — there's nothing behind it to pop to,
      // so canPop is false and the hardware/gesture back action would
      // otherwise just exit the app instead of doing anything useful.
      // Route to Home explicitly instead, matching the leading AppBar
      // button below.
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(RouteNames.home);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          titleSpacing: AppSpacing.pageHorizontal,
          leading: IconButton(
            onPressed: () => context.go(RouteNames.home),
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back to Home',
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Account', style: TextStyle(color: Colors.white)),
              if (customer != null)
                Text(
                  customer.name,
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
        body: customer == null
          ? const EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Profile not found',
              subtitle: 'Please sign in again.',
            )
          : RefreshIndicator(
              onRefresh: () async {
                context.read<CustomerServiceRequestsBloc>().add(
                      LoadMyServiceRequestsEvent(customer.id),
                    );
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                children: [
                  _ProfileCard(customer: customer),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Service Requests', style: AppTypography.headlineSmall),
                      TextButton.icon(
                        onPressed: () => context.push(RouteNames.customerServiceRequestNew),
                        icon: const Icon(Icons.add_circle_rounded, size: 18),
                        label: const Text('New Request'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BlocBuilder<CustomerServiceRequestsBloc, CustomerServiceRequestsState>(
                    builder: (context, state) {
                      if (state.loadStatus == LoadStatus.loading ||
                          state.loadStatus == LoadStatus.initial) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                          child: Loader(),
                        );
                      }
                      if (state.loadStatus == LoadStatus.error) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                          child: Text(
                            state.loadError ?? 'Unable to load service requests.',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                          ),
                        );
                      }
                      if (state.requests.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                          child: EmptyState(
                            icon: Icons.build_circle_outlined,
                            title: 'No service requests yet',
                            subtitle: 'Raise a request if you need any help with your system.',
                          ),
                        );
                      }
                      return Column(
                        children: state.requests
                            .map((r) => Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                  child: _ServiceRequestCard(request: r),
                                ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final CustomerEntity customer;
  const _ProfileCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primaryContainer,
      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                  style: AppTypography.headlineSmall.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: AppTypography.titleLarge),
                    Text('+91 ${customer.mobile}', style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(child: _InfoTile(label: 'System Type', value: customer.systemType)),
              Expanded(child: _InfoTile(label: 'Capacity', value: customer.capacity)),
              Expanded(
                child: _InfoTile(label: 'Status', value: customer.installationStatus),
              ),
            ],
          ),
          if (customer.address.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(customer.address, style: AppTypography.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTypography.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ServiceRequestCard extends StatelessWidget {
  final ServiceRequestEntity request;
  const _ServiceRequestCard({required this.request});

  String _formattedDate(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    return DateFormat('d MMM yyyy').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(request.serviceType, style: AppTypography.titleMedium),
              ),
              ServiceRequestStatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(request.description, style: AppTypography.bodyMedium),
          if (request.assignedEngineerName.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.engineering_rounded, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Engineer: ${request.assignedEngineerName}',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formattedDate(request.createdAt), style: AppTypography.labelSmall),
              if (request.estimatedCost > 0)
                Text(
                  '₹${request.estimatedCost}',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

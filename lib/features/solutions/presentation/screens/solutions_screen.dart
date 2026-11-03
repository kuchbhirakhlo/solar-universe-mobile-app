import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/loader.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../injection.dart';
import '../../../content/domain/entities/solution_entity.dart';
import '../../../content/presentation/bloc/content_bloc.dart';
import '../../../content/presentation/bloc/content_event.dart';
import '../../../content/presentation/bloc/content_state.dart';
import '../../../enquiry/presentation/widgets/enquiry_form_sheet.dart';

IconData _iconFor(String type) {
  switch (type) {
    case 'on_grid':
      return Icons.power_rounded;
    case 'off_grid':
      return Icons.battery_charging_full_rounded;
    case 'hybrid':
      return Icons.sync_alt_rounded;
    default:
      return Icons.solar_power_rounded;
  }
}

/// Maps a solution's `type` to one of [EnquiryOptions.systemTypes] so the
/// quote form's dropdown pre-selects correctly.
String _systemTypeFor(String type) {
  switch (type) {
    case 'off_grid':
      return 'Off Grid';
    case 'hybrid':
      return 'Hybrid';
    default:
      return 'On Grid';
  }
}

class SolutionsScreen extends StatelessWidget {
  const SolutionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ContentBloc>()..add(const LoadSolutionsEvent()),
      child: Scaffold(
        appBar: const AppTopBar(title: 'Solar Solutions'),
        backgroundColor: AppColors.background,
        body: BlocBuilder<ContentBloc, ContentState>(
          builder: (context, state) {
            if (state.solutionsStatus == LoadStatus.loading ||
                state.solutionsStatus == LoadStatus.initial) {
              return const Loader();
            }
            if (state.solutions.isEmpty) {
              return Center(
                child: Text(state.solutionsError ?? 'No solutions available yet.'),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
              children: [
                for (final solution in state.solutions) ...[
                  _SolutionCard(solution: solution),
                  const SizedBox(height: AppSpacing.lg),
                ],
                SecondaryButton(
                  label: 'View Pricing Packages',
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  onPressed: () => context.push(RouteNames.pricing),
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SolutionCard extends StatelessWidget {
  final SolutionEntity solution;

  const _SolutionCard({required this.solution});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.smAll,
                ),
                child: Icon(_iconFor(solution.type), color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(solution.title, style: AppTypography.headlineSmall)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(solution.description, style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          for (final benefit in solution.benefits)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(benefit, style: AppTypography.bodySmall)),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Request Quote',
            onPressed: () => showEnquiryFormSheet(
              context,
              source: 'solutions_${solution.type}',
              initialSystemType: _systemTypeFor(solution.type),
            ),
          ),
        ],
      ),
    );
  }
}

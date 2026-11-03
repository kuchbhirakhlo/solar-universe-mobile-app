import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loader.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/two_column_grid.dart';
import '../../../../injection.dart';
import '../../../content/presentation/bloc/content_bloc.dart';
import '../../../content/presentation/bloc/content_event.dart';
import '../../../content/presentation/bloc/content_state.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ContentBloc>()..add(const LoadCompanyInfoEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('About Us')),
        backgroundColor: AppColors.background,
        body: BlocBuilder<ContentBloc, ContentState>(
          builder: (context, state) {
            if (state.companyStatus == LoadStatus.loading ||
                state.companyStatus == LoadStatus.initial) {
              return const Loader();
            }
            final info = state.companyInfo;
            if (info == null) {
              return Center(child: Text(state.companyError ?? 'Unable to load content.'));
            }
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
              children: [
                Text(info.aboutShort, style: AppTypography.bodyLarge),
                const SizedBox(height: AppSpacing.xxl),
                AppCard(
                  color: AppColors.primaryContainer,
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Our Mission', style: AppTypography.titleLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(info.missionText, style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  color: AppColors.accentContainer,
                  border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Our Vision', style: AppTypography.titleLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(info.visionText, style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const SectionHeader(title: 'Our Team'),
                const SizedBox(height: AppSpacing.lg),
                TwoColumnGrid(
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  children: [
                    _TeamStat(value: '${info.teamExperienceYears}+', label: 'Years Experience'),
                    _TeamStat(value: '${info.teamProjectsCompleted}+', label: 'Projects Completed'),
                    _TeamStat(value: '${info.teamMembers}+', label: 'Team Members'),
                    _TeamStat(
                      value: '${info.teamSatisfactionPercent}%',
                      label: 'Client Satisfaction',
                    ),
                  ],
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

class _TeamStat extends StatelessWidget {
  final String value;
  final String label;

  const _TeamStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTypography.headlineMedium.copyWith(color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

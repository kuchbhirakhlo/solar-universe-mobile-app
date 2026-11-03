import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/loader.dart';
import '../../../../injection.dart';
import '../../../content/domain/entities/project_entity.dart';
import '../../../content/presentation/bloc/content_bloc.dart';
import '../../../content/presentation/bloc/content_event.dart';
import '../../../content/presentation/bloc/content_state.dart';
import '../../../enquiry/presentation/widgets/enquiry_form_sheet.dart';

String _formatDate(String isoDate) {
  final parsed = DateTime.tryParse(isoDate);
  if (parsed == null) return isoDate;
  return DateFormat('MMM yyyy').format(parsed);
}

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ContentBloc>()..add(const LoadProjectsEvent()),
      child: Scaffold(
        appBar: const AppTopBar(title: 'Projects'),
        backgroundColor: AppColors.background,
        body: BlocBuilder<ContentBloc, ContentState>(
          builder: (context, state) {
            if (state.projectsStatus == LoadStatus.loading ||
                state.projectsStatus == LoadStatus.initial) {
              return const Loader();
            }
            if (state.projects.isEmpty) {
              return Center(child: Text(state.projectsError ?? 'No projects listed yet.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
              itemCount: state.projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, i) => _ProjectCard(project: state.projects[i]),
            );
          },
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectEntity project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: project.imageUrl.isEmpty
                      ? Container(
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.image_rounded,
                            size: 40,
                            color: AppColors.textTertiary,
                          ),
                        )
                      : AppImage(
                          url: project.imageUrl,
                          fallback: () => Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.broken_image_rounded),
                          ),
                        ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _Badge(
                    label: project.capacity,
                    color: AppColors.secondaryNavy,
                  ),
                ),
                if (project.featured)
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: _Badge(label: 'Featured', color: AppColors.primary),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.title, style: AppTypography.titleLarge),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(project.location, style: AppTypography.bodySmall),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  children: [
                    _TagChip(label: project.systemType),
                    _TagChip(label: project.capacity),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(project.description, style: AppTypography.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${project.customerName} • Completed ${_formatDate(project.completionDate)}',
                  style: AppTypography.labelSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => showEnquiryFormSheet(context, source: 'project_${project.id}'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text('Get Quote →'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.fullAll),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: Colors.white),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppTypography.labelSmall),
    );
  }
}

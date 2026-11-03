import 'package:flutter/material.dart';
import '../../../../core/constants/app_color_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../content/domain/entities/project_entity.dart';
import '../../domain/home_content.dart';
import 'home_common.dart';

/// Website `#projects`: Residential / Commercial / Industrial tabs over the
/// `projects` collection, with the website's "portfolio being prepared"
/// placeholder when a category has no entries.
class HomeProjectsSection extends StatefulWidget {
  final List<ProjectEntity> projects;
  final VoidCallback onDiscuss;

  const HomeProjectsSection({super.key, required this.projects, required this.onDiscuss});

  @override
  State<HomeProjectsSection> createState() => _HomeProjectsSectionState();
}

class _HomeProjectsSectionState extends State<HomeProjectsSection> {
  String _category = HomeContent.projectCategories.first;

  @override
  Widget build(BuildContext context) {
    final shown = widget.projects
        .where((p) => p.category.toLowerCase() == _category.toLowerCase())
        .toList();
    return HomeSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Project experience'),
          const SectionTitle('Solar Expertise. Across Every Rooftop.'),
          const SectionLead(
            'Residential, commercial and industrial capabilities backed by 5000+ kW of solar '
            'project experience.',
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (final c in HomeContent.projectCategories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _category = c),
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: c == _category ? AppColors.accent : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: c == _category ? AppColors.accent : const Color(0xFFDEE5D7),
                        ),
                      ),
                      child: Text(
                        c,
                        style: AppTypography.labelMedium.copyWith(
                          color: c == _category ? Colors.white : AppColorConstants.inkText,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (shown.isEmpty)
            _Placeholder(category: _category, onDiscuss: widget.onDiscuss)
          else
            for (final p in shown) _ProjectCard(project: p),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String category;
  final VoidCallback onDiscuss;

  const _Placeholder({required this.category, required this.onDiscuss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColorConstants.sectionLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6DFD7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.solar_power_rounded, size: 28, color: AppColors.accent),
          const SizedBox(height: 10),
          Text('$category project portfolio', style: AppTypography.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Verified project photographs and details are being prepared. Contact our team to '
            'discuss relevant project experience.',
            style: AppTypography.bodyMedium.copyWith(height: 1.7),
          ),
          const SizedBox(height: 14),
          HomeButton(label: 'Discuss Project Experience', onPressed: onDiscuss),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectEntity project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: homeCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 190,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppImage(
                  url: project.imageUrl,
                  fallback: () => Container(color: AppColorConstants.sectionCalc),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(project.category, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
                  ),
                ),
                if (project.featured)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '★ Featured',
                        style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: AppTypography.titleLarge.copyWith(
                    fontSize: 14,
                    color: AppColorConstants.inkText,
                  ),
                ),
                if (project.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    project.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall,
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(project.location, style: AppTypography.bodySmall),
                    ),
                    Text(
                      project.capacity,
                      style: AppTypography.labelMedium.copyWith(color: AppColors.accent),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

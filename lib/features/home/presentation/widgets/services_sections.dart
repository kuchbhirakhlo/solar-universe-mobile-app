import 'package:flutter/material.dart';
import '../../../../core/constants/app_color_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/two_column_grid.dart';
import '../../domain/home_content.dart';
import 'home_common.dart';

/// Website `#services`: 14 service cards, 2 per row on mobile; each opens an enquiry.
class ServicesSection extends StatelessWidget {
  final void Function(String serviceTitle) onService;
  final VoidCallback onDiscuss;

  const ServicesSection({super.key, required this.onService, required this.onDiscuss});

  @override
  Widget build(BuildContext context) {
    return HomeSection(
      background: AppColorConstants.sectionLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Built around your energy needs'),
          const SectionTitle('One Solar Partner. Complete Possibilities.'),
          const SectionLead(
            'Our solar services cover your entire project lifecycle, with professional support at '
            'every step.',
          ),
          const SizedBox(height: 14),
          HomeButton(label: 'Discuss Your Project', secondary: true, onPressed: onDiscuss),
          const SizedBox(height: 20),
          TwoColumnGrid(
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              for (final s in HomeContent.services)
                _ServiceCard(item: s, onTap: () => onService(s.title)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceItem item;
  final VoidCallback onTap;

  const _ServiceCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(kCardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(kCardRadius),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: homeCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(item.icon, size: 24, color: AppColors.accent),
                  const Icon(Icons.north_east_rounded, size: 15, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: AppTypography.titleLarge.copyWith(
                  fontSize: 13,
                  height: 1.3,
                  color: AppColorConstants.inkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(item.text, style: AppTypography.bodySmall.copyWith(fontSize: 10.5, height: 1.55)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Website "Solar for every scale": Home / Commercial / Industrial.
class ScaleSection extends StatelessWidget {
  final void Function(String title) onExplore;

  const ScaleSection({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return HomeSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Solar for every scale'),
          const SectionTitle('Your Space. Your Solar Solution.'),
          const SizedBox(height: 18),
          for (final s in HomeContent.scales)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: s.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColorConstants.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(s.icon, size: 30, color: AppColors.accent),
                  const SizedBox(height: 14),
                  Text(
                    s.title,
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColorConstants.inkText,
                      fontSize: 21,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(s.text, style: AppTypography.bodyMedium.copyWith(height: 1.7)),
                  const SizedBox(height: 8),
                  HomeTextLink(label: s.cta, onTap: () => onExplore(s.title)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

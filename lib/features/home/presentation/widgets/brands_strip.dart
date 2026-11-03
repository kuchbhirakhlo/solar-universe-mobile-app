import 'package:flutter/material.dart';
import '../../../../core/constants/app_color_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../content/domain/entities/brand_entity.dart';
import 'home_common.dart';

/// Existing app feature (Firestore `brands`), restyled to the website's section look.
class BrandsStrip extends StatelessWidget {
  final List<BrandEntity> brands;

  const BrandsStrip({super.key, required this.brands});

  @override
  Widget build(BuildContext context) {
    if (brands.isEmpty) return const SizedBox.shrink();
    return HomeSection(
      background: AppColorConstants.sectionLight,
      padding: const EdgeInsets.symmetric(vertical: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: kHomeHPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow('Our brand partners'),
                SectionTitle('Premium Solar Brands'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: kHomeHPad),
              itemCount: brands.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final brand = brands[i];
                Widget fallback() => Center(
                      child: Text(
                        brand.name,
                        style: AppTypography.labelMedium,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                return Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(kCardRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: brand.logo.isEmpty
                      ? fallback()
                      : AppImage(url: brand.logo, fit: BoxFit.contain, fallback: fallback),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

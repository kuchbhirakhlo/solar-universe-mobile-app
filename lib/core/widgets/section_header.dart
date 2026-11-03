import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry? padding;
  final TextAlign textAlign;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.padding,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment:
            textAlign == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.headlineLarge, textAlign: textAlign),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: textAlign,
            ),
          ],
        ],
      ),
    );
  }
}

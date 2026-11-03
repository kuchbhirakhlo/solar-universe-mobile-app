import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class AppDropdownField<T> extends StatelessWidget {
  final String? label;
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final void Function(T?) onChanged;

  const AppDropdownField({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!.toUpperCase(), style: AppTypography.labelMedium),
          const SizedBox(height: AppSpacing.sm),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
          decoration: const InputDecoration(counterText: ''),
          items: items
              .map((e) => DropdownMenuItem<T>(value: e, child: Text(labelBuilder(e))))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

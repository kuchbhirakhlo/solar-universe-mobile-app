import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';

/// Colors the 3 real statuses seen in the admin panel (Open/In Progress/
/// Completed) explicitly; falls back to a neutral gray for anything else
/// rather than assuming this is every status string the admin will ever
/// use — same defensive lesson as `staff_enquiries`'s `_StageBadge`.
class ServiceRequestStatusBadge extends StatelessWidget {
  final String status;

  const ServiceRequestStatusBadge({super.key, required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'open':
        return AppColors.info;
      case 'in progress':
        return AppColors.warning;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.fullAll,
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/enquiry_stages.dart';

/// Pill showing an enquiry's stage; case-insensitive, so legacy ALL-CAPS and
/// CRM title-case values render identically.
class EnquiryStageBadge extends StatelessWidget {
  final String status;

  const EnquiryStageBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = EnquiryStages.color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: AppRadius.fullAll),
      child: Text(
        EnquiryStages.normalize(status),
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}

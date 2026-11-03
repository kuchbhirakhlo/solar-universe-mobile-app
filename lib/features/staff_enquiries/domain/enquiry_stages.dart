import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Enquiry pipeline, using the exact strings the website CRM writes and
/// matches on (`types.ts` `Enquiry.status`). The app used to write them in
/// ALL CAPS ("INTERESTED"), which the CRM's chips/counters didn't match, so
/// everything here compares case-insensitively and writes canonical title-case.
class EnquiryStages {
  EnquiryStages._();

  /// "Converted" is admin-only in the CRM — sales staff can't set it
  /// (`SalesEnquiries.tsx` omits it from its dropdowns).
  static const List<String> staffSelectable = [
    'Interested',
    'Contacted',
    'Paper Correction',
    'Paper Received',
    'Site Visit',
    'Quotation',
    'File Submitted in Bank',
    'Payment Received',
    'Rejected',
  ];

  static const String converted = 'Converted';
  static const String initial = 'Interested';

  static const List<String> all = [...staffSelectable, converted];

  /// Canonical title-case for a known stage, whatever case it was stored in;
  /// unknown values (e.g. the legacy "New") are returned unchanged.
  static String normalize(String status) {
    final key = status.trim().toLowerCase();
    for (final s in all) {
      if (s.toLowerCase() == key) return s;
    }
    return status.trim();
  }

  static bool isConverted(String status) => normalize(status) == converted;

  static Color color(String status) {
    switch (normalize(status)) {
      case 'Converted':
        return AppColors.success;
      case 'Rejected':
        return AppColors.error;
      case 'Interested':
        return AppColors.primary;
      case 'Contacted':
      case 'Paper Received':
        return AppColors.info;
      case 'Paper Correction':
        return AppColors.warning;
      case 'Site Visit':
      case 'Quotation':
        return AppColors.accent;
      case 'File Submitted in Bank':
      case 'Payment Received':
        return AppColors.secondaryNavy;
      default:
        return AppColors.warning;
    }
  }
}

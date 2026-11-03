import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/launcher_helper.dart';
import '../../../../core/widgets/app_top_bar.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'More'),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        children: [
          _MoreTile(
            icon: Icons.info_rounded,
            label: 'About Us',
            onTap: () => context.push(RouteNames.about),
          ),
          _MoreTile(
            icon: Icons.help_rounded,
            label: 'FAQs',
            onTap: () => context.push(RouteNames.faq),
          ),
          _MoreTile(
            icon: Icons.contact_mail_rounded,
            label: 'Contact Us',
            onTap: () => context.push(RouteNames.contact),
          ),
          _MoreTile(
            icon: Icons.local_offer_rounded,
            label: 'Solar Packages',
            onTap: () => context.push(RouteNames.pricing),
          ),
          _MoreTile(
            icon: Icons.call_rounded,
            label: 'Call Us: ${AppStrings.primaryContactDisplay}',
            onTap: () => LauncherHelper.call(AppStrings.primaryContactNumber),
          ),
          _MoreTile(
            icon: Icons.email_rounded,
            label: AppStrings.contactEmail,
            onTap: () => LauncherHelper.email(AppStrings.contactEmail),
          ),
          const SizedBox(height: AppSpacing.lg),
          _MoreTile(
            icon: Icons.badge_rounded,
            label: 'Staff Login',
            onTap: () => context.push(RouteNames.staffLogin),
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MoreTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: AppTypography.titleMedium),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
        onTap: onTap,
      ),
    );
  }
}

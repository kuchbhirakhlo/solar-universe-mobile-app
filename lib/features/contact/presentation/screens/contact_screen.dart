import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/launcher_helper.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loader.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../injection.dart';
import '../../../content/domain/entities/company_info_entity.dart';
import '../../../content/presentation/bloc/content_bloc.dart';
import '../../../content/presentation/bloc/content_event.dart';
import '../../../content/presentation/bloc/content_state.dart';
import '../../../enquiry/presentation/widgets/contact_message_form.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ContentBloc>()..add(const LoadCompanyInfoEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Contact Us')),
        backgroundColor: AppColors.background,
        body: BlocBuilder<ContentBloc, ContentState>(
          builder: (context, state) {
            if (state.companyStatus == LoadStatus.loading ||
                state.companyStatus == LoadStatus.initial) {
              return const Loader();
            }
            final info = state.companyInfo;
            if (info == null) {
              return Center(child: Text(state.companyError ?? 'Unable to load content.'));
            }
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Office Headquarters', style: AppTypography.titleLarge),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(info.regOfficeAddress, style: AppTypography.bodySmall),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton.icon(
                        onPressed: () => LauncherHelper.openMap(info.regOfficeAddress),
                        icon: const Icon(Icons.map_rounded, size: 18),
                        label: const Text('Open in Maps'),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      ),
                    ],
                  ),
                ),
                if (info.branchOffices.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(title: 'Branch Offices'),
                  for (final branch in info.branchOffices)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _BranchRow(branch: branch),
                    ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Get in Touch', style: AppTypography.titleLarge),
                      const SizedBox(height: AppSpacing.md),
                      for (final number in info.contactNumbers)
                        _ContactRow(
                          icon: Icons.call_rounded,
                          label: number,
                          onTap: () => LauncherHelper.call(number),
                        ),
                      _ContactRow(
                        icon: Icons.email_rounded,
                        label: info.email,
                        onTap: () => LauncherHelper.email(info.email),
                      ),
                      _ContactRow(
                        icon: Icons.schedule_rounded,
                        label: info.businessHours,
                        onTap: null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const SectionHeader(title: 'Send Us a Message'),
                const ContactMessageForm(),
                const SizedBox(height: AppSpacing.xxxl),
                Center(
                  child: Column(
                    children: [
                      Text('GSTN: ${info.gstn}', style: AppTypography.labelSmall),
                      Text('Vendor Code: ${info.vendorCode}', style: AppTypography.labelSmall),
                      const SizedBox(height: 4),
                      Text(
                        '© 2026 ${AppStrings.appName}',
                        style: AppTypography.labelSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BranchRow extends StatelessWidget {
  final BranchOfficeEntity branch;

  const _BranchRow({required this.branch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.store_rounded, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(branch.name, style: AppTypography.titleMedium),
                Text(branch.address, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ContactRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(label, style: AppTypography.bodyMedium)),
          ],
        ),
      ),
    );
  }
}

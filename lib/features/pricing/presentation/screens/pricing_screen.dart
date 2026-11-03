import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loader.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../injection.dart';
import '../../../content/domain/entities/package_entity.dart';
import '../../../content/presentation/bloc/content_bloc.dart';
import '../../../content/presentation/bloc/content_event.dart';
import '../../../content/presentation/bloc/content_state.dart';
import '../../../enquiry/presentation/widgets/enquiry_form_sheet.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ContentBloc>()..add(const LoadPackagesEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Solar Packages')),
        backgroundColor: AppColors.background,
        body: BlocBuilder<ContentBloc, ContentState>(
          builder: (context, state) {
            if (state.packagesStatus == LoadStatus.loading ||
                state.packagesStatus == LoadStatus.initial) {
              return const Loader();
            }
            if (state.packages.isEmpty) {
              return Center(child: Text(state.packagesError ?? 'No packages available yet.'));
            }
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.brandYellow.withOpacity(0.25),
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(color: AppColors.brandYellowDark.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_rounded, color: AppColors.textHeading),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'PM-Surya Ghar Subsidy Advantage — Residential setups of 1KW to 3KW '
                          'enjoy government subsidies up to ₹1,08,000!',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textHeading),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                for (final pkg in state.packages) ...[
                  _PackageCard(pkg: pkg),
                  const SizedBox(height: AppSpacing.lg),
                ],
                const SizedBox(height: AppSpacing.xxl),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final PackageEntity pkg;

  const _PackageCard({required this.pkg});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(pkg.title, style: AppTypography.headlineSmall)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.fullAll,
                ),
                child: Text(
                  pkg.capacity,
                  style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            pkg.price.currencyFormatted,
            style: AppTypography.headlineMedium.copyWith(color: AppColors.primary),
          ),
          const Divider(height: AppSpacing.xxl),
          _SpecRow(label: 'Panels', value: pkg.panelType),
          _SpecRow(label: 'Inverter', value: pkg.inverter),
          _SpecRow(label: 'Warranty', value: pkg.warranty),
          if (pkg.features.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            for (final item in pkg.features)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(item, style: AppTypography.bodySmall)),
                  ],
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Enquire Now',
            onPressed: () => showEnquiryFormSheet(
              context,
              source: 'pricing_${pkg.id}',
              initialCapacity: pkg.capacity,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: AppTypography.labelMedium)),
          Expanded(child: Text(value, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}

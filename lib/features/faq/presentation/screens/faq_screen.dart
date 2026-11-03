import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/launcher_helper.dart';
import '../../../../core/widgets/loader.dart';
import '../../../../injection.dart';
import '../../../content/presentation/bloc/content_bloc.dart';
import '../../../content/presentation/bloc/content_event.dart';
import '../../../content/presentation/bloc/content_state.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ContentBloc>()..add(const LoadFaqsEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('FAQs')),
        backgroundColor: AppColors.background,
        body: BlocBuilder<ContentBloc, ContentState>(
          builder: (context, state) {
            if (state.faqsStatus == LoadStatus.loading || state.faqsStatus == LoadStatus.initial) {
              return const Loader();
            }
            if (state.faqs.isEmpty) {
              return Center(child: Text(state.faqsError ?? 'No FAQs available yet.'));
            }
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
              children: [
                for (final faq in state.faqs)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: AppRadius.mdAll,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        title: Text(faq.question, style: AppTypography.titleLarge),
                        expandedAlignment: Alignment.topLeft,
                        children: [
                          Text(faq.answer, style: AppTypography.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Still have questions?',
                        style: AppTypography.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton.icon(
                        onPressed: () => LauncherHelper.call(AppStrings.primaryContactNumber),
                        icon: const Icon(Icons.call_rounded),
                        label: Text('Call Our Support Desk: ${AppStrings.primaryContactDisplay}'),
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

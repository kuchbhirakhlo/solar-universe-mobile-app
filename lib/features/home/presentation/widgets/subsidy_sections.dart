import 'package:flutter/material.dart';
import '../../../../core/constants/app_color_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/launcher_helper.dart';
import '../../domain/home_content.dart';
import 'home_common.dart';

class _SubsidyCard extends StatelessWidget {
  final String number;
  final String system;
  final String? prefix;
  final String amount;

  const _SubsidyCard({
    required this.number,
    required this.system,
    this.prefix,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
        decoration: homeCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.wb_sunny_outlined, size: 18, color: AppColors.primary),
                Text(number, style: AppTypography.labelSmall.copyWith(fontSize: 9)),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              system,
              style: AppTypography.titleLarge.copyWith(fontSize: 12.5, height: 1.3),
            ),
            const SizedBox(height: 10),
            Text(
              'Central Government Subsidy',
              style: AppTypography.bodySmall.copyWith(fontSize: 9.5, height: 1.3),
            ),
            const SizedBox(height: 8),
            if (prefix != null)
              Text(prefix!, style: AppTypography.labelSmall.copyWith(fontSize: 9.5)),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.accent,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Website `#subsidy`: PM Surya Ghar central subsidy tiers + UP combined card.
class SubsidySection extends StatelessWidget {
  final VoidCallback onFindPotential;
  final VoidCallback onEligibility;

  const SubsidySection({super.key, required this.onFindPotential, required this.onEligibility});

  @override
  Widget build(BuildContext context) {
    return HomeSection(
      background: AppColorConstants.sectionSubsidy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('PM Surya Ghar: Muft Bijli Yojana'),
          const SectionTitle('Make Your Home Solar-Powered with Government Subsidy'),
          const SectionLead(
            'Explore government support for eligible residential rooftop solar. We help you '
            'understand the process, from application to installation.',
          ),
          const SizedBox(height: 6),
          HomeTextLink(label: 'Find your solar potential', onTap: onFindPotential),
          const SizedBox(height: 14),
          const IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SubsidyCard(number: '01', system: '1 kW System', amount: '₹30,000'),
                SizedBox(width: 10),
                _SubsidyCard(number: '02', system: '2 kW System', amount: '₹60,000'),
                SizedBox(width: 10),
                _SubsidyCard(
                  number: '03',
                  system: '3 kW and Above System',
                  prefix: 'Up to',
                  amount: '₹78,000',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColorConstants.subsidyCardGreen,
              borderRadius: BorderRadius.circular(kCardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Extra support for Uttar Pradesh', color: Color(0xFFC3DC9F)),
                RichText(
                  text: TextSpan(
                    style: AppTypography.headlineLarge.copyWith(color: Colors.white, fontSize: 24),
                    children: [
                      const TextSpan(text: 'Get Up to '),
                      TextSpan(
                        text: '₹1,08,000',
                        style: AppTypography.headlineLarge.copyWith(
                          color: AppColorConstants.amberOnDark,
                          fontSize: 32,
                        ),
                      ),
                      const TextSpan(text: ' Combined Subsidy*'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Additional UP Government Subsidy — ₹15,000/kW up to 2 kW.',
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white70, fontSize: 12.5),
                ),
                const SizedBox(height: 16),
                HomeButton(label: 'Check Subsidy Eligibility', onPressed: onEligibility),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '*${HomeContent.subsidyDisclaimer} Subsidy is provided by the applicable government '
            'scheme; Solar Universe Enterprises does not provide or guarantee it.',
            style: AppTypography.bodySmall.copyWith(fontSize: 10, height: 1.6),
          ),
          const SizedBox(height: 8),
          HomeTextLink(
            label: 'Apply for PM Surya Ghar',
            onTap: () => LauncherHelper.openUrl(HomeContent.pmSuryaGharUrl),
          ),
          Wrap(
            spacing: 6,
            children: [
              Text('Scheme sources:', style: AppTypography.bodySmall.copyWith(fontSize: 10)),
              InkWell(
                onTap: () => LauncherHelper.openUrl(HomeContent.centralSourceUrl),
                child: Text(
                  'Government central assistance information',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 10,
                    color: AppColors.accent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text('·', style: AppTypography.bodySmall.copyWith(fontSize: 10)),
              InkWell(
                onTap: () => LauncherHelper.openUrl(HomeContent.upPolicyUrl),
                child: Text(
                  'Uttar Pradesh Solar Energy Policy',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 10,
                    color: AppColors.accent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final String state;
  final String text;
  final String? highlight;
  final bool featured;
  final VoidCallback onTap;

  const _StateCard({
    required this.state,
    required this.text,
    this.highlight,
    this.featured = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: homeCardDecoration(
        color: featured ? const Color(0xFFF5F9F0) : Colors.white,
        border: featured ? const Color(0xFF9CB48C) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(state, style: AppTypography.headlineMedium.copyWith(color: AppColorConstants.inkText)),
          const SizedBox(height: 8),
          Text(text, style: AppTypography.bodyMedium.copyWith(fontSize: 12.5)),
          if (highlight != null) ...[
            const SizedBox(height: 8),
            Text(
              highlight!,
              style: AppTypography.titleLarge.copyWith(color: AppColors.accent, fontSize: 14),
            ),
          ],
          const SizedBox(height: 6),
          HomeTextLink(label: 'Ask About Eligibility', onTap: onTap),
        ],
      ),
    );
  }
}

/// Website "Solar Subsidy & Support": per-state cards.
class StateSubsidySection extends StatelessWidget {
  final VoidCallback onAsk;

  const StateSubsidySection({super.key, required this.onAsk});

  @override
  Widget build(BuildContext context) {
    const bihar =
        'Central PM Surya Ghar assistance of up to ₹78,000, subject to eligibility. State-specific '
        'benefits will be shared after verification.';
    return HomeSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Know your benefits'),
          const SectionTitle('Solar Subsidy & Support'),
          const SectionLead(
            'PM Surya Ghar central financial assistance applies to eligible residential '
            'grid-connected rooftop installations according to current scheme guidelines.',
          ),
          const SizedBox(height: 18),
          _StateCard(
            state: 'Uttar Pradesh',
            text: 'Central subsidy + applicable additional Uttar Pradesh state subsidy.',
            highlight: 'Potential combined subsidy up to ₹1,08,000*',
            featured: true,
            onTap: onAsk,
          ),
          _StateCard(state: 'Bihar', text: bihar, onTap: onAsk),
          _StateCard(state: 'Jharkhand', text: bihar, onTap: onAsk),
          Text(
            '*${HomeContent.subsidyDisclaimer} Government schemes, subsidy amounts and eligibility '
            'criteria may be revised. Contact our team for current information.',
            style: AppTypography.bodySmall.copyWith(fontSize: 10, height: 1.6),
          ),
        ],
      ),
    );
  }
}

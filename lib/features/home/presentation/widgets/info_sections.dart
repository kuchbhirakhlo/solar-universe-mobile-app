import 'package:flutter/material.dart';
import '../../../../core/constants/app_color_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/home_content.dart';
import 'home_common.dart';

/// Website trust strip: 2x2 quick facts.
class TrustStrip extends StatelessWidget {
  final int experienceYears;
  final int capacityKw;

  const TrustStrip({super.key, required this.experienceYears, required this.capacityKw});

  @override
  Widget build(BuildContext context) {
    return HomeSection(
      padding: const EdgeInsets.symmetric(horizontal: kHomeHPad, vertical: 26),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _Num('$experienceYears+', 'Years Experience')),
              Expanded(child: _Num('$capacityKw+ kW', 'Solar Project Experience')),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Fact(
                  Icons.grid_view_rounded,
                  'Residential · Commercial',
                  'Industrial Expertise',
                ),
              ),
              Expanded(
                child: _Fact(
                  Icons.verified_user_outlined,
                  'From Consultation to',
                  'After-Sales Support',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Num extends StatelessWidget {
  final String value;
  final String label;

  const _Num(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.displayLarge.copyWith(
            color: AppColors.accent,
            fontSize: 30,
            fontWeight: FontWeight.w500,
            letterSpacing: -1.2,
          ),
        ),
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 10.5)),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String line1;
  final String line2;

  const _Fact(this.icon, this.line1, this.line2);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accent, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(line1, style: AppTypography.bodySmall.copyWith(fontSize: 10.5)),
              Text(
                line2,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColorConstants.inkText,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Website `#about`: image with the "15+ years" badge, copy, 5 checks, CTA.
class AboutSection extends StatelessWidget {
  final int experienceYears;
  final VoidCallback onTalk;

  const AboutSection({super.key, required this.experienceYears, required this.onTalk});

  @override
  Widget build(BuildContext context) {
    return HomeSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(kCardRadius),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/solar_universe_hero.jpg',
                  height: 230,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 14,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(kCardRadius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$experienceYears+',
                          style: AppTypography.displayLarge.copyWith(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'YEARS OF\nSOLAR EXPERTISE',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Clean energy. Thoughtfully delivered.',
            style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 22),
          const Eyebrow('Your partner in the solar journey'),
          const SectionTitle('15+ Years of Solar Expertise You Can Trust'),
          const SectionLead(
            'An experienced solar EPC company in Lucknow, Solar Universe Enterprises brings '
            'practical expertise and personal attention to every stage of your solar journey.',
          ),
          const SizedBox(height: 10),
          Text(
            'We design and deliver end-to-end solutions for homes, businesses and industrial '
            'facilities. From your first site assessment to commissioning and ongoing support, our '
            'focus is a system that fits your property and energy needs.',
            style: AppTypography.bodyMedium.copyWith(height: 1.7),
          ),
          const SizedBox(height: 16),
          for (final c in HomeContent.aboutChecks)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColorConstants.inkText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          HomeButton(label: 'Let\'s Talk Solar', onPressed: onTalk),
        ],
      ),
    );
  }
}

/// Website award band — the certificate photo is still "To be added" there too.
class AwardBand extends StatelessWidget {
  const AwardBand({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeSection(
      background: AppColorConstants.sectionAward,
      padding: const EdgeInsets.symmetric(horizontal: kHomeHPad, vertical: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.workspace_premium_rounded, size: 36, color: Color(0xFFB18A41)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Recognized for Excellence', color: Color(0xFF957D40)),
                Text(
                  'Excellence Award — FY 2025–26',
                  style: AppTypography.headlineMedium.copyWith(color: AppColorConstants.inkText),
                ),
                const SizedBox(height: 6),
                Text(
                  'End-to-End Customer Service · Awarded by Metafin Cleantech Finance Pvt. Ltd.',
                  style: AppTypography.bodyMedium.copyWith(fontSize: 12.5),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD9D2BC)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_outlined, size: 16, color: Color(0xFFB18A41)),
                      const SizedBox(width: 8),
                      Text(
                        'Award photograph — to be added',
                        style: AppTypography.bodySmall.copyWith(fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Website dark "Solar Universe difference" section.
class WhyUsSection extends StatelessWidget {
  const WhyUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeSection(
      background: AppColorConstants.forestGreen700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('The Solar Universe difference', color: Color(0xFFC3DC9F)),
          const SectionTitle('Experience That Makes Every Step Easier.', color: Colors.white),
          const SectionLead(
            'A solar investment deserves thoughtful planning, professional execution and a team '
            'you can reach long after installation.',
            color: Color(0xFFD5DDD3),
          ),
          const SizedBox(height: 20),
          Wrap(
            runSpacing: 14,
            children: [
              for (final item in HomeContent.whyUs)
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 17, color: Color(0xFF9AC88D)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
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

/// Website `#atta-chakki`.
class AttaChakkiSection extends StatelessWidget {
  final VoidCallback onDiscuss;

  const AttaChakkiSection({super.key, required this.onDiscuss});

  @override
  Widget build(BuildContext context) {
    return HomeSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(kCardRadius),
            child: Image.asset(
              'assets/images/solar_atta_chakki.webp',
              height: 210,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Solar for flour mills.',
            style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
          const Eyebrow('Solar for Flour Mills'),
          const SectionTitle('Solar Atta Chakki Solutions'),
          const SectionLead('Power Your Flour Mill with Solar Energy'),
          const SizedBox(height: 10),
          Text(
            'Looking for a solar-powered atta chakki? Contact Solar Universe Enterprises to discuss '
            'a solar solution for your flour milling business.',
            style: AppTypography.bodyMedium.copyWith(height: 1.7),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.grass_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Whether you\'re planning a new setup or exploring solar power for an existing '
                  'mill, share your machine capacity, location and daily operating needs with us to '
                  'discuss system options and pricing.',
                  style: AppTypography.bodySmall.copyWith(height: 1.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          HomeButton(label: 'Discuss Your Atta Chakki Project', onPressed: onDiscuss),
        ],
      ),
    );
  }
}

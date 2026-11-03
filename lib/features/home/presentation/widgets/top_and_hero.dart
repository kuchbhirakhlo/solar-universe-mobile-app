import 'package:flutter/material.dart';
import '../../../../core/constants/app_color_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/launcher_helper.dart';
import '../../domain/home_content.dart';
import 'home_common.dart';

/// The website's `.su-topbar`: phone numbers, WhatsApp, email.
class ContactTopBar extends StatelessWidget {
  const ContactTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.labelMedium.copyWith(
      color: AppColorConstants.inkText,
      fontSize: 11,
      letterSpacing: 0.2,
    );
    return Container(
      width: double.infinity,
      color: AppColorConstants.topBarBg,
      padding: const EdgeInsets.symmetric(horizontal: kHomeHPad, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(Icons.phone_rounded, size: 14, color: AppColors.accent),
            const SizedBox(width: 6),
            for (var i = 0; i < HomeContent.phones.length; i++) ...[
              if (i > 0) Text('  /  ', style: style),
              InkWell(
                onTap: () => LauncherHelper.call('+91${HomeContent.phones[i]}'),
                child: Text(HomeContent.phones[i], style: style),
              ),
            ],
            const SizedBox(width: 14),
            InkWell(
              onTap: () => LauncherHelper.whatsapp(HomeContent.whatsappNumber),
              child: Text('WhatsApp ↗', style: style.copyWith(color: AppColors.accent)),
            ),
            const SizedBox(width: 14),
            const Icon(Icons.mail_outline_rounded, size: 14, color: AppColors.accent),
            const SizedBox(width: 6),
            InkWell(
              onTap: () => LauncherHelper.email('asarvindshl1@gmail.com'),
              child: Text('asarvindshl1@gmail.com', style: style),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hero, matching the website: Unsplash photo under a dark-green gradient,
/// tag, two-tone H1, "15+ years" H2, body, two CTAs, subsidy link.
class HeroSection extends StatelessWidget {
  final String badge;
  final String headline;
  final int experienceYears;
  final VoidCallback onQuote;
  final VoidCallback onSubsidy;

  const HeroSection({
    super.key,
    required this.badge,
    required this.headline,
    required this.experienceYears,
    required this.onQuote,
    required this.onSubsidy,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/solar_universe_hero.jpg', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0, 0.42, 1],
                colors: [
                  const Color(0xFF0F251C).withOpacity(0.95),
                  const Color(0xFF12261D).withOpacity(0.86),
                  const Color(0xFF11251C).withOpacity(0.55),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(kHomeHPad, 40, kHomeHPad, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (badge.isNotEmpty) _HeroTag(text: badge),
              const SizedBox(height: 18),
              _HeroHeadline(headline: headline),
              const SizedBox(height: 18),
              Text(
                '$experienceYears+ Years of Professional Solar Experience',
                style: AppTypography.titleLarge.copyWith(
                  color: const Color(0xFFF3ECD6),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Solar Universe Enterprises provides complete end-to-end solar solutions for '
                'residential, commercial and industrial customers. With more than 5,000 kW of solar '
                'project experience, we provide professional support from consultation and system '
                'design to installation, commissioning and after-sales service.',
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFFD5DDD3),
                  fontSize: 12.5,
                  height: 1.85,
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  HomeButton(label: 'Get Free Solar Quote', onPressed: onQuote),
                  HomeButton(
                    label: 'WhatsApp Us',
                    glass: true,
                    showArrow: false,
                    onPressed: () => LauncherHelper.whatsapp(
                      HomeContent.whatsappNumber,
                      HomeContent.whatsappDefaultMessage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: onSubsidy,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wb_sunny_outlined, size: 16, color: Color(0xFFE9D7A0)),
                      const SizedBox(width: 8),
                      Text(
                        'Check Your Solar Subsidy',
                        style: AppTypography.labelLarge.copyWith(
                          color: const Color(0xFFE9D7A0),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 15, color: Color(0xFFE9D7A0)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Icon(Icons.verified_user_outlined, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    'End-to-End Solar Solutions',
                    style: AppTypography.labelMedium.copyWith(color: Colors.white70, fontSize: 11.5),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Uttar Pradesh · Bihar · Jharkhand',
                style: AppTypography.labelMedium.copyWith(color: Colors.white, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroTag extends StatelessWidget {
  final String text;

  const _HeroTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              color: const Color(0xFFEBF1D9),
              letterSpacing: 1.6,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

/// Splits the headline at " with " so the last clause renders in the website's
/// peach accent ("Smarter Solar Energy"); falls back to plain white text if the
/// copy ever loses that split point.
class _HeroHeadline extends StatelessWidget {
  final String headline;

  const _HeroHeadline({required this.headline});

  @override
  Widget build(BuildContext context) {
    final base = AppTypography.displayLarge.copyWith(
      color: Colors.white,
      fontSize: 36,
      fontWeight: FontWeight.w500,
      height: 1.15,
      letterSpacing: -1.4,
    );
    const splitWord = ' with ';
    final i = headline.indexOf(splitWord);
    if (i == -1) return Text(headline, style: base);
    final lead = headline.substring(0, i + splitWord.length - 1);
    final tail = headline.substring(i + splitWord.length);
    return RichText(
      text: TextSpan(
        style: base,
        children: [
          TextSpan(text: '$lead\n'),
          TextSpan(
            text: tail,
            style: const TextStyle(color: AppColorConstants.peachOnDark),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_color_constants.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/launcher_helper.dart';
import '../../domain/home_content.dart';
import 'home_common.dart';
import 'lead_form.dart';

/// Website "Serving Solar Customers Across Multiple States".
class ServiceAreaSection extends StatelessWidget {
  final VoidCallback onCheck;

  const ServiceAreaSection({super.key, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    Widget region(String name, String text) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: homeCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTypography.headlineSmall.copyWith(color: AppColorConstants.inkText)),
              const SizedBox(height: 4),
              Text(text, style: AppTypography.bodySmall),
            ],
          ),
        );
    return HomeSection(
      background: AppColorConstants.sectionLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Close to you. Ready to help.'),
          const SectionTitle('Serving Solar Customers Across Multiple States'),
          const SizedBox(height: 18),
          region('Uttar Pradesh', 'All major cities and districts'),
          region('Bihar', 'Residential, commercial and solar EPC enquiries'),
          region('Jharkhand', 'Residential, commercial and solar EPC enquiries'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in HomeContent.cities)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE0E6D9)),
                  ),
                  child: Text(
                    c,
                    style: AppTypography.labelMedium.copyWith(
                      color: const Color(0xFF617457),
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Looking for solar installation in your city?',
            style: AppTypography.titleLarge.copyWith(color: AppColorConstants.inkText),
          ),
          const SizedBox(height: 12),
          HomeButton(label: 'Check Service Availability', onPressed: onCheck),
        ],
      ),
    );
  }
}

/// Website "Our Office Locations".
class OfficesSection extends StatelessWidget {
  const OfficesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Meet your local solar team'),
          const SectionTitle('Our Office Locations'),
          const SizedBox(height: 18),
          for (final o in HomeContent.offices)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(20),
              decoration: homeCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          o.title,
                          style: AppTypography.titleLarge.copyWith(color: AppColorConstants.inkText),
                        ),
                      ),
                    ],
                  ),
                  if (o.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(o.subtitle!, style: AppTypography.labelMedium),
                  ],
                  const SizedBox(height: 8),
                  Text(o.address, style: AppTypography.bodyMedium.copyWith(height: 1.6)),
                  const SizedBox(height: 4),
                  HomeTextLink(
                    label: 'Open in Google Maps',
                    onTap: () => LauncherHelper.openMap(o.address),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Website `#contact`: call/WhatsApp, email, GSTIN + the full lead form.
class ContactSection extends StatelessWidget {
  final String gstin;

  const ContactSection({super.key, required this.gstin});

  @override
  Widget build(BuildContext context) {
    return HomeSection(
      background: AppColorConstants.sectionContact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Make the switch. Start a conversation.'),
          const SectionTitle('Start Your Solar Journey Today'),
          const SectionLead(
            'Talk to our solar team for a site assessment, system recommendation, subsidy '
            'information and customized quotation.',
          ),
          const SizedBox(height: 20),
          Text('CALL / WHATSAPP', style: AppTypography.labelSmall.copyWith(letterSpacing: 1.8)),
          const SizedBox(height: 6),
          for (final p in HomeContent.phones)
            Row(
              children: [
                InkWell(
                  onTap: () => LauncherHelper.call('+91$p'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      p,
                      style: AppTypography.headlineSmall.copyWith(color: AppColorConstants.inkText),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                HomeTextLink(
                  label: 'WhatsApp',
                  onTap: () => LauncherHelper.whatsapp('91$p', HomeContent.whatsappDefaultMessage),
                ),
              ],
            ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => LauncherHelper.email('asarvindshl1@gmail.com'),
            child: Text(
              'asarvindshl1@gmail.com',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 10),
          Text('GSTIN: $gstin', style: AppTypography.labelMedium),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: homeCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell us what you have in mind.',
                  style: AppTypography.headlineMedium.copyWith(color: AppColorConstants.inkText),
                ),
                const SizedBox(height: 4),
                Text(
                  'Our team will help you find the right solar solution.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 18),
                const LeadForm(
                  source: 'home_contact',
                  submitLabel: 'Request Free Solar Consultation',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Website footer block.
class HomeFooter extends StatelessWidget {
  final String gstin;

  const HomeFooter({super.key, required this.gstin});

  @override
  Widget build(BuildContext context) {
    final head = AppTypography.labelSmall.copyWith(color: const Color(0xFFC3DC9F), letterSpacing: 1.8);
    final body = AppTypography.bodySmall.copyWith(color: const Color(0xFFD5DDD3), height: 1.7);
    return Container(
      width: double.infinity,
      color: AppColorConstants.footerGreen,
      padding: const EdgeInsets.fromLTRB(kHomeHPad, 36, kHomeHPad, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset('assets/images/solar_universe_logo_tight.png', height: 64),
          ),
          const SizedBox(height: 14),
          Text('Solar EPC | Residential | Commercial | Industrial', style: body),
          Text('15+ Years Professional Solar Experience', style: body),
          const SizedBox(height: 4),
          Text(
            'Clean energy. Lasting possibilities.',
            style: AppTypography.labelMedium.copyWith(color: const Color(0xFFDBAB73)),
          ),
          const SizedBox(height: 24),
          Text('GET IN TOUCH', style: head),
          const SizedBox(height: 6),
          for (final p in HomeContent.phones)
            InkWell(
              onTap: () => LauncherHelper.call('+91$p'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(p, style: body),
              ),
            ),
          Text('asarvindshl1@gmail.com', style: body),
          Text('GSTIN: $gstin', style: body),
          const SizedBox(height: 22),
          Text('FIND US', style: head),
          const SizedBox(height: 6),
          Text('1/60, Vibhav Khand, Gomti Nagar,\nLucknow – 226010', style: body),
          Text('Branch Offices: Mirzapur | Jaunpur', style: body),
          Text('Uttar Pradesh | Bihar | Jharkhand', style: body),
          const SizedBox(height: 22),
          const Divider(color: Color(0x33FFFFFF)),
          const SizedBox(height: 8),
          Text('© ${DateTime.now().year} Solar Universe Enterprises', style: body),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => context.push(RouteNames.staffLogin),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Staff Login',
                style: body.copyWith(decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The website's floating "Let's talk solar" WhatsApp pill; icon-only on mobile.
class FloatingWhatsApp extends StatelessWidget {
  const FloatingWhatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColorConstants.whatsappGreen,
      shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 3)),
      elevation: 6,
      shadowColor: const Color(0x4D15341C),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => LauncherHelper.whatsapp(
          HomeContent.whatsappNumber,
          HomeContent.whatsappDefaultMessage,
        ),
        child: const SizedBox(
          width: 54,
          height: 54,
          child: Icon(Icons.chat_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// All color values used in the app as a single source of truth.
/// Semantic aliases reference the raw hex values defined here.
///
/// Palette matches the real reference site, https://thesolaruniverse.vercel.app/
/// (scraped via computed styles, not guessed from the logo): forest green
/// from its dark hero/section backgrounds (#25362e / #203e2e) and stat/accent
/// text (#28754b), warm orange from its primary CTA buttons (#ed7627), and a
/// cream page background (#fafaf5). The previous palette here (navy/red)
/// was copied from the wrong reference site during an earlier clone and
/// never actually matched Solar Universe Enterprises' own branding.
class AppColorConstants {
  AppColorConstants._();

  // ─── Raw Palette ─────────────────────────────────────────────────────────────

  // Brand Orange (primary CTA, from the site's own buttons/badges)
  static const Color orange500 = Color(0xFFF2924F);
  static const Color orange600 = Color(0xFFED7627);
  static const Color orange700 = Color(0xFFC85F1A);
  static const Color orangeContainer = Color(0xFFFDECDF);

  // Forest Green (dark hero/section backgrounds, stat numbers, accents)
  static const Color forestGreen900 = Color(0xFF1E2E24);
  static const Color forestGreen800 = Color(0xFF25362E);
  static const Color forestGreen700 = Color(0xFF203E2E);
  static const Color forestGreen500 = Color(0xFF28754B);
  static const Color forestGreenContainer = Color(0xFFE3F0E8);

  // Cream (page background, matches the site's off-white sections)
  static const Color cream50 = Color(0xFFFAFAF5);
  static const Color cream100 = Color(0xFFF5F7F0);

  // Homepage section palette (computed styles from the redesigned website's
  // SolarHomepage.css): alternating section backgrounds, dark/footer greens,
  // and the accent tones used on dark surfaces.
  static const Color sectionLight = Color(0xFFF7F9F5);
  static const Color sectionSubsidy = Color(0xFFFAFAF5);
  static const Color sectionCalc = Color(0xFFEDF3E8);
  static const Color sectionContact = Color(0xFFF5F7F0);
  static const Color sectionAward = Color(0xFFF7F4EB);
  static const Color topBarBg = Color(0xFFF1F5ED);
  static const Color footerGreen = Color(0xFF1C3025);
  static const Color subsidyCardGreen = Color(0xFF26734A);
  static const Color amberOnDark = Color(0xFFFFCA87);
  static const Color peachOnDark = Color(0xFFF6A554);
  static const Color whatsappGreen = Color(0xFF278749);
  static const Color cardBorder = Color(0xFFE2E7DD);
  static const Color inkText = Color(0xFF25312B);
  static const Color mutedText = Color(0xFF6D766F);

  // Neutrals / Backgrounds
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF5F7FA);
  static const Color gray100 = Color(0xFFEEF1F5);
  static const Color gray200 = Color(0xFFE2E5EA);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray900 = Color(0xFF111827);
  static const Color black = Color(0xFF000000);

  // Status
  static const Color red500 = Color(0xFFDC2626);
  static const Color redContainer = Color(0xFFFDECEC);
  static const Color green500 = Color(0xFF1B7A3D);
  static const Color greenContainer = Color(0xFFE6F4EA);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amberContainer = Color(0xFFFEF3E0);

  // ─── Semantic Aliases ─────────────────────────────────────────────────────────

  // Backgrounds
  static const Color background = cream50;
  static const Color surface = white;
  static const Color card = white;
  static const Color cardElevated = cream100;

  // Brand
  static const Color primary = orange600;
  static const Color primaryLight = orange500;
  static const Color primaryDark = orange700;
  static const Color primaryContainer = orangeContainer;

  static const Color brandYellow = orange500;
  static const Color brandYellowLight = Color(0xFFF7B37E);
  static const Color brandYellowDark = orange700;

  // Accent (secondary brand color — forest green, from the site's stat/badge text)
  static const Color accent = forestGreen500;
  static const Color accentContainer = forestGreenContainer;
  static const Color secondaryNavy = forestGreen800;

  // Status / Feedback
  static const Color success = green500;
  static const Color successContainer = greenContainer;
  static const Color error = red500;
  static const Color errorContainer = redContainer;
  static const Color warning = amber500;
  static const Color warningContainer = amberContainer;
  static const Color info = orange600;
  static const Color infoContainer = orangeContainer;

  // Text
  static const Color textPrimary = forestGreen900;
  static const Color textHeading = forestGreen900;
  static const Color textSecondary = Color(0xFF5C665A);
  static const Color textTertiary = Color(0xFF8B9186);
  static const Color textOnBrand = white;
  static const Color textDisabled = gray300;

  // Borders / Dividers
  static const Color border = gray200;
  static const Color borderLight = gray100;
  static const Color divider = gray100;

  // ─── Gradients ────────────────────────────────────────────────────────────────

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [forestGreen700, forestGreen800],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange600, orange700],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [white, cream100],
  );
}

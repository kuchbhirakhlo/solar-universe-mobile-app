import 'package:flutter/material.dart';
import '../../../../core/constants/app_color_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Shared building blocks for the homepage sections — keeps each section file
/// focused on its own content and mirrors the website's `.su-*` CSS classes.

const double kHomeHPad = 22;
const double kCardRadius = 9;
const double kButtonRadius = 5;

/// A full-width section with the website's alternating background + padding.
class HomeSection extends StatelessWidget {
  final Color? background;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const HomeSection({
    super.key,
    this.background,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: kHomeHPad, vertical: 44),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: background ?? Colors.white,
      padding: padding,
      child: child,
    );
  }
}

class Eyebrow extends StatelessWidget {
  final String text;
  final Color? color;

  const Eyebrow(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: color ?? AppColors.accent,
          letterSpacing: 2,
          fontSize: 10,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign align;

  const SectionTitle(this.text, {super.key, this.color, this.align = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: AppTypography.headlineLarge.copyWith(
        color: color ?? AppColorConstants.inkText,
        fontSize: 26,
        height: 1.25,
        letterSpacing: -0.8,
      ),
    );
  }
}

class SectionLead extends StatelessWidget {
  final String text;
  final Color? color;

  const SectionLead(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: AppTypography.bodyMedium.copyWith(
          color: color ?? AppColorConstants.mutedText,
          height: 1.7,
        ),
      ),
    );
  }
}

/// The website's `.su-button`: orange fill, white text, trailing arrow.
class HomeButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool glass;
  final bool fullWidth;
  final bool loading;
  final bool showArrow;

  const HomeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.glass = false,
    this.fullWidth = false,
    this.loading = false,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color border;
    if (glass) {
      bg = Colors.white.withOpacity(0.05);
      fg = Colors.white;
      border = Colors.white.withOpacity(0.36);
    } else if (secondary) {
      bg = Colors.white;
      fg = AppColors.accent;
      border = const Color(0xFFD6DFD7);
    } else {
      bg = AppColors.primary;
      fg = Colors.white;
      border = AppColors.primary;
    }
    final button = Material(
      color: bg,
      borderRadius: BorderRadius.circular(kButtonRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(kButtonRadius),
        onTap: loading ? null : onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kButtonRadius),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                )
              else ...[
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.labelLarge.copyWith(
                      color: fg,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (showArrow) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.north_east_rounded, size: 16, color: fg),
                ],
              ],
            ],
          ),
        ),
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// The website's green text link with a trailing arrow.
class HomeTextLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final IconData icon;

  const HomeTextLink({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.icon = Icons.north_east_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accent;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: c,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, size: 15, color: c),
          ],
        ),
      ),
    );
  }
}

BoxDecoration homeCardDecoration({Color? color, Color? border}) => BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(kCardRadius),
      border: Border.all(color: border ?? AppColorConstants.cardBorder),
    );

/// Indian digit grouping for rupee figures, e.g. 520000 -> 5,20,000.
String inr(num value) {
  final s = value.round().toString();
  if (s.length <= 3) return s;
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

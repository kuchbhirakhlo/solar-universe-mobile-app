import 'package:flutter/material.dart';
import '../constants/app_color_constants.dart';

/// Convenience alias — all values delegate to [AppColorConstants].
/// Use [AppColorConstants] directly for raw palette access,
/// or [AppColors] as a shorthand in UI code.
class AppColors {
  AppColors._();

  // Background
  static const Color background = AppColorConstants.background;
  static const Color surface = AppColorConstants.surface;
  static const Color card = AppColorConstants.card;
  static const Color cardElevated = AppColorConstants.cardElevated;

  // Brand
  static const Color primary = AppColorConstants.primary;
  static const Color primaryLight = AppColorConstants.primaryLight;
  static const Color primaryDark = AppColorConstants.primaryDark;
  static const Color primaryContainer = AppColorConstants.primaryContainer;

  static const Color brandYellow = AppColorConstants.brandYellow;
  static const Color brandYellowLight = AppColorConstants.brandYellowLight;
  static const Color brandYellowDark = AppColorConstants.brandYellowDark;

  // Accent
  static const Color accent = AppColorConstants.accent;
  static const Color accentContainer = AppColorConstants.accentContainer;
  static const Color secondaryNavy = AppColorConstants.secondaryNavy;

  // Success
  static const Color success = AppColorConstants.success;
  static const Color successContainer = AppColorConstants.successContainer;

  // Error
  static const Color error = AppColorConstants.error;
  static const Color errorContainer = AppColorConstants.errorContainer;

  // Warning
  static const Color warning = AppColorConstants.warning;
  static const Color warningContainer = AppColorConstants.warningContainer;

  // Info
  static const Color info = AppColorConstants.info;
  static const Color infoContainer = AppColorConstants.infoContainer;

  // Text
  static const Color textPrimary = AppColorConstants.textPrimary;
  static const Color textHeading = AppColorConstants.textHeading;
  static const Color textSecondary = AppColorConstants.textSecondary;
  static const Color textTertiary = AppColorConstants.textTertiary;
  static const Color textOnBrand = AppColorConstants.textOnBrand;
  static const Color textDisabled = AppColorConstants.textDisabled;

  // Borders
  static const Color border = AppColorConstants.border;
  static const Color borderLight = AppColorConstants.borderLight;
  static const Color divider = AppColorConstants.divider;

  // Gradients
  static const LinearGradient heroGradient = AppColorConstants.heroGradient;
  static const LinearGradient primaryGradient = AppColorConstants.primaryGradient;
  static const LinearGradient cardGradient = AppColorConstants.cardGradient;
}

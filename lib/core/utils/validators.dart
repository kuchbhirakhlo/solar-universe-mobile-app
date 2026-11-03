import '../constants/app_strings.dart';

class Validators {
  Validators._();

  static final RegExp _indianMobile = RegExp(r'^[6-9]\d{9}$');

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.errorNameRequired;
    if (value.trim().length < 3) return AppStrings.errorNameTooShort;
    return null;
  }

  static String? mobile(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.errorMobileRequired;
    final digits = value.trim().replaceAll(RegExp(r'\D'), '');
    if (!_indianMobile.hasMatch(digits)) return AppStrings.errorMobileInvalid;
    return null;
  }

  static String? city(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.errorCityRequired;
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }
}

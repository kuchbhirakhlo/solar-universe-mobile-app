import 'package:url_launcher/url_launcher.dart';

class LauncherHelper {
  LauncherHelper._();

  static Future<void> call(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(uri);
  }

  static Future<void> email(String address) async {
    final uri = Uri(scheme: 'mailto', path: address);
    await launchUrl(uri);
  }

  static Future<void> openMap(String query) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// [number] is digits with country code, e.g. `917607237555`.
  static Future<void> whatsapp(String number, [String? message]) async {
    final query = message == null ? '' : '?text=${Uri.encodeComponent(message)}';
    await openUrl('https://wa.me/$number$query');
  }

  static Future<void> openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

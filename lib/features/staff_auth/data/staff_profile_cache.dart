import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/staff_model.dart';

/// Last successfully loaded staff profile, so a restored session still works
/// when the app is opened with no connectivity (field staff) — the Firebase
/// Auth user persists on its own, but the `staff/{uid}` doc needs a network
/// read. Only ever used as a fallback for transient read errors.
class StaffProfileCache {
  StaffProfileCache._();

  static const String _key = 'staff_profile_cache';

  static Future<void> save(StaffModel staff) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({
        'id': staff.id,
        'employeeId': staff.employeeId,
        'name': staff.name,
        'phone': staff.phone,
        'email': staff.email,
        'role': staff.role,
      }),
    );
  }

  static Future<StaffModel?> load(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['id'] != uid) return null;
      return StaffModel.fromMap(uid, map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

import 'package:flutter/foundation.dart';
import '../../features/staff_auth/domain/entities/staff_entity.dart';

/// Holds the signed-in staff member for the current app session. Injected
/// into go_router as a `refreshListenable` so route guards react
/// immediately to sign-in/sign-out, and used across the staff feature for
/// quick access to "who is logged in" without re-fetching Firestore.
class StaffSession extends ChangeNotifier {
  StaffEntity? _current;

  StaffEntity? get current => _current;
  bool get isSignedIn => _current != null;

  void setStaff(StaffEntity? staff) {
    if (_current == staff) return;
    _current = staff;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import '../../features/customer_auth/domain/entities/customer_entity.dart';

/// Holds the signed-in customer for the current app session. Injected into
/// go_router as part of a merged `refreshListenable` (alongside
/// [StaffSession]) so route guards react immediately to sign-in/out.
///
/// Unlike [StaffSession] (a single nullable field — a Firebase Auth account
/// only ever exists here for someone with a matching `staff` doc already),
/// this has two independent nullable fields: phone verification and profile
/// creation are separate steps, so "verified, no profile yet" is a real,
/// possibly-persisted-across-restarts state.
class CustomerSession extends ChangeNotifier {
  String? _verifiedMobile;
  CustomerEntity? _profile;

  String? get verifiedMobile => _verifiedMobile;
  CustomerEntity? get profile => _profile;
  bool get isVerified => _verifiedMobile != null;
  bool get hasProfile => _profile != null;

  void setVerified(String? mobile) {
    if (_verifiedMobile == mobile) return;
    _verifiedMobile = mobile;
    notifyListeners();
  }

  void setProfile(CustomerEntity? profile) {
    if (_profile == profile) return;
    _profile = profile;
    notifyListeners();
  }

  void clear() {
    if (_verifiedMobile == null && _profile == null) return;
    _verifiedMobile = null;
    _profile = null;
    notifyListeners();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/staff_restore_policy.dart';
import '../models/staff_model.dart';
import '../staff_profile_cache.dart';

abstract class StaffAuthDataSource {
  Future<StaffModel> signIn(String employeeId, String password);
  Future<void> signOut();
  Future<StaffModel?> getCurrentStaff();
}

/// Thrown when the signed-in Auth user has no matching `staff/{uid}` document
/// — distinct from a network/permission error, which must not end a session.
class StaffProfileMissingException implements Exception {
  const StaffProfileMissingException();

  @override
  String toString() => 'Staff profile not found';
}

class StaffAuthDataSourceImpl implements StaffAuthDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  StaffAuthDataSourceImpl(this.firebaseAuth, this.firestore);

  String _syntheticEmail(String employeeId) =>
      '${employeeId.trim().toLowerCase()}@${AppStrings.staffAuthEmailDomain}';

  Future<StaffModel> _fetchStaffDoc(String uid) async {
    final doc = await firestore.collection('staff').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      throw const StaffProfileMissingException();
    }
    return StaffModel.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<StaffModel> signIn(String employeeId, String password) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: _syntheticEmail(employeeId),
      password: password,
    );
    final uid = credential.user?.uid;
    if (uid == null) throw Exception('Sign-in failed');
    try {
      final staff = await _fetchStaffDoc(uid);
      await StaffProfileCache.save(staff);
      return staff;
    } catch (_) {
      // Authenticated but no matching staff profile — don't leave a dangling session.
      await firebaseAuth.signOut();
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await StaffProfileCache.clear();
    await firebaseAuth.signOut();
  }

  /// Restores a persisted staff session. Firebase Auth keeps the user across
  /// app restarts; this re-reads the profile so the in-memory StaffSession can
  /// be rebuilt. Rules:
  ///  - a non-staff user (e.g. a phone-OTP customer) is ignored, never signed out;
  ///  - only a *definitively missing* staff doc ends the session;
  ///  - any other error (offline, timeout) keeps the session, using the cached
  ///    profile if there is one.
  @override
  Future<StaffModel?> getCurrentStaff() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    if (!isStaffAuthUser(user.email, AppStrings.staffAuthEmailDomain)) return null;
    try {
      final staff = await _fetchStaffDoc(user.uid);
      await StaffProfileCache.save(staff);
      return staff;
    } on StaffProfileMissingException {
      await signOut();
      return null;
    } catch (_) {
      return StaffProfileCache.load(user.uid);
    }
  }
}

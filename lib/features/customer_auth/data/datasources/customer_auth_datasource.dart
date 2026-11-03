import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/customer_auth_repository.dart';
import '../models/customer_model.dart';

abstract class CustomerAuthDataSource {
  /// Starts phone verification. Returns the `verificationId` once a code has
  /// been sent, unless Android's SMS Retriever auto-verifies instantly first
  /// — in that case [onAutoVerified] fires (having already signed in and
  /// looked up any existing profile) and the returned Future never resolves
  /// with a normal verificationId the caller needs to act on.
  Future<String> sendOtp({
    required String mobile,
    required void Function(CustomerModel? profile) onAutoVerified,
  });

  Future<User> confirmOtp({required String verificationId, required String smsCode});

  Future<CustomerModel?> findProfileByMobile(String mobile);

  Future<CustomerModel> createProfile(NewCustomerProfile profile);

  /// The verified phone number (bare 10-digit) for the currently signed-in
  /// Firebase Auth user, or null if no one is signed in.
  String? get currentVerifiedMobile;

  Future<CustomerModel?> getCurrentProfile();

  Future<void> signOut();
}

class CustomerAuthDataSourceImpl implements CustomerAuthDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  CustomerAuthDataSourceImpl(this.firebaseAuth, this.firestore);

  /// India-only for now (matches [Validators.mobile] and every other bare
  /// 10-digit phone field already in this schema) — bare digits in, E.164
  /// out. This is the *only* place in the app that deals with E.164.
  static String _toE164(String bareMobile) {
    final digits = bareMobile.replaceAll(RegExp(r'\D'), '');
    return '+91$digits';
  }

  /// Takes the last 10 digits of whatever Firebase Auth hands back
  /// (`+919988770099`) so it matches the bare 10-digit format every
  /// `customers`/`staff` doc already stores `mobile` as.
  static String _toBare(String e164) {
    final digits = e164.replaceAll(RegExp(r'\D'), '');
    return digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  }

  @override
  Future<String> sendOtp({
    required String mobile,
    required void Function(CustomerModel? profile) onAutoVerified,
  }) async {
    final completer = Completer<String>();
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: _toE164(mobile),
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        // Android SMS Retriever auto-verified without the user typing
        // anything — sign in directly and skip the OTP-entry screen.
        try {
          await firebaseAuth.signInWithCredential(credential);
          onAutoVerified(await findProfileByMobile(mobile));
        } catch (_) {
          // Let the normal code-entry flow proceed rather than losing the
          // user silently — codeSent should still fire separately.
        }
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (verificationId, resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
    );
    return completer.future;
  }

  @override
  Future<User> confirmOtp({required String verificationId, required String smsCode}) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await firebaseAuth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) throw Exception('Sign-in failed');
    return user;
  }

  @override
  Future<CustomerModel?> findProfileByMobile(String mobile) async {
    final snap = await firestore
        .collection('customers')
        .where('mobile', isEqualTo: mobile)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return CustomerModel.fromMap(snap.docs.first.id, snap.docs.first.data());
  }

  @override
  Future<CustomerModel> createProfile(NewCustomerProfile profile) async {
    final docRef = firestore.collection('customers').doc();
    final data = {
      'name': profile.name,
      'mobile': profile.mobile,
      'email': profile.email,
      'address': profile.address,
      'systemType': profile.systemType,
      'capacity': profile.capacity,
      // Self-registered profiles start at 'Pending' — staff-created ones
      // (via the Staff Customers feature) default to 'In Progress' instead;
      // that convention is untouched.
      'installationStatus': 'Pending',
      'documents': <String, dynamic>{},
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    await docRef.set(data);
    return CustomerModel.fromMap(docRef.id, data);
  }

  @override
  String? get currentVerifiedMobile {
    final phone = firebaseAuth.currentUser?.phoneNumber;
    return phone == null ? null : _toBare(phone);
  }

  @override
  Future<CustomerModel?> getCurrentProfile() async {
    final mobile = currentVerifiedMobile;
    if (mobile == null) return null;
    return findProfileByMobile(mobile);
  }

  @override
  Future<void> signOut() => firebaseAuth.signOut();
}

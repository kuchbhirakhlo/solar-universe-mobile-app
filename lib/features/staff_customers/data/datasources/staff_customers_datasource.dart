import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import '../../domain/repositories/staff_customers_repository.dart';
import '../models/staff_customer_model.dart';

abstract class StaffCustomersDataSource {
  Future<List<StaffCustomerModel>> getCustomers({required String staffId});

  /// A locally-generated Firestore doc ID, reserved before the customer doc
  /// exists — lets the Create Customer screen upload each document to its
  /// final Storage/Firestore path as soon as it's picked, instead of staging
  /// everything locally and uploading it all only when Register is pressed.
  String reserveCustomerId();

  /// Writes the customer's metadata onto [customerId] — a doc that may
  /// already have `documents.*` fields populated by earlier [uploadDocument]
  /// calls (merged, not overwritten). This is the only write Register needs
  /// to make, since every document was already uploaded as it was picked.
  Future<void> createCustomer(
    NewStaffCustomer customer, {
    required String customerId,
    required String staffId,
  });
  Future<void> uploadDocument({
    required String customerId,
    required String docType,
    required String filePath,
    required bool multi,
  });
}

class StaffCustomersDataSourceImpl implements StaffCustomersDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  StaffCustomersDataSourceImpl(this.firestore, this.storage);

  @override
  Future<List<StaffCustomerModel>> getCustomers({required String staffId}) async {
    final snap = await firestore
        .collection('customers')
        .where('createdByStaffId', isEqualTo: staffId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => StaffCustomerModel.fromMap(d.id, d.data())).toList();
  }

  @override
  String reserveCustomerId() => firestore.collection('customers').doc().id;

  @override
  Future<void> createCustomer(
    NewStaffCustomer customer, {
    required String customerId,
    required String staffId,
  }) async {
    // merge: true — this doc may already exist with `documents.*` fields set
    // by uploadDocument() calls made while the form was being filled in.
    await firestore.collection('customers').doc(customerId).set({
      'name': customer.name,
      'mobile': customer.mobile,
      'email': customer.email,
      'address': customer.address,
      'systemType': customer.systemType,
      'capacity': customer.capacity,
      'installationStatus': 'In Progress',
      'createdByStaffId': staffId,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> uploadDocument({
    required String customerId,
    required String docType,
    required String filePath,
    required bool multi,
  }) async {
    // Always attempted — if Storage/Blaze billing isn't enabled yet, this
    // throws and the repository's try/catch turns it into a Left(Failure)
    // for just this one document (doesn't touch createCustomer(), a
    // separate call). The moment Blaze is enabled, the exact same call
    // starts succeeding with no code change needed. See
    // AppConfig.storageUploadsEnabled for what that flag actually still
    // controls (UI-only, not this).
    final file = File(filePath);
    final ext = p.extension(filePath);
    final ref = storage.ref(
      'customers/$customerId/$docType-${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    // set(merge: true) instead of update() — this may be the very first
    // write for a customer doc that doesn't exist yet (eager upload, before
    // Register is pressed), as well as an update to an existing customer's
    // documents from the detail screen. update() would throw not-found for
    // the former case.
    if (multi) {
      await firestore.collection('customers').doc(customerId).set({
        'documents': {
          docType: FieldValue.arrayUnion([url]),
        },
      }, SetOptions(merge: true));
    } else {
      await firestore.collection('customers').doc(customerId).set({
        'documents': {docType: url},
      }, SetOptions(merge: true));
    }
  }
}

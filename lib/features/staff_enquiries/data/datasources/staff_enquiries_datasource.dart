import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import '../../domain/enquiry_stages.dart';
import '../../domain/repositories/staff_enquiries_repository.dart';
import '../models/staff_enquiry_model.dart';

abstract class StaffEnquiriesDataSource {
  Future<List<StaffEnquiryModel>> getEnquiries({required String staffId});
  Future<void> createEnquiry(NewStaffEnquiry enquiry, {required String staffId, required String staffName});
  Future<void> updateEnquiryStatus({
    required String enquiryId,
    required String status,
    required String remark,
    required String updatedBy,
  });
}

class StaffEnquiriesDataSourceImpl implements StaffEnquiriesDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  StaffEnquiriesDataSourceImpl(this.firestore, this.storage);

  @override
  Future<List<StaffEnquiryModel>> getEnquiries({required String staffId}) async {
    final snap = await firestore
        .collection('enquiries')
        .where('createdByStaffId', isEqualTo: staffId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => StaffEnquiryModel.fromMap(d.id, d.data())).toList();
  }

  @override
  Future<void> createEnquiry(
    NewStaffEnquiry enquiry, {
    required String staffId,
    required String staffName,
  }) async {
    final docRef = firestore.collection('enquiries').doc();

    // Site photo is optional — only upload if the staff member attached one.
    // Deliberately wrapped in its own try/catch, separate from the rest of
    // this method: unlike a standalone upload call (staff_customers,
    // staff_service_requests), this one is embedded inside a larger
    // operation — an uncaught Storage failure here (e.g. Blaze billing not
    // enabled yet) would otherwise abort the whole enquiry creation below,
    // silently losing the lead. Any upload failure just means no photo
    // attached; the enquiry itself always still gets created. Once Blaze is
    // enabled, this starts succeeding automatically, no app update needed.
    String? sitePhotoUrl;
    final sitePhoto = enquiry.sitePhoto;
    if (sitePhoto != null) {
      try {
        final ext = p.extension(sitePhoto.name);
        final photoRef = storage.ref('enquiries/${docRef.id}/sitePhoto$ext');
        await photoRef.putFile(File(sitePhoto.path));
        sitePhotoUrl = await photoRef.getDownloadURL();
      } catch (_) {
        sitePhotoUrl = null;
      }
    }

    final createdAt = DateTime.now().toUtc().toIso8601String();
    // Same seeding as the CRM's addEnquiry (db.ts): the latest remark is the
    // initial message, and history starts with a creation entry.
    final firstRemark = enquiry.message.trim().isEmpty ? 'Logged by $staffName' : enquiry.message.trim();

    await docRef.set({
      'name': enquiry.name,
      'phone': enquiry.phone,
      'city': enquiry.city,
      'solarType': enquiry.solarType,
      'capacity': enquiry.capacity,
      'message': enquiry.message,
      'salesType': enquiry.salesType,
      'status': EnquiryStages.initial,
      'remark': firstRemark,
      'statusHistory': [
        {
          'status': EnquiryStages.initial,
          'remark': firstRemark,
          'updatedBy': staffName,
          'updatedAt': createdAt,
        },
      ],
      'createdByStaffId': staffId,
      'createdByStaffName': staffName,
      // Self-assigned at creation — matches the real CRM data, where a
      // staff-created enquiry's assignedStaffId/Name equal the creator's
      // until someone reassigns it (no reassignment UI in this app).
      'assignedStaffId': staffId,
      'assignedStaffName': staffName,
      if (sitePhotoUrl != null) 'sitePhotoUrl': sitePhotoUrl,
      'enquiryDateTime': enquiry.enquiryDateTime.toIso8601String(),
      'createdAt': createdAt,
    });
  }

  /// Mirrors the CRM's `updateEnquiryStatus` (db.ts): sets status + latest
  /// remark and appends to `statusHistory` with an ISO `updatedAt`. Never
  /// touches the assignment fields (sales staff can't reassign in the CRM).
  @override
  Future<void> updateEnquiryStatus({
    required String enquiryId,
    required String status,
    required String remark,
    required String updatedBy,
  }) async {
    await firestore.collection('enquiries').doc(enquiryId).update({
      'status': status,
      'remark': remark,
      'statusHistory': FieldValue.arrayUnion([
        {
          'status': status,
          'remark': remark,
          'updatedBy': updatedBy,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        },
      ]),
    });
  }
}

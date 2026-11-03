import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import '../../domain/entities/enquiry_status_entry.dart';
import '../../domain/entities/staff_enquiry_entity.dart';

class StaffEnquiryModel extends StaffEnquiryEntity {
  const StaffEnquiryModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.city,
    required super.solarType,
    required super.capacity,
    required super.message,
    required super.status,
    required super.salesType,
    super.createdByStaffId,
    super.createdByStaffName,
    super.assignedStaffId,
    super.assignedStaffName,
    super.sitePhotoUrl,
    super.enquiryDateTime,
    required super.createdAt,
    super.remark,
    super.statusHistory,
  });

  factory StaffEnquiryModel.fromMap(String id, Map<String, dynamic> map) {
    return StaffEnquiryModel(
      id: id,
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      city: map['city'] as String? ?? '',
      solarType: map['solarType'] as String? ?? '',
      capacity: map['capacity'] as String? ?? '',
      message: map['message'] as String? ?? '',
      status: map['status'] as String? ?? 'New',
      // 'salesType' is the real CRM field name; 'enquiryType' is the older
      // name this app wrote before this field was aligned with the CRM
      // schema — fall back to it for enquiries created before that change.
      salesType: map['salesType'] as String? ?? map['enquiryType'] as String? ?? 'Telecaller',
      createdByStaffId: map['createdByStaffId'] as String?,
      createdByStaffName: map['createdByStaffName'] as String? ?? map['preparedBy'] as String?,
      assignedStaffId: map['assignedStaffId'] as String?,
      assignedStaffName: map['assignedStaffName'] as String?,
      sitePhotoUrl: map['sitePhotoUrl'] as String?,
      enquiryDateTime: map['enquiryDateTime'] as String?,
      createdAt: map['createdAt'] as String? ?? '',
      remark: map['remark'] as String?,
      statusHistory: _parseHistory(map['statusHistory']),
    );
  }

  /// Tolerant of old docs (no field), and of `updatedAt` being a Firestore
  /// Timestamp instead of the ISO string the CRM and this app write.
  static List<EnquiryStatusEntry> _parseHistory(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((e) {
      final at = e['updatedAt'];
      return EnquiryStatusEntry(
        status: e['status']?.toString() ?? '',
        remark: e['remark']?.toString() ?? '',
        updatedBy: e['updatedBy']?.toString() ?? '',
        updatedAt: at is Timestamp
            ? at.toDate().toUtc().toIso8601String()
            : at?.toString() ?? '',
      );
    }).toList();
  }
}

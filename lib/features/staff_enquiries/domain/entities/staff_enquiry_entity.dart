import 'package:equatable/equatable.dart';
import 'enquiry_status_entry.dart';

class StaffEnquiryEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String city;
  final String solarType;
  final String capacity;
  final String message;
  final String status;
  final String salesType; // 'Telecaller' | 'Field Salesman'
  final String? createdByStaffId;
  final String? createdByStaffName;
  final String? assignedStaffId;
  final String? assignedStaffName;
  final String? sitePhotoUrl;
  final String? enquiryDateTime;
  final String createdAt;
  final String? remark;
  final List<EnquiryStatusEntry> statusHistory;

  const StaffEnquiryEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    required this.solarType,
    required this.capacity,
    required this.message,
    required this.status,
    required this.salesType,
    this.createdByStaffId,
    this.createdByStaffName,
    this.assignedStaffId,
    this.assignedStaffName,
    this.sitePhotoUrl,
    this.enquiryDateTime,
    required this.createdAt,
    this.remark,
    this.statusHistory = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        city,
        solarType,
        capacity,
        message,
        status,
        salesType,
        createdByStaffId,
        createdByStaffName,
        assignedStaffId,
        assignedStaffName,
        sitePhotoUrl,
        enquiryDateTime,
        createdAt,
        remark,
        statusHistory,
      ];
}

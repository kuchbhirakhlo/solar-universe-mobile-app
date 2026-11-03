import 'package:equatable/equatable.dart';
import '../../domain/repositories/staff_enquiries_repository.dart';

abstract class StaffEnquiriesEvent extends Equatable {
  const StaffEnquiriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffEnquiriesEvent extends StaffEnquiriesEvent {
  const LoadStaffEnquiriesEvent();
}

class SubmitStaffEnquiryEvent extends StaffEnquiriesEvent {
  final NewStaffEnquiry enquiry;
  const SubmitStaffEnquiryEvent(this.enquiry);

  @override
  List<Object?> get props => [enquiry];
}

class ResetSubmitStatusEvent extends StaffEnquiriesEvent {
  const ResetSubmitStatusEvent();
}

class UpdateEnquiryStatusEvent extends StaffEnquiriesEvent {
  final String enquiryId;
  final String status;
  final String remark;
  const UpdateEnquiryStatusEvent({
    required this.enquiryId,
    required this.status,
    required this.remark,
  });

  @override
  List<Object?> get props => [enquiryId, status, remark];
}

class ResetEnquiryActionEvent extends StaffEnquiriesEvent {
  const ResetEnquiryActionEvent();
}

import 'package:equatable/equatable.dart';

/// One row of an enquiry's `statusHistory` array — same shape the website CRM
/// writes (`types.ts` `StatusHistoryEntry`): updatedAt is an ISO-8601 string.
class EnquiryStatusEntry extends Equatable {
  final String status;
  final String remark;
  final String updatedBy;
  final String updatedAt;

  const EnquiryStatusEntry({
    required this.status,
    required this.remark,
    required this.updatedBy,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [status, remark, updatedBy, updatedAt];
}

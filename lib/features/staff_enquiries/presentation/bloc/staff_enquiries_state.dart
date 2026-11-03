import 'package:equatable/equatable.dart';
import '../../domain/entities/staff_enquiry_entity.dart';

enum ListStatus { initial, loading, success, failure }
enum SubmitStatus { initial, submitting, success, failure }
enum EnquiryActionStatus { idle, working, success, error }

class StaffEnquiriesState extends Equatable {
  final ListStatus listStatus;
  final List<StaffEnquiryEntity> enquiries;
  final String? listError;
  final SubmitStatus submitStatus;
  final String? submitError;
  final EnquiryActionStatus actionStatus;
  final String? actionError;

  const StaffEnquiriesState({
    this.listStatus = ListStatus.initial,
    this.enquiries = const [],
    this.listError,
    this.submitStatus = SubmitStatus.initial,
    this.submitError,
    this.actionStatus = EnquiryActionStatus.idle,
    this.actionError,
  });

  /// Freshest copy of one enquiry after a reload (the detail screen is pushed
  /// with a snapshot and must show the updated status/history after saving).
  StaffEnquiryEntity? byId(String id) {
    for (final e in enquiries) {
      if (e.id == id) return e;
    }
    return null;
  }

  StaffEnquiriesState copyWith({
    ListStatus? listStatus,
    List<StaffEnquiryEntity>? enquiries,
    String? listError,
    SubmitStatus? submitStatus,
    String? submitError,
    EnquiryActionStatus? actionStatus,
    String? actionError,
  }) {
    return StaffEnquiriesState(
      listStatus: listStatus ?? this.listStatus,
      enquiries: enquiries ?? this.enquiries,
      listError: listError,
      submitStatus: submitStatus ?? this.submitStatus,
      submitError: submitError,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [
        listStatus,
        enquiries,
        listError,
        submitStatus,
        submitError,
        actionStatus,
        actionError,
      ];
}

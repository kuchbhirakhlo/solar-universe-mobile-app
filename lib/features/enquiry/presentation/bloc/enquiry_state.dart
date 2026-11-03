import 'package:equatable/equatable.dart';

enum SubmitStatus { initial, submitting, success, failure }

class EnquiryState extends Equatable {
  final SubmitStatus enquiryStatus;
  final String? enquiryError;
  final SubmitStatus contactStatus;
  final String? contactError;

  const EnquiryState({
    this.enquiryStatus = SubmitStatus.initial,
    this.enquiryError,
    this.contactStatus = SubmitStatus.initial,
    this.contactError,
  });

  EnquiryState copyWith({
    SubmitStatus? enquiryStatus,
    String? enquiryError,
    SubmitStatus? contactStatus,
    String? contactError,
  }) {
    return EnquiryState(
      enquiryStatus: enquiryStatus ?? this.enquiryStatus,
      enquiryError: enquiryError,
      contactStatus: contactStatus ?? this.contactStatus,
      contactError: contactError,
    );
  }

  @override
  List<Object?> get props => [enquiryStatus, enquiryError, contactStatus, contactError];
}

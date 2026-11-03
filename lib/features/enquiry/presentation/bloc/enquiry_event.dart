import 'package:equatable/equatable.dart';
import '../../domain/entities/contact_message_entity.dart';
import '../../domain/entities/enquiry_entity.dart';

abstract class EnquiryEvent extends Equatable {
  const EnquiryEvent();

  @override
  List<Object?> get props => [];
}

class SubmitEnquiryEvent extends EnquiryEvent {
  final EnquiryEntity enquiry;
  const SubmitEnquiryEvent(this.enquiry);

  @override
  List<Object?> get props => [enquiry];
}

class SubmitContactMessageEvent extends EnquiryEvent {
  final ContactMessageEntity message;
  const SubmitContactMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class ResetEnquiryStatusEvent extends EnquiryEvent {
  const ResetEnquiryStatusEvent();
}

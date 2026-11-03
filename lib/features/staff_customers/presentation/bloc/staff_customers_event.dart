import 'package:equatable/equatable.dart';
import '../../domain/repositories/staff_customers_repository.dart';

abstract class StaffCustomersEvent extends Equatable {
  const StaffCustomersEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaffCustomersEvent extends StaffCustomersEvent {
  const LoadStaffCustomersEvent();
}

class SubmitStaffCustomerEvent extends StaffCustomersEvent {
  final NewStaffCustomer customer;
  final String customerId;
  const SubmitStaffCustomerEvent(this.customer, {required this.customerId});

  @override
  List<Object?> get props => [customer, customerId];
}

class ResetCustomerSubmitStatusEvent extends StaffCustomersEvent {
  const ResetCustomerSubmitStatusEvent();
}

class UploadCustomerDocumentEvent extends StaffCustomersEvent {
  final String customerId;
  final String docType;
  final String filePath;
  final bool multi;

  const UploadCustomerDocumentEvent({
    required this.customerId,
    required this.docType,
    required this.filePath,
    this.multi = false,
  });

  @override
  List<Object?> get props => [customerId, docType, filePath, multi];
}

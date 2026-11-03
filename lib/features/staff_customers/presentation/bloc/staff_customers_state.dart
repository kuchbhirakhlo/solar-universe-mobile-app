import 'package:equatable/equatable.dart';
import '../../domain/entities/staff_customer_entity.dart';

enum ListStatus { initial, loading, success, failure }
enum SubmitStatus { initial, submitting, success, failure }

class StaffCustomersState extends Equatable {
  final ListStatus listStatus;
  final List<StaffCustomerEntity> customers;
  final String? listError;
  final SubmitStatus submitStatus;
  final String? submitError;
  final SubmitStatus uploadStatus;
  final String? uploadError;

  const StaffCustomersState({
    this.listStatus = ListStatus.initial,
    this.customers = const [],
    this.listError,
    this.submitStatus = SubmitStatus.initial,
    this.submitError,
    this.uploadStatus = SubmitStatus.initial,
    this.uploadError,
  });

  StaffCustomersState copyWith({
    ListStatus? listStatus,
    List<StaffCustomerEntity>? customers,
    String? listError,
    SubmitStatus? submitStatus,
    String? submitError,
    SubmitStatus? uploadStatus,
    String? uploadError,
  }) {
    return StaffCustomersState(
      listStatus: listStatus ?? this.listStatus,
      customers: customers ?? this.customers,
      listError: listError,
      submitStatus: submitStatus ?? this.submitStatus,
      submitError: submitError,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadError: uploadError,
    );
  }

  @override
  List<Object?> get props => [
        listStatus,
        customers,
        listError,
        submitStatus,
        submitError,
        uploadStatus,
        uploadError,
      ];
}

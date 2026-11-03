import 'package:equatable/equatable.dart';
import '../../domain/entities/customer_entity.dart';

enum CustomerAuthStatus {
  initial,
  sendingOtp,
  otpSent,
  verifying,
  needsProfile,
  creatingProfile,
  authenticated,
}

class CustomerAuthState extends Equatable {
  final CustomerAuthStatus status;
  final String? mobile;
  final String? verificationId;
  final CustomerEntity? customer;
  final String? errorMessage;

  const CustomerAuthState({
    this.status = CustomerAuthStatus.initial,
    this.mobile,
    this.verificationId,
    this.customer,
    this.errorMessage,
  });

  CustomerAuthState copyWith({
    CustomerAuthStatus? status,
    String? mobile,
    String? verificationId,
    CustomerEntity? customer,
    String? errorMessage,
  }) {
    return CustomerAuthState(
      status: status ?? this.status,
      mobile: mobile ?? this.mobile,
      verificationId: verificationId ?? this.verificationId,
      customer: customer ?? this.customer,
      // errorMessage is deliberately not defaulted to `this.errorMessage` —
      // every transition should either set a fresh error or explicitly
      // clear the old one, or a stale error would linger on screen forever.
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, mobile, verificationId, customer, errorMessage];
}

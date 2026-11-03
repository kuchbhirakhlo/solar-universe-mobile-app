import 'package:equatable/equatable.dart';
import '../../domain/repositories/customer_auth_repository.dart';

abstract class CustomerAuthEvent extends Equatable {
  const CustomerAuthEvent();
  @override
  List<Object?> get props => [];
}

class SendCustomerOtpEvent extends CustomerAuthEvent {
  final String mobile;
  const SendCustomerOtpEvent(this.mobile);
  @override
  List<Object?> get props => [mobile];
}

/// Re-sends to whichever mobile number the bloc is already holding onto
/// from the most recent [SendCustomerOtpEvent].
class ResendCustomerOtpEvent extends CustomerAuthEvent {
  const ResendCustomerOtpEvent();
}

class VerifyCustomerOtpEvent extends CustomerAuthEvent {
  final String smsCode;
  const VerifyCustomerOtpEvent(this.smsCode);
  @override
  List<Object?> get props => [smsCode];
}

class CreateCustomerProfileEvent extends CustomerAuthEvent {
  final NewCustomerProfile profile;
  const CreateCustomerProfileEvent(this.profile);
  @override
  List<Object?> get props => [profile];
}

class SignOutCustomerEvent extends CustomerAuthEvent {
  const SignOutCustomerEvent();
}

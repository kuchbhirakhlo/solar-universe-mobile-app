import 'package:equatable/equatable.dart';
import '../../domain/repositories/customer_service_requests_repository.dart';

abstract class CustomerServiceRequestsEvent extends Equatable {
  const CustomerServiceRequestsEvent();
  @override
  List<Object?> get props => [];
}

class LoadMyServiceRequestsEvent extends CustomerServiceRequestsEvent {
  final String customerId;
  const LoadMyServiceRequestsEvent(this.customerId);
  @override
  List<Object?> get props => [customerId];
}

class SubmitServiceRequestEvent extends CustomerServiceRequestsEvent {
  final NewServiceRequest request;
  const SubmitServiceRequestEvent(this.request);
  @override
  List<Object?> get props => [request];
}

/// Clears `submitStatus` back to idle after the screen has reacted to it.
/// Needed because this bloc is a singleton (shared across screen visits,
/// not recreated) — without this, re-opening Create Service Request after a
/// successful submit would see the still-`submitted` status from last time
/// and immediately pop itself again (mirrors `staff_enquiries`'
/// `ResetSubmitStatusEvent` for the same reason).
class ResetServiceRequestSubmitStatusEvent extends CustomerServiceRequestsEvent {
  const ResetServiceRequestSubmitStatusEvent();
}

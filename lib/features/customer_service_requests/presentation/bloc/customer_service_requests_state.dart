import 'package:equatable/equatable.dart';
import '../../domain/entities/service_request_entity.dart';

enum LoadStatus { initial, loading, loaded, error }
enum SubmitStatus { idle, submitting, submitted, error }

class CustomerServiceRequestsState extends Equatable {
  final LoadStatus loadStatus;
  final List<ServiceRequestEntity> requests;
  final String? loadError;
  final SubmitStatus submitStatus;
  final String? submitError;

  const CustomerServiceRequestsState({
    this.loadStatus = LoadStatus.initial,
    this.requests = const [],
    this.loadError,
    this.submitStatus = SubmitStatus.idle,
    this.submitError,
  });

  CustomerServiceRequestsState copyWith({
    LoadStatus? loadStatus,
    List<ServiceRequestEntity>? requests,
    String? loadError,
    SubmitStatus? submitStatus,
    String? submitError,
  }) {
    return CustomerServiceRequestsState(
      loadStatus: loadStatus ?? this.loadStatus,
      requests: requests ?? this.requests,
      loadError: loadError,
      submitStatus: submitStatus ?? this.submitStatus,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [loadStatus, requests, loadError, submitStatus, submitError];
}

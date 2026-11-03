import 'package:equatable/equatable.dart';
import '../../../customer_service_requests/domain/entities/service_request_entity.dart';

enum LoadStatus { initial, loading, loaded, error }
enum ActionStatus { idle, working, success, error }

class StaffServiceRequestsState extends Equatable {
  final LoadStatus loadStatus;
  final List<ServiceRequestEntity> requests;
  final String? loadError;
  final ActionStatus actionStatus;
  final String? actionError;

  const StaffServiceRequestsState({
    this.loadStatus = LoadStatus.initial,
    this.requests = const [],
    this.loadError,
    this.actionStatus = ActionStatus.idle,
    this.actionError,
  });

  /// Convenience for the detail screen — the freshest copy of one request
  /// from the last load, falling back to null if it hasn't loaded (yet).
  ServiceRequestEntity? byId(String id) {
    for (final r in requests) {
      if (r.id == id) return r;
    }
    return null;
  }

  StaffServiceRequestsState copyWith({
    LoadStatus? loadStatus,
    List<ServiceRequestEntity>? requests,
    String? loadError,
    ActionStatus? actionStatus,
    String? actionError,
  }) {
    return StaffServiceRequestsState(
      loadStatus: loadStatus ?? this.loadStatus,
      requests: requests ?? this.requests,
      loadError: loadError,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [loadStatus, requests, loadError, actionStatus, actionError];
}

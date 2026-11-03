import 'package:equatable/equatable.dart';

/// Matches the real `service_requests` Firestore collection exactly (the
/// admin web panel's "Service Requests" feature already writes/reads this
/// shape — confirmed from a live document). `status`/`assignedEngineerId`/
/// `assignedEngineerName`/`estimatedCost` are admin-managed: this app only
/// ever writes `status: 'Open'` and leaves the engineer/cost fields empty
/// at creation (see `CreateServiceRequestData`) — never edits them after.
class ServiceRequestEntity extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String customerMobile;
  final String serviceType;
  final String description;
  final String remark;
  final String status;
  final String assignedEngineerId;
  final String assignedEngineerName;
  final num estimatedCost;
  final String createdAt;
  final String updatedAt;
  // Not part of the admin panel's original schema — added for the mobile
  // app's Engineer service page (see StaffServiceRequestsDataSource). Purely
  // additive: absent/empty on every doc the admin panel itself has written.
  final List<String> installationPhotos;

  const ServiceRequestEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerMobile,
    required this.serviceType,
    required this.description,
    required this.remark,
    required this.status,
    required this.assignedEngineerId,
    required this.assignedEngineerName,
    required this.estimatedCost,
    required this.createdAt,
    required this.updatedAt,
    this.installationPhotos = const [],
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        customerMobile,
        serviceType,
        description,
        remark,
        status,
        assignedEngineerId,
        assignedEngineerName,
        estimatedCost,
        createdAt,
        updatedAt,
        installationPhotos,
      ];
}

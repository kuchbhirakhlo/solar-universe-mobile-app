import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/service_request_options.dart';
import '../../domain/repositories/customer_service_requests_repository.dart';
import '../models/service_request_model.dart';

abstract class CustomerServiceRequestsDataSource {
  Future<List<ServiceRequestModel>> getMyRequests(String customerId);
  Future<void> createRequest(NewServiceRequest request);
}

class CustomerServiceRequestsDataSourceImpl implements CustomerServiceRequestsDataSource {
  final FirebaseFirestore firestore;

  CustomerServiceRequestsDataSourceImpl(this.firestore);

  @override
  Future<List<ServiceRequestModel>> getMyRequests(String customerId) async {
    final snap = await firestore
        .collection('service_requests')
        .where('customerId', isEqualTo: customerId)
        .get();
    // Sorted here rather than with .orderBy('createdAt'): that combined with the
    // equality filter needs a composite index which isn't deployed, and an
    // un-indexed query fails outright (FAILED_PRECONDITION) — the screen then
    // shows "could not load". createdAt is an ISO-8601 string, so it sorts
    // correctly as text.
    final list = snap.docs
        .map((d) => ServiceRequestModel.tryFromMap(d.id, d.data()))
        .whereType<ServiceRequestModel>()
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> createRequest(NewServiceRequest request) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await firestore.collection('service_requests').add({
      'customerId': request.customerId,
      'customerName': request.customerName,
      'customerMobile': request.customerMobile,
      'serviceType': request.serviceType,
      'description': request.description,
      'remark': request.remark,
      // Always 'Open' at creation — status is admin-managed from here on,
      // this app never writes to it again.
      'status': ServiceRequestOptions.initialStatus,
      'assignedEngineerId': '',
      'assignedEngineerName': '',
      'estimatedCost': 0,
      'createdAt': now,
      'updatedAt': now,
    });
  }
}

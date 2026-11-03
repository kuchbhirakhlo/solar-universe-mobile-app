import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import '../../../customer_service_requests/data/models/service_request_model.dart';

abstract class StaffServiceRequestsDataSource {
  Future<List<ServiceRequestModel>> getAssignedRequests(
    String engineerId, {
    String employeeId = '',
  });

  Future<void> updateStatusAndRemark({
    required String requestId,
    required String status,
    required String remark,
  });

  Future<void> uploadInstallationPhoto({
    required String requestId,
    required String filePath,
  });
}

class StaffServiceRequestsDataSourceImpl implements StaffServiceRequestsDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  StaffServiceRequestsDataSourceImpl(this.firestore, this.storage);

  @override
  Future<List<ServiceRequestModel>> getAssignedRequests(
    String engineerId, {
    String employeeId = '',
  }) async {
    // Match both the Auth/doc id (what AdminService writes for current staff)
    // and employeeId (legacy / re-created staff docs). Equality-only — no
    // orderBy — because assignedEngineerId + createdAt needs a composite
    // index that is not deployed on this project (FAILED_PRECONDITION
    // otherwise empties the engineer screen).
    final ids = <String>{
      if (engineerId.trim().isNotEmpty) engineerId.trim(),
      if (employeeId.trim().isNotEmpty) employeeId.trim(),
    }.toList();
    if (ids.isEmpty) return [];

    final snaps = await Future.wait(
      ids.map(
        (id) => firestore
            .collection('service_requests')
            .where('assignedEngineerId', isEqualTo: id)
            .get(),
      ),
    );

    final byDocId = <String, ServiceRequestModel>{};
    for (final snap in snaps) {
      for (final doc in snap.docs) {
        final model = ServiceRequestModel.tryFromMap(doc.id, doc.data());
        if (model != null) byDocId[doc.id] = model;
      }
    }
    final list = byDocId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> updateStatusAndRemark({
    required String requestId,
    required String status,
    required String remark,
  }) async {
    await firestore.collection('service_requests').doc(requestId).update({
      'status': status,
      'remark': remark,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> uploadInstallationPhoto({
    required String requestId,
    required String filePath,
  }) async {
    // Always attempted — see the matching comment in
    // StaffCustomersDataSourceImpl.uploadDocument for why: this throws
    // cleanly (caught by the repository) if Storage/Blaze isn't enabled
    // yet, and starts succeeding automatically once it is, no app update
    // needed.
    final file = File(filePath);
    final ext = p.extension(filePath);
    final ref = storage.ref(
      'service_requests/$requestId/installation-${DateTime.now().millisecondsSinceEpoch}$ext',
    );
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    await firestore.collection('service_requests').doc(requestId).set({
      'installationPhotos': FieldValue.arrayUnion([url]),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    }, SetOptions(merge: true));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

/// Writes the current staff member's GPS position to the `staff_locations`
/// collection — one document per staff member, overwritten (not appended) on
/// every update. Same contract as the DAS NEXA GROUP app / its admin Live
/// Tracking map: `updatedAt` is an ISO-8601 UTC string, and the admin treats a
/// position older than ~5 minutes as "inactive".
class StaffLocationDataSource {
  final FirebaseFirestore firestore;

  StaffLocationDataSource(this.firestore);

  Future<void> pushLocation({
    required String staffId,
    required String staffName,
    required String role,
    required double lat,
    required double lng,
    double? accuracy,
    double? speed,
    double? heading,
  }) async {
    await firestore.collection('staff_locations').doc(staffId).set({
      'staffId': staffId,
      'staffName': staffName,
      'role': role,
      'lat': lat,
      'lng': lng,
      if (accuracy != null) 'accuracy': accuracy,
      if (speed != null) 'speed': speed,
      if (heading != null) 'heading': heading,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }
}

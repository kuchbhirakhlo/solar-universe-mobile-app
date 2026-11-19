import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Staff GPS data for the admin web panel:
/// - [pushLocation] — live position (`staff_locations/{staffId}`)
/// - [recordLocationSnapshot] — periodic / session history (`staff_location_snapshots`)
/// - [appendDailyTravelPoint] — daily km total + route (`staff_daily_travel` + `points`)
class StaffLocationDataSource {
  final FirebaseFirestore firestore;

  StaffLocationDataSource(this.firestore);

  static String _todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  static String dailyTravelDocId(String staffId) => '${staffId}_${_todayKey()}';

  /// Latest position for the live tracking map (overwritten on each update).
  Future<void> pushLocation({
    required String staffId,
    required String employeeId,
    required String staffName,
    required String role,
    required String phone,
    required double lat,
    required double lng,
    double? accuracy,
    double? speed,
    double? heading,
  }) async {
    await firestore.collection('staff_locations').doc(staffId).set({
      'staffId': staffId,
      'employeeId': employeeId,
      'staffName': staffName,
      'role': role,
      'phone': phone,
      'lat': lat,
      'lng': lng,
      if (accuracy != null) 'accuracy': accuracy,
      if (speed != null) 'speed': speed,
      if (heading != null) 'heading': heading,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Appended history (login fix, every 30 minutes, etc.) for admin timelines.
  Future<void> recordLocationSnapshot({
    required String staffId,
    required String employeeId,
    required String staffName,
    required String role,
    required String phone,
    required double lat,
    required double lng,
    required String kind,
    double? accuracy,
    double? speed,
    double? heading,
  }) async {
    await firestore.collection('staff_location_snapshots').add({
      'staffId': staffId,
      'employeeId': employeeId,
      'staffName': staffName,
      'role': role,
      'phone': phone,
      'lat': lat,
      'lng': lng,
      if (accuracy != null) 'accuracy': accuracy,
      if (speed != null) 'speed': speed,
      if (heading != null) 'heading': heading,
      'kind': kind,
      'date': _todayKey(),
      'capturedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Increments today's travel distance and stores a route point for the admin map.
  Future<void> appendDailyTravelPoint({
    required String staffId,
    required String employeeId,
    required String staffName,
    required String role,
    required String phone,
    required double lat,
    required double lng,
    required double segmentDistanceKm,
    required String source,
    double? accuracy,
  }) async {
    final dateKey = _todayKey();
    final docRef = firestore.collection('staff_daily_travel').doc(dailyTravelDocId(staffId));
    final now = DateTime.now().toUtc().toIso8601String();

    final existing = await docRef.get();
    await docRef.set({
      'staffId': staffId,
      'employeeId': employeeId,
      'staffName': staffName,
      'role': role,
      'phone': phone,
      'date': dateKey,
      'totalDistanceKm': FieldValue.increment(segmentDistanceKm),
      'updatedAt': now,
      'lastLat': lat,
      'lastLng': lng,
      if (!existing.exists) 'startedAt': now,
    }, SetOptions(merge: true));

    await docRef.collection('points').add({
      'lat': lat,
      'lng': lng,
      'recordedAt': now,
      'segmentDistanceKm': segmentDistanceKm,
      'source': source,
      if (accuracy != null) 'accuracy': accuracy,
    });
  }
}

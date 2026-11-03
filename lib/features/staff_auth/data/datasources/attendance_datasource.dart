import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Attendance/{staffId}_{yyyy-MM-dd} doc pattern, matching the web portal.
/// Marking is now an explicit staff action (via DailyAttendancePopup) rather
/// than silent/automatic — see 'Present' | 'Leave' | 'Weekly Off'.
class AttendanceDataSource {
  final FirebaseFirestore firestore;

  AttendanceDataSource(this.firestore);

  String _todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// The status already recorded for today, or null if nothing's been
  /// marked yet.
  Future<String?> getTodayStatus(String staffId) async {
    final doc = await firestore.collection('attendance').doc('${staffId}_${_todayKey()}').get();
    if (!doc.exists) return null;
    return doc.data()?['status'] as String?;
  }

  Future<void> markAttendance({
    required String staffId,
    required String staffName,
    required String status,
  }) async {
    await firestore.collection('attendance').doc('${staffId}_${_todayKey()}').set({
      'staffId': staffId,
      'staffName': staffName,
      'date': _todayKey(),
      'status': status,
    });
  }
}

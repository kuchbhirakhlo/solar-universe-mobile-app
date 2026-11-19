import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../features/staff_auth/data/datasources/staff_location_datasource.dart';
import '../../features/staff_auth/domain/entities/staff_entity.dart';

enum LocationTrackingStatus { off, tracking, serviceDisabled, permissionDenied }

/// Streams the signed-in staff member's GPS position to Firestore: a write on
/// every ~30 m of movement plus a floor of one write every 60 s while
/// stationary, so the admin can tell "actively moving" from "idle".
///
/// Also records:
/// - a location snapshot when tracking starts (staff login / session restore)
/// - `staff_location_snapshots` every 30 minutes
/// - daily travel distance (km) and route points under `staff_daily_travel`
///
/// Keeps sharing while the app is **minimized** (not force-stopped):
/// - Android: location foreground service + ongoing notification (Geolocator FGS)
/// - iOS: `UIBackgroundModes` + requests "Always" after "While In Use" when possible
///
/// Stops on logout or when the user swipes the app away / kills the process.
/// The admin treats a position older than 5 minutes as "inactive".
///
/// The outcome is exposed through [status] so the UI can tell the staff
/// member when location is off/denied instead of failing silently.
class StaffLocationTracker {
  StaffLocationTracker(this._dataSource);

  static const Duration _intervalSnapshotPeriod = Duration(minutes: 30);
  static const double _minTravelSegmentMeters = 25;

  final StaffLocationDataSource _dataSource;

  final ValueNotifier<LocationTrackingStatus> status =
      ValueNotifier(LocationTrackingStatus.off);

  StreamSubscription<Position>? _positionSub;
  Timer? _heartbeatTimer;
  Timer? _intervalSnapshotTimer;
  Position? _lastPosition;
  ({double lat, double lng})? _lastTravelFix;
  String? _travelDateKey;
  StaffEntity? _staff;

  bool get isTracking => _positionSub != null;

  /// Begins tracking for [staff]. Safe to call without permission — it is
  /// requested here, and tracking simply doesn't start if declined (reflected
  /// in [status]) without ever blocking sign-in.
  Future<void> start(StaffEntity staff) async {
    await stop();
    _staff = staff;
    _travelDateKey = _todayKey();
    _lastTravelFix = null;

    final permission = await _checkPermission();
    if (permission != LocationTrackingStatus.tracking) {
      status.value = permission;
      return;
    }

    _positionSub = Geolocator.getPositionStream(locationSettings: _streamSettings()).listen(
      (position) {
        _lastPosition = position;
        unawaited(_push(position, recordTravel: true, travelSource: 'movement'));
      },
      onError: (Object error) {
        debugPrint('StaffLocationTracker: position stream error: $error');
      },
    );
    status.value = LocationTrackingStatus.tracking;

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      final position = _lastPosition;
      if (position != null) {
        unawaited(_push(position, recordTravel: false));
      }
    });

    _intervalSnapshotTimer = Timer.periodic(_intervalSnapshotPeriod, (_) {
      final position = _lastPosition;
      if (position != null) {
        unawaited(_recordIntervalSnapshot(position));
      }
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      _lastPosition = position;
      await _push(position, recordTravel: true, travelSource: 'session_start');
      await _recordSnapshot(position, kind: 'session_start');
    } catch (error) {
      debugPrint('StaffLocationTracker: initial fix failed: $error');
    }
  }

  /// Re-attempts tracking for the last staff member (used by the banner's
  /// "Enable" button after the user turns location on or grants permission).
  Future<void> retry() async {
    final staff = _staff;
    if (staff != null) await start(staff);
  }

  /// Called when the app returns to the foreground. Restarts the GPS stream if
  /// the OS paused it while minimized, without stopping tracking on [paused].
  Future<void> ensureRunning(StaffEntity? staff) async {
    if (staff == null) return;
    _staff ??= staff;
    if (_staff!.id != staff.id) {
      await start(staff);
      return;
    }
    if (!isTracking) {
      await start(staff);
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _lastPosition = position;
      await _push(position, recordTravel: true, travelSource: 'movement');
    } catch (error) {
      debugPrint('StaffLocationTracker: resume refresh failed: $error');
    }
  }

  /// Stops tracking (cancels the stream so the Android notification / FGS
  /// goes away). Does not delete the last written position — the admin shows
  /// it as "inactive" once it goes stale.
  Future<void> stop() async {
    await _positionSub?.cancel();
    _positionSub = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _intervalSnapshotTimer?.cancel();
    _intervalSnapshotTimer = null;
    _lastPosition = null;
    status.value = LocationTrackingStatus.off;
  }

  /// Full reset on sign-out.
  Future<void> clear() async {
    await stop();
    _staff = null;
    _lastTravelFix = null;
    _travelDateKey = null;
  }

  LocationSettings _streamSettings() {
    const accuracy = LocationAccuracy.high;
    const distanceFilter = 30;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        intervalDuration: const Duration(seconds: 60),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Solar Universe',
          notificationText:
              'Sharing your location while you work — even if the app is minimized',
          notificationChannelName: 'Staff location',
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        activityType: ActivityType.otherNavigation,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }
    return const LocationSettings(accuracy: accuracy, distanceFilter: distanceFilter);
  }

  Future<void> _recordIntervalSnapshot(Position position) async {
    await _recordSnapshot(position, kind: 'interval_30m');
    await _push(position, recordTravel: true, travelSource: 'interval_30m');
  }

  Future<void> _recordSnapshot(Position position, {required String kind}) async {
    final staff = _staff;
    if (staff == null) return;
    try {
      await _dataSource.recordLocationSnapshot(
        staffId: staff.id,
        employeeId: staff.employeeId,
        staffName: staff.name,
        role: staff.role,
        phone: staff.phone,
        lat: position.latitude,
        lng: position.longitude,
        kind: kind,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
      );
    } catch (error) {
      debugPrint('StaffLocationTracker: snapshot write failed: $error');
    }
  }

  Future<void> _push(
    Position position, {
    required bool recordTravel,
    String travelSource = 'movement',
  }) async {
    final staff = _staff;
    if (staff == null) return;
    _rollTravelDayIfNeeded();

    try {
      await _dataSource.pushLocation(
        staffId: staff.id,
        employeeId: staff.employeeId,
        staffName: staff.name,
        role: staff.role,
        phone: staff.phone,
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
      );
    } catch (error) {
      debugPrint('StaffLocationTracker: live location write failed: $error');
    }

    if (!recordTravel) return;

    final alwaysRecordPoint =
        travelSource == 'session_start' || travelSource == 'interval_30m';
    final dayAnchor = _lastTravelFix == null;
    final segmentKm = _segmentDistanceKm(position);
    if (!alwaysRecordPoint && segmentKm <= 0 && !dayAnchor) return;

    try {
      await _dataSource.appendDailyTravelPoint(
        staffId: staff.id,
        employeeId: staff.employeeId,
        staffName: staff.name,
        role: staff.role,
        phone: staff.phone,
        lat: position.latitude,
        lng: position.longitude,
        segmentDistanceKm: segmentKm,
        source: travelSource,
        accuracy: position.accuracy,
      );
    } catch (error) {
      debugPrint('StaffLocationTracker: daily travel write failed: $error');
    }
  }

  void _rollTravelDayIfNeeded() {
    final today = _todayKey();
    if (_travelDateKey != today) {
      _travelDateKey = today;
      _lastTravelFix = null;
    }
  }

  String _todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// Returns km to add for this fix; updates [_lastTravelFix] when the point
  /// is stored (movement, session start, or interval — not heartbeats).
  double _segmentDistanceKm(Position position) {
    final prev = _lastTravelFix;
    final lat = position.latitude;
    final lng = position.longitude;

    if (prev == null) {
      _lastTravelFix = (lat: lat, lng: lng);
      return 0;
    }

    final meters = Geolocator.distanceBetween(prev.lat, prev.lng, lat, lng);
    if (meters < _minTravelSegmentMeters) {
      return 0;
    }

    _lastTravelFix = (lat: lat, lng: lng);
    return meters / 1000;
  }

  Future<LocationTrackingStatus> _checkPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationTrackingStatus.serviceDisabled;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationTrackingStatus.permissionDenied;
    }
    // iOS: second prompt upgrades to Always so updates continue when minimized.
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        permission == LocationPermission.whileInUse) {
      final always = await Geolocator.requestPermission();
      if (always == LocationPermission.always) {
        permission = always;
      }
    }
    final ok = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    return ok ? LocationTrackingStatus.tracking : LocationTrackingStatus.permissionDenied;
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/staff_auth/data/datasources/staff_location_datasource.dart';
import '../../features/staff_auth/domain/entities/staff_entity.dart';

enum LocationTrackingStatus { off, tracking, serviceDisabled, permissionDenied }

/// Streams the signed-in staff member's GPS position to Firestore: a write on
/// every ~30 m of movement plus a floor of one write every 60 s while
/// stationary, so the admin can tell "actively moving" from "idle".
///
/// Continues while the app is minimized via Android's location foreground
/// service (persistent notification) and iOS background location updates.
/// Stops on logout or when the process is killed — no boot receiver and no
/// "Always" / background-location permission, so a force-stop does not keep
/// tracking. The admin treats a position older than 5 minutes as "inactive".
///
/// The outcome is exposed through [status] so the UI can tell the staff
/// member when location is off/denied instead of failing silently.
class StaffLocationTracker {
  final StaffLocationDataSource _dataSource;

  StaffLocationTracker(this._dataSource);

  final ValueNotifier<LocationTrackingStatus> status =
      ValueNotifier(LocationTrackingStatus.off);

  StreamSubscription<Position>? _positionSub;
  Timer? _heartbeatTimer;
  Position? _lastPosition;
  StaffEntity? _staff;

  bool get isTracking => _positionSub != null;

  /// Begins tracking for [staff]. Safe to call without permission — it is
  /// requested here, and tracking simply doesn't start if declined (reflected
  /// in [status]) without ever blocking sign-in.
  Future<void> start(StaffEntity staff) async {
    await stop();
    _staff = staff;

    final permission = await _checkPermission();
    if (permission != LocationTrackingStatus.tracking) {
      status.value = permission;
      return;
    }

    _positionSub = Geolocator.getPositionStream(locationSettings: _streamSettings()).listen(
      (position) {
        _lastPosition = position;
        unawaited(_push(position));
      },
      onError: (Object error) {
        debugPrint('StaffLocationTracker: position stream error: $error');
      },
    );
    status.value = LocationTrackingStatus.tracking;

    // Floor write cadence — fires even when stationary (the distanceFilter
    // above only emits after ~30 m of movement).
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      final position = _lastPosition;
      if (position != null) unawaited(_push(position));
    });

    // First fix immediately instead of waiting for the first stream event or
    // heartbeat. Bounded by a timeLimit so a device that never delivers a fix
    // fails instead of hanging.
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      _lastPosition = position;
      await _push(position);
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

  /// Stops tracking (cancels the stream so the Android notification / FGS
  /// goes away). Does not delete the last written position — the admin shows
  /// it as "inactive" once it goes stale.
  Future<void> stop() async {
    await _positionSub?.cancel();
    _positionSub = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _lastPosition = null;
    // Keep _staff so retry() still works while the banner is shown after a
    // denied start; sign-out clears it via [clear].
    status.value = LocationTrackingStatus.off;
  }

  /// Full reset on sign-out.
  Future<void> clear() async {
    await stop();
    _staff = null;
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
          notificationText: 'Sharing your location with the office',
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

  Future<void> _push(Position position) async {
    final staff = _staff;
    if (staff == null) return;
    try {
      await _dataSource.pushLocation(
        staffId: staff.id,
        staffName: staff.name,
        role: staff.role,
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
      );
    } catch (error) {
      debugPrint('StaffLocationTracker: write failed: $error');
    }
  }

  Future<LocationTrackingStatus> _checkPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationTrackingStatus.serviceDisabled;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    final ok = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    return ok ? LocationTrackingStatus.tracking : LocationTrackingStatus.permissionDenied;
  }
}

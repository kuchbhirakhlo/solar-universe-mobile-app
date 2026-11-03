import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../injection.dart';
import '../services/staff_location_tracker.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Shown at the top of the staff portal only when live location couldn't start
/// (location services off, or permission declined), so the staff member knows
/// the office can't see their position and can fix it.
class LocationStatusBanner extends StatelessWidget {
  const LocationStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = sl<StaffLocationTracker>();
    return ValueListenableBuilder<LocationTrackingStatus>(
      valueListenable: tracker.status,
      builder: (context, status, _) {
        if (status != LocationTrackingStatus.serviceDisabled &&
            status != LocationTrackingStatus.permissionDenied) {
          return const SizedBox.shrink();
        }
        final serviceOff = status == LocationTrackingStatus.serviceDisabled;
        return Container(
          width: double.infinity,
          color: AppColors.warningContainer,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(Icons.location_off_rounded, size: 18, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  serviceOff
                      ? 'Location is turned off. Turn it on so the office can see your position.'
                      : 'Location permission is needed so the office can see your position.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    if (serviceOff) {
                      await Geolocator.openLocationSettings();
                    } else {
                      final p = await Geolocator.checkPermission();
                      if (p == LocationPermission.deniedForever) {
                        await Geolocator.openAppSettings();
                      }
                    }
                  } catch (_) {}
                  await tracker.retry();
                },
                child: const Text('Enable'),
              ),
            ],
          ),
        );
      },
    );
  }
}

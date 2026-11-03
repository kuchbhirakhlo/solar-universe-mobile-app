import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/staff_auth/data/datasources/attendance_datasource.dart';
import '../../features/staff_auth/presentation/bloc/staff_auth_bloc.dart';
import '../../features/staff_auth/presentation/bloc/staff_auth_event.dart';
import '../../features/staff_auth/presentation/widgets/daily_attendance_popup.dart';
import '../../injection.dart';
import '../routing/route_names.dart';
import '../session/staff_session.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'location_status_banner.dart';

/// Mobile-adapted staff portal shell. The web reference is a fixed dark
/// sidebar (Dashboard/Enquiries/Quick Quote/Solar Customers + profile card
/// with Website/Logout) — on a phone that's a bottom nav bar instead, with
/// the profile/logout moved into the app bar, which is the idiomatic mobile
/// equivalent rather than a squeezed-down desktop sidebar.
class StaffShell extends StatefulWidget {
  final Widget child;
  final String title;

  const StaffShell({super.key, required this.child, required this.title});

  @override
  State<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends State<StaffShell> {
  bool _attendanceChecked = false;

  @override
  void initState() {
    super.initState();
    // Checked once per shell mount (this State persists across tab
    // navigation, so it doesn't re-fire on every tap).
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAttendance());
  }

  Future<void> _checkAttendance() async {
    if (!mounted || _attendanceChecked) return;
    _attendanceChecked = true;
    // Sessions now persist across restarts, so only prompt when today's
    // attendance hasn't been recorded yet (the popup itself is date-keyed:
    // a new day naturally starts unmarked). If the lookup fails (offline),
    // fall through to showing the popup so attendance can still be marked.
    final staff = sl<StaffSession>().current;
    if (staff != null) {
      try {
        final status = await sl<AttendanceDataSource>().getTodayStatus(staff.id);
        if (status != null) return;
      } catch (_) {}
    }
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DailyAttendancePopup(),
    );
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RouteNames.staffEnquiries)) return 1;
    if (location.startsWith(RouteNames.staffQuickQuote)) return 2;
    if (location.startsWith(RouteNames.staffCustomers)) return 3;
    return 0;
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout of the staff portal?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      sl<StaffAuthBloc>().add(const SignOutStaffEvent());
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final staff = sl<StaffSession>().current;
    final index = _currentIndex(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleSpacing: AppSpacing.pageHorizontal,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: AppTypography.headlineSmall.copyWith(color: Colors.white)),
            if (staff != null)
              Text(
                '${staff.role} Portal',
                style: AppTypography.labelSmall.copyWith(color: Colors.white70),
              ),
          ],
        ),
        actions: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Text(
              (staff?.name.isNotEmpty ?? false) ? staff!.name[0].toUpperCase() : '?',
              style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          const LocationStatusBanner(),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.brandYellow,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go(RouteNames.staffDashboard);
              break;
            case 1:
              context.go(RouteNames.staffEnquiries);
              break;
            case 2:
              context.go(RouteNames.staffQuickQuote);
              break;
            case 3:
              context.go(RouteNames.staffCustomers);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inbox_rounded), label: 'Enquiries'),
          BottomNavigationBarItem(icon: Icon(Icons.bolt_rounded), label: 'Quick Quote'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_rounded), label: 'Customers'),
        ],
      ),
    );
  }
}

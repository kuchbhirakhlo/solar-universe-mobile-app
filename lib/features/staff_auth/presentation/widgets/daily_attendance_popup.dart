import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/session/staff_session.dart';
import '../../../../injection.dart';
import '../../data/datasources/attendance_datasource.dart';
import '../../domain/entities/staff_entity.dart';

/// Modal shown once per staff portal session (see StaffShell) — mirrors the
/// web portal's SalesAttendancePopup: check today's attendance, and if not
/// yet marked, let the staff member choose Present or On Leave (with a
/// separate Sunday/Weekly-Off flow), rather than silently auto-marking
/// Present the way this app used to.
class DailyAttendancePopup extends StatefulWidget {
  const DailyAttendancePopup({super.key});

  @override
  State<DailyAttendancePopup> createState() => _DailyAttendancePopupState();
}

class _DailyAttendancePopupState extends State<DailyAttendancePopup> {
  final _attendance = sl<AttendanceDataSource>();
  bool _loading = true;
  bool _marking = false;
  String? _status; // 'Present' | 'Leave' | 'Weekly Off' | null

  bool get _isSunday => DateTime.now().weekday == DateTime.sunday;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final staff = sl<StaffSession>().current;
    if (staff == null) {
      setState(() => _loading = false);
      return;
    }
    final status = await _attendance.getTodayStatus(staff.id);
    if (!mounted) return;
    setState(() {
      _status = status;
      _loading = false;
    });
  }

  Future<void> _mark(String status) async {
    final staff = sl<StaffSession>().current;
    if (staff == null) return;
    setState(() => _marking = true);
    await _attendance.markAttendance(staffId: staff.id, staffName: staff.name, status: status);
    if (!mounted) return;
    setState(() {
      _status = status;
      _marking = false;
    });
  }

  Future<void> _confirmLeave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark today as Leave?'),
        content: const Text('Leaves beyond 2 in a month are deducted from salary.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark Leave', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
    if (confirmed == true) await _mark('Leave');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: _loading ? _loadingCard() : _content(),
      ),
    );
  }

  Widget _loadingCard() {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xxl),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)),
          SizedBox(width: AppSpacing.md),
          Text('Checking attendance...'),
        ],
      ),
    );
  }

  Widget _content() {
    if (_isSunday && _status == null) return _sundayPrompt();
    if (_isSunday) return _doneCard(sunday: true);
    if (_status != null) return _doneCard(sunday: false);
    return _markPrompt();
  }

  Widget _sundayPrompt() {
    final staff = sl<StaffSession>().current;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(
          icon: Icons.wb_sunny_rounded,
          iconColor: AppColors.warning,
          iconBg: AppColors.warningContainer,
          bg: AppColors.warning,
          title: 'Sunday — Weekly Off',
          subtitle: 'Today is a company-wide holiday. No attendance required.',
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _infoCard(staff, statusLabel: 'Weekly Off', statusColor: AppColors.warning, bg: AppColors.warningContainer),
              const SizedBox(height: AppSpacing.lg),
              _button(
                label: 'CONFIRM WEEKLY OFF',
                icon: Icons.wb_sunny_rounded,
                color: AppColors.warning,
                loading: _marking,
                onPressed: () => _mark('Weekly Off'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your Weekly Off status will be recorded for payroll processing.',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _markPrompt() {
    final staff = sl<StaffSession>().current;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(
          icon: Icons.event_available_rounded,
          iconColor: AppColors.brandYellow,
          iconBg: AppColors.secondaryNavy,
          bg: AppColors.secondaryNavy,
          title: 'Daily Attendance',
          subtitle: 'Mark your attendance to start your shift',
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _infoCard(staff, statusLabel: 'Present', statusColor: AppColors.success, bg: AppColors.surface),
              const SizedBox(height: AppSpacing.lg),
              _button(
                label: 'MARK PRESENT',
                icon: Icons.check_circle_rounded,
                color: AppColors.primary,
                loading: _marking,
                onPressed: () => _mark('Present'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _marking ? null : _confirmLeave,
                icon: const Icon(Icons.flight_takeoff_rounded, size: 18, color: Colors.orange),
                label: const Text('ON LEAVE TODAY'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                  textStyle: AppTypography.labelMedium.copyWith(letterSpacing: 1),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'By marking Present you confirm your availability for the day. Leaves beyond 2 '
                'in a month are deducted from salary.',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _doneCard({required bool sunday}) {
    final isLeave = _status == 'Leave';
    final isWeeklyOff = sunday || _status == 'Weekly Off';
    final IconData icon;
    final Color color;
    final Color bg;
    final String title;
    final String message;
    if (isWeeklyOff) {
      icon = Icons.wb_sunny_rounded;
      color = AppColors.warning;
      bg = AppColors.warningContainer;
      title = 'Weekly Off';
      message = 'Your Weekly Off has been recorded for today.';
    } else if (isLeave) {
      icon = Icons.flight_takeoff_rounded;
      color = Colors.orange;
      bg = const Color(0xFFFFF3E0);
      title = 'Leave Recorded';
      message = 'You\'ve been marked on Leave for today. Leaves beyond 2 in a month are '
          'deducted from salary.';
    } else {
      icon = Icons.check_circle_rounded;
      color = AppColors.success;
      bg = AppColors.successContainer;
      title = 'Attendance Marked';
      message = 'You\'ve been marked Present for today.';
    }
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 34),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTypography.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: AppTypography.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          _button(
            label: 'CONTINUE TO PORTAL',
            color: color,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _header({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color bg,
    required String title,
    required String subtitle,
  }) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        width: double.infinity,
        color: bg,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.labelSmall.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
    StaffEntity? staff, {
    required String statusLabel,
    required Color statusColor,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _infoRow('Employee', staff?.name ?? '—'),
          _infoRow('Employee ID', staff?.employeeId ?? '—'),
          _infoRow('Date', DateFormat('EEEE, d MMMM yyyy').format(DateTime.now())),
          _infoRow('Status', statusLabel, valueColor: statusColor),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(color: valueColor ?? AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _button({
    required String label,
    IconData? icon,
    required Color color,
    bool loading = false,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Icon(icon, size: 18, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        textStyle: AppTypography.labelMedium.copyWith(letterSpacing: 1, color: Colors.white),
      ),
    );
  }
}

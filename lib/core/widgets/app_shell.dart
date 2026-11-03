import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/enquiry/presentation/widgets/enquiry_form_sheet.dart';
import '../routing/route_names.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(RouteNames.solutions)) return 1;
    if (location.startsWith(RouteNames.projects)) return 3;
    if (location.startsWith(RouteNames.more) ||
        location.startsWith(RouteNames.about) ||
        location.startsWith(RouteNames.faq) ||
        location.startsWith(RouteNames.contact)) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.background,
            boxShadow: [
              BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, -2)),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: index == 0,
                onTap: () => context.go(RouteNames.home),
              ),
              _NavItem(
                icon: Icons.solar_power_rounded,
                label: 'Solutions',
                selected: index == 1,
                onTap: () => context.go(RouteNames.solutions),
              ),
              _QuoteNavItem(
                onTap: () => showEnquiryFormSheet(context, source: 'bottom_nav'),
              ),
              _NavItem(
                icon: Icons.photo_library_rounded,
                label: 'Projects',
                selected: index == 3,
                onTap: () => context.go(RouteNames.projects),
              ),
              _NavItem(
                icon: Icons.menu_rounded,
                label: 'More',
                selected: index == 4,
                onTap: () => context.go(RouteNames.more),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textTertiary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label, style: AppTypography.labelSmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _QuoteNavItem extends StatelessWidget {
  final VoidCallback onTap;

  const _QuoteNavItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.brandYellow,
                shape: BoxShape.circle,
                boxShadow: AppShadows.glow(AppColors.brandYellow),
              ),
              child: const Icon(Icons.bolt_rounded, color: AppColors.textHeading, size: 24),
            ),
            const SizedBox(height: 2),
            Text(
              'Get Quote',
              style: AppTypography.labelSmall.copyWith(color: AppColors.textHeading),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_strings.dart';
import '../routing/route_names.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/launcher_helper.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  static const double _height = 64;

  final String? title;

  const AppTopBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _height,
      title: title == null
          ? InkWell(
              onTap: () => context.go(RouteNames.home),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Image.asset(
                  'assets/images/solar_universe_logo_tight.png',
                  height: _height - 12,
                  fit: BoxFit.contain,
                ),
              ),
            )
          : Text(title!, style: AppTypography.headlineSmall),
      actions: [
        IconButton(
          onPressed: () => context.push(RouteNames.customerLogin),
          icon: const Icon(Icons.person_rounded, color: AppColors.primary),
          tooltip: 'My Account',
        ),
        IconButton(
          onPressed: () => context.push(RouteNames.staffLogin),
          icon: const Icon(Icons.badge_rounded, color: AppColors.primary),
          tooltip: 'Staff Login',
        ),
        IconButton(
          onPressed: () => LauncherHelper.call(AppStrings.primaryContactNumber),
          icon: const Icon(Icons.call_rounded, color: AppColors.primary),
          tooltip: 'Call Now',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_height);
}

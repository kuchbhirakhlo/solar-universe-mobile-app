import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solaruniverse/core/constants/app_strings.dart';
import 'package:solaruniverse/core/routing/app_router.dart';
import 'package:solaruniverse/core/services/staff_location_tracker.dart';
import 'package:solaruniverse/core/session/customer_session.dart';
import 'package:solaruniverse/core/session/staff_session.dart';
import 'package:solaruniverse/core/theme/app_theme.dart';
import 'package:solaruniverse/firebase_options.dart';
import 'package:solaruniverse/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupDependencies();
  runApp(SolarUniverseApp(router: buildAppRouter(sl<StaffSession>(), sl<CustomerSession>())));
}

class SolarUniverseApp extends StatefulWidget {
  final GoRouter router;

  const SolarUniverseApp({super.key, required this.router});

  @override
  State<SolarUniverseApp> createState() => _SolarUniverseAppState();
}

class _SolarUniverseAppState extends State<SolarUniverseApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // paused = minimized — keep tracking. detached = process going away.
    if (state == AppLifecycleState.detached) {
      unawaited(sl<StaffLocationTracker>().stop());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.light,
      routerConfig: widget.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

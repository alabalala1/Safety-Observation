import 'package:flutter/material.dart';

import 'app_services.dart';
import '../core/l10n/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/settings/presentation/role_activation_screen.dart';
import 'user_role.dart';

class SafetyObservationApp extends StatefulWidget {
  const SafetyObservationApp({super.key});

  @override
  State<SafetyObservationApp> createState() => _SafetyObservationAppState();
}

class _SafetyObservationAppState extends State<SafetyObservationApp> {
  late Future<UserRole?> _role = _loadRole();

  Future<UserRole?> _loadRole() async {
    final value = await AppServices.reports.loadSetting('userRole');
    for (final role in UserRole.values) {
      if (role.name == value) return role;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: FutureBuilder<UserRole?>(
        future: _role,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          final role = snapshot.data;
          if (role == null) {
            return RoleActivationScreen(
                onActivated: (value) => setState(() {
                      _role = Future.value(value);
                    }));
          }
          return HomeScreen(
              role: role,
              onChangeRole: () async {
                await AppServices.reports.saveSetting('userRole', '');
                if (mounted) setState(() => _role = Future.value(null));
              });
        },
      ),
    );
  }
}

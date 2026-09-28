import 'package:flutter/material.dart';

import '../core/l10n/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../features/home/presentation/home_screen.dart';

class SafetyObservationApp extends StatelessWidget {
  const SafetyObservationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}

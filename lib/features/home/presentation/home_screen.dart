import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';

/// Initial entry point. The Figma layout and its SVG assets are being brought
/// into this file in the next UI milestone; no example counts are shown.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(child: Text(AppStrings.shortAppName)),
      ),
    );
  }
}

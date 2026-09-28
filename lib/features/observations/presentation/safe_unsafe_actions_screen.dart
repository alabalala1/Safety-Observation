import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/observation_report.dart';
import 'observation_form_widgets.dart';
import 'risk_ranking_screen.dart';

const _icons = 'safe_unsafe_actions';

class SafeUnsafeActionsScreen extends StatefulWidget {
  const SafeUnsafeActionsScreen({super.key, required this.report});
  final ObservationReport report;

  @override
  State<SafeUnsafeActionsScreen> createState() => _SafeUnsafeActionsScreenState();
}

class _SafeUnsafeActionsScreenState extends State<SafeUnsafeActionsScreen> {
  late final TextEditingController _encouragement =
      TextEditingController(text: widget.report.encouragement);
  late final TextEditingController _correction =
      TextEditingController(text: widget.report.immediateCorrectiveAction);

  @override
  void dispose() {
    _encouragement.dispose();
    _correction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final positiveOnly = widget.report.type == ObservationType.stopCard &&
        widget.report.stopCardCategory == StopCardCategory.positive;
    final correctiveOnly = widget.report.type == ObservationType.stopCard &&
        widget.report.stopCardCategory == StopCardCategory.unsafeCorrective;
    return ObservationStepScaffold(
    title: AppStrings.safeUnsafeActions,
    step: 8,
    iconDirectory: _icons,
    onContinue: () => Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => RiskRankingScreen(report: widget.report.withDetails(
        encouragement: _encouragement.text.trim(),
        immediateCorrectiveAction: _correction.text.trim(),
      )),
    )),
    children: [
      const ObservationNotice(text: AppStrings.safeUnsafeNotice,
        iconDirectory: _icons, icon: 'info'),
      const SizedBox(height: 20),
      if (!correctiveOnly) ...[
        ObservationTextArea(label: AppStrings.encouragementLabel,
          hint: AppStrings.encouragementHint, controller: _encouragement, height: 130),
        const SizedBox(height: 20),
      ],
      if (!positiveOnly)
        ObservationTextArea(label: AppStrings.immediateCorrectionLabel,
          hint: AppStrings.immediateCorrectionHint, controller: _correction, height: 130),
      const SizedBox(height: 16),
      const Text(AppStrings.safeUnsafeHint, style: TextStyle(
        color: AppColors.mutedInk, fontSize: 12)),
    ],
  );
  }
}

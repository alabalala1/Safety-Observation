import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/observation_report.dart';
import '../data/draft_autosave.dart';
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
  late final DraftAutosave _autosave = DraftAutosave(widget.report.id, (_) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.saveFailed)));
  });

  @override
  void initState() {
    super.initState();
    _encouragement.addListener(_schedule);
    _correction.addListener(_schedule);
  }

  void _schedule() {
    final encouragement = _encouragement.text.trim();
    final correction = _correction.text.trim();
    _autosave.schedule((report) => report.withDetails(
      encouragement: encouragement, immediateCorrectiveAction: correction));
  }

  Future<void> _continue() async {
    try {
      final report = await _autosave.flush();
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => RiskRankingScreen(report: report)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.saveFailed)));
    }
  }

  @override
  void dispose() {
    _autosave.close();
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
    onContinue: _continue,
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

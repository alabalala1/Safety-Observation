import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../domain/observation_report.dart';
import '../data/draft_autosave.dart';
import 'observation_form_widgets.dart';
import 'safety_categories_screen.dart';

const _icons = 'action_taken';

class ActionTakenScreen extends StatefulWidget {
  const ActionTakenScreen({super.key, required this.report});
  final ObservationReport report;

  @override
  State<ActionTakenScreen> createState() => _ActionTakenScreenState();
}

class _ActionTakenScreenState extends State<ActionTakenScreen> {
  late final TextEditingController _action =
      TextEditingController(text: widget.report.actionTaken);
  late final TextEditingController _further =
      TextEditingController(text: widget.report.furtherActions);
  late final DraftAutosave _autosave = DraftAutosave(widget.report.id, (_) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.saveFailed)));
  });

  @override
  void initState() {
    super.initState();
    _action.addListener(_schedule);
    _further.addListener(_schedule);
  }

  void _schedule() {
    final action = _action.text.trim();
    final further = _further.text.trim();
    _autosave.schedule((report) => report.withDetails(
      actionTaken: action, furtherActions: further));
  }

  @override
  void dispose() {
    _autosave.close();
    _action.dispose();
    _further.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_action.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.actionRequired)));
      return;
    }
    try {
      final report = await _autosave.flush();
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => SafetyCategoriesScreen(report: report),
      ));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.saveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) => ObservationStepScaffold(
    title: AppStrings.actionTaken,
    step: 6,
    iconDirectory: _icons,
    onContinue: _continue,
    children: [
      const ObservationNotice(text: AppStrings.actionTakenNotice,
        iconDirectory: _icons, icon: 'info'),
      const SizedBox(height: 20),
      ObservationTextArea(label: AppStrings.actionTakenLabel,
        hint: AppStrings.actionTakenHint, controller: _action, height: 154),
      const SizedBox(height: 20),
      ObservationTextArea(label: AppStrings.furtherActionsLabel,
        hint: AppStrings.furtherActionsHint, controller: _further, height: 154),
    ],
  );
}

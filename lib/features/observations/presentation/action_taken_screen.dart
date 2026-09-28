import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../domain/observation_report.dart';
import 'observation_form_widgets.dart';

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

  @override
  void dispose() {
    _action.dispose();
    _further.dispose();
    super.dispose();
  }

  void _continue() {
    if (_action.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.actionRequired)));
      return;
    }
    final report = widget.report.withDetails(
      actionTaken: _action.text.trim(), furtherActions: _further.text.trim());
    // Keep the draft in memory until local persistence and the next screen exist.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${AppStrings.nextScreenPending} ${report.id}'),
    ));
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

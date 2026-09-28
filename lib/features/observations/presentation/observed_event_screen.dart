import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../domain/observation_report.dart';
import '../data/draft_autosave.dart';
import 'observation_form_widgets.dart';
import 'potential_hazard_screen.dart';

const _icons = 'observed_event';

class ObservedEventScreen extends StatefulWidget {
  const ObservedEventScreen({super.key, required this.report});
  final ObservationReport report;

  @override
  State<ObservedEventScreen> createState() => _ObservedEventScreenState();
}

class _ObservedEventScreenState extends State<ObservedEventScreen> {
  late final TextEditingController _description =
      TextEditingController(text: widget.report.observedEvent);
  late final DraftAutosave _autosave = DraftAutosave(widget.report.id, (_) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.saveFailed)));
  });

  @override
  void initState() {
    super.initState();
    _description.addListener(() {
      final text = _description.text.trim();
      _autosave.schedule((report) => report.withDetails(observedEvent: text));
    });
  }

  @override
  void dispose() {
    _autosave.close();
    _description.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_description.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.eventRequired)));
      return;
    }
    try {
      final report = await _autosave.flush();
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => PotentialHazardScreen(report: report),
      ));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.saveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) => ObservationStepScaffold(
    title: AppStrings.observedEvent,
    step: 4,
    iconDirectory: _icons,
    onContinue: _continue,
    children: [
      const ObservationNotice(text: AppStrings.observedEventNotice,
        iconDirectory: _icons, icon: 'info'),
      const SizedBox(height: 20),
      ObservationTextArea(label: AppStrings.describeObservedEvent,
        hint: AppStrings.observedEventHint, controller: _description),
      const SizedBox(height: 20),
      EvidencePhotos(reportId: widget.report.id,
        iconDirectory: _icons, initialPaths: widget.report.attachmentPaths),
    ],
  );
}

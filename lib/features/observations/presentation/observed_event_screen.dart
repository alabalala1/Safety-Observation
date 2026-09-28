import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/observation_report.dart';
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

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  void _continue() {
    if (_description.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.eventRequired)));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PotentialHazardScreen(report: widget.report.withDetails(
        observedEvent: _description.text.trim(),
      )),
    ));
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
      const ObservationFieldLabel(AppStrings.evidencePhotos),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.photosPending))),
        icon: const ObservationIcon(_icons, 'camera', 18),
        label: const Text(AppStrings.addPhoto),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondaryInk,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.centerLeft,
        ),
      ),
    ],
  );
}

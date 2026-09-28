import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/observation_report.dart';
import '../data/draft_autosave.dart';
import 'action_taken_screen.dart';
import 'observation_form_widgets.dart';

const _icons = 'potential_hazard';

class PotentialHazardScreen extends StatefulWidget {
  const PotentialHazardScreen({super.key, required this.report});
  final ObservationReport report;

  @override
  State<PotentialHazardScreen> createState() => _PotentialHazardScreenState();
}

class _PotentialHazardScreenState extends State<PotentialHazardScreen> {
  late final TextEditingController _description =
      TextEditingController(text: widget.report.potentialHazard);
  late final DraftAutosave _autosave = DraftAutosave(widget.report.id, (_) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.saveFailed)));
  });

  @override
  void initState() {
    super.initState();
    _description.addListener(() {
      final text = _description.text.trim();
      _autosave.schedule((report) => report.withDetails(potentialHazard: text));
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
        const SnackBar(content: Text(AppStrings.hazardRequired)));
      return;
    }
    try {
      final report = await _autosave.flush();
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ActionTakenScreen(report: report),
      ));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.saveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) => ObservationStepScaffold(
    title: AppStrings.potentialHazard,
    step: 5,
    iconDirectory: _icons,
    onContinue: _continue,
    children: [
      const ObservationNotice(text: AppStrings.potentialHazardNotice,
        iconDirectory: _icons, icon: 'info'),
      const SizedBox(height: 20),
      ObservationTextArea(label: AppStrings.describePotentialHazard,
        hint: AppStrings.potentialHazardHint, controller: _description),
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

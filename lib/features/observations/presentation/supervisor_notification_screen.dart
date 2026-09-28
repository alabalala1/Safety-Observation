import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/observation_report.dart';
import 'attachments_screen.dart';
import 'observation_form_widgets.dart';

const _icons = 'supervisor_notification';

class SupervisorNotificationScreen extends StatefulWidget {
  const SupervisorNotificationScreen({super.key, required this.report});
  final ObservationReport report;

  @override
  State<SupervisorNotificationScreen> createState() => _SupervisorNotificationScreenState();
}

class _SupervisorNotificationScreenState extends State<SupervisorNotificationScreen> {
  late bool _notified = widget.report.supervisorNotified;
  late final TextEditingController _name =
      TextEditingController(text: widget.report.supervisorName);
  late final TextEditingController _notes =
      TextEditingController(text: widget.report.supervisorFurtherAction);

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _continue() {
    if (_notified && _name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.supervisorNameRequired)));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => AttachmentsScreen(report: widget.report.withDetails(
        supervisorNotified: _notified,
        supervisorName: _notified ? _name.text.trim() : '',
        supervisorFurtherAction: _notes.text.trim(),
      )),
    ));
  }

  @override
  Widget build(BuildContext context) => ObservationStepScaffold(
    title: AppStrings.supervisor,
    step: 10,
    iconDirectory: _icons,
    onContinue: _continue,
    children: [
      Row(children: [
        const Expanded(child: Text(AppStrings.supervisorNotified,
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800))),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text(AppStrings.yes)),
            ButtonSegment(value: false, label: Text(AppStrings.no)),
          ],
          selected: {_notified},
          onSelectionChanged: (selection) => setState(() => _notified = selection.first),
        ),
      ]),
      if (_notified) ...[
        const SizedBox(height: 20),
        const ObservationFieldLabel(AppStrings.supervisorName),
        const SizedBox(height: 6),
        TextField(controller: _name, decoration: InputDecoration(
          hintText: AppStrings.enterSupervisorName,
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        )),
        const SizedBox(height: 20),
        const ObservationFieldLabel(AppStrings.supervisorSignature),
        const SizedBox(height: 6),
        Container(
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC),
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(10)),
          child: const Text(AppStrings.signaturePending,
            style: TextStyle(color: AppColors.mutedInk, fontSize: 13)),
        ),
      ],
      const SizedBox(height: 20),
      ObservationTextArea(label: AppStrings.supervisorNotes,
        hint: AppStrings.supervisorNotesHint, controller: _notes, height: 90),
    ],
  );
}

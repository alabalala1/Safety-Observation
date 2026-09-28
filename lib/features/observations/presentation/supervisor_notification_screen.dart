import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../../app/app_services.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/observation_report.dart';
import '../data/draft_autosave.dart';
import 'attachments_screen.dart';
import 'observation_form_widgets.dart';
import 'signature_pad_dialog.dart';

const _icons = 'supervisor_notification';

class SupervisorNotificationScreen extends StatefulWidget {
  const SupervisorNotificationScreen({super.key, required this.report});
  final ObservationReport report;

  @override
  State<SupervisorNotificationScreen> createState() => _SupervisorNotificationScreenState();
}

class _SupervisorNotificationScreenState extends State<SupervisorNotificationScreen> {
  late bool _notified = widget.report.supervisorNotified;
  late String? _signaturePath = widget.report.signaturePath;
  late final TextEditingController _name =
      TextEditingController(text: widget.report.supervisorName);
  late final TextEditingController _notes =
      TextEditingController(text: widget.report.supervisorFurtherAction);
  late final DraftAutosave _autosave = DraftAutosave(widget.report.id, (_) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.saveFailed)));
  });

  @override
  void initState() {
    super.initState();
    _name.addListener(_schedule);
    _notes.addListener(_schedule);
  }

  void _schedule() {
    final notified = _notified;
    final name = _name.text.trim();
    final notes = _notes.text.trim();
    _autosave.schedule((report) => report.withDetails(
      supervisorNotified: notified,
      supervisorName: notified ? name : '',
      supervisorFurtherAction: notes,
    ));
  }

  Future<void> _captureSignature() async {
    final bytes = await showDialog<Uint8List>(context: context,
      builder: (_) => const SignaturePadDialog());
    if (bytes == null) return;
    try {
      final report = await AppServices.media.saveSignature(widget.report.id, bytes);
      if (mounted) setState(() => _signaturePath = report.signaturePath);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.saveFailed)));
    }
  }

  @override
  void dispose() {
    _autosave.close();
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_notified && _name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.supervisorNameRequired)));
      return;
    }
    try {
      final report = await _autosave.flush();
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => AttachmentsScreen(report: report)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.saveFailed)));
    }
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
          onSelectionChanged: (selection) {
            setState(() => _notified = selection.first);
            _schedule();
          },
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
        InkWell(onTap: _captureSignature,
          child: Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC),
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(10)),
            child: _signaturePath == null
                ? const Text(AppStrings.tapToSign,
                    style: TextStyle(color: AppColors.mutedInk, fontSize: 13))
                : Image.file(File(_signaturePath!), fit: BoxFit.contain),
          ),
        ),
      ],
      const SizedBox(height: 20),
      ObservationTextArea(label: AppStrings.supervisorNotes,
        hint: AppStrings.supervisorNotesHint, controller: _notes, height: 90),
    ],
  );
}

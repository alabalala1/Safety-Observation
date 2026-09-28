import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../app/app_services.dart';
import '../../observations/domain/observation_report.dart';
import '../../observations/presentation/observation_form_widgets.dart';
import '../../observations/presentation/basic_information_screen.dart';
import '../data/report_pdf.dart';
import '../data/report_transfer.dart';

const _icons = 'report_details';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key, required this.report});
  final ObservationReport report;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          InkWell(onTap: () => Navigator.of(context).pop(),
            child: const ObservationIcon(_icons, 'arrow_left', 36)),
          const SizedBox(width: 8),
          const Expanded(child: Text(AppStrings.reportDetails,
            style: TextStyle(fontSize: 18, color: AppColors.ink,
              fontWeight: FontWeight.w800))),
          Text(AppStrings.statusLabel(report.status),
            style: const TextStyle(color: AppColors.orange, fontSize: 11)),
        ]),
      ),
      Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(report.id, style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w800, color: AppColors.ink)),
                const Text(AppStrings.reportId, style: TextStyle(
                  color: AppColors.mutedInk, fontSize: 10)),
              ])),
              if (report.risk != null) Text(AppStrings.riskLabel(report.risk!),
                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11,
                  fontWeight: FontWeight.w800)),
            ]),
            const Divider(height: 24),
            _DetailLine(AppStrings.type, AppStrings.typeLabel(report.type)),
            _DetailLine(AppStrings.area, report.area),
            _DetailLine(AppStrings.dateRecorded,
              MaterialLocalizations.of(context).formatMediumDate(report.createdAt.toLocal())),
          ]),
        ),
        const SizedBox(height: 20),
        if (report.employeeName.isNotEmpty) ...[
          const ObservationFieldLabel(AppStrings.employeeInfo),
          const SizedBox(height: 6),
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const ObservationIcon(_icons, 'user', 18),
              const SizedBox(width: 12),
              Expanded(child: Text(report.employeeName,
                style: const TextStyle(fontWeight: FontWeight.w700))),
            ]),
          ),
          const SizedBox(height: 20),
        ],
        _DetailText(AppStrings.observedEvent, report.observedEvent),
        _DetailText(AppStrings.potentialHazard, report.potentialHazard),
        _DetailText(AppStrings.actionTaken, report.actionTaken),
        if (report.safetyCategories.isNotEmpty) ...[
          const ObservationFieldLabel(AppStrings.safetyCategories),
          const SizedBox(height: 8),
          Wrap(spacing: 6, children: report.safetyCategories.map((e) => Chip(
            label: Text(e), backgroundColor: const Color(0xFFFFEDD5))).toList()),
          const SizedBox(height: 20),
        ],
        if (report.attachmentPaths.isNotEmpty) ...[
          const ObservationFieldLabel(AppStrings.evidencePhotos),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final path in report.attachmentPaths)
              ClipRRect(borderRadius: BorderRadius.circular(8),
                child: Image.file(File(path), width: 96, height: 96, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(width: 96, height: 96,
                    child: Icon(Icons.broken_image_outlined)))),
          ]),
          const SizedBox(height: 20),
        ],
        if (report.supervisorNotified && report.supervisorName.isNotEmpty) ...[
          const ObservationFieldLabel(AppStrings.supervisor),
          const SizedBox(height: 8),
          Row(children: [const ObservationIcon(_icons, 'check_circle', 18),
            const SizedBox(width: 8), Text(report.supervisorName)]),
        ],
        if (report.signaturePath != null) ...[
          const SizedBox(height: 16),
          const ObservationFieldLabel(AppStrings.supervisorSignature),
          Image.file(File(report.signaturePath!), height: 72, fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined)),
        ],
      ])),
      Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          _ActionButton(AppStrings.edit, 'pencil', () => _edit(context)),
          _ActionButton(AppStrings.exportPdf, 'file_text', () => _exportPdf(context)),
          _ActionButton(AppStrings.exportSafety, 'download', () => _exportSafety(context)),
          _ActionButton(AppStrings.duplicate, 'copy', () => _duplicate(context)),
          _ActionButton(AppStrings.deleteReport, 'trash', () => _delete(context)),
        ]),
      ),
    ])),
  );

  Future<void> _exportPdf(BuildContext context) async {
    try {
      final latest = await AppServices.reports.findById(report.id);
      if (latest == null) throw StateError('Report missing');
      final bytes = await ReportPdf.build(latest);
      if (!context.mounted) return;
      await Printing.sharePdf(bytes: bytes, filename: '${report.id}.pdf');
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.pdfFailed)));
    }
  }

  Future<void> _exportSafety(BuildContext context) async {
    try {
      final latest = await AppServices.reports.findById(report.id);
      if (latest == null) throw StateError('Report missing');
      final file = await ReportTransfer.exportReport(latest);
      if (!context.mounted) return;
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.exportFailed)));
    }
  }

  Future<void> _edit(BuildContext context) async {
    try {
      final latest = await AppServices.reports.update(report.id,
        (value) => value.withDetails(status: ReportStatus.draft));
      if (!context.mounted) return;
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => BasicInformationScreen(report: latest)));
      if (context.mounted) Navigator.of(context).pop();
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.loadFailed)));
    }
  }

  Future<void> _duplicate(BuildContext context) async {
    try {
      final fresh = ObservationReport.newDraft(type: report.type,
        stopCardCategory: report.stopCardCategory).withDetails(
          area: report.area,
          employeeName: report.employeeName,
          employeeNumber: report.employeeNumber,
          employeeDepartment: report.employeeDepartment,
          observedEvent: report.observedEvent,
          potentialHazard: report.potentialHazard,
          actionTaken: report.actionTaken,
          furtherActions: report.furtherActions,
          safetyCategories: List.of(report.safetyCategories),
          encouragement: report.encouragement,
          immediateCorrectiveAction: report.immediateCorrectiveAction,
          risk: report.risk,
        );
      await AppServices.reports.save(fresh);
      if (!context.mounted) return;
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => BasicInformationScreen(report: fresh)));
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.saveFailed)));
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialog) => AlertDialog(
      title: const Text(AppStrings.deleteReport),
      content: const Text(AppStrings.deleteConfirm),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text(AppStrings.cancel)),
        FilledButton(onPressed: () => Navigator.pop(dialog, true), child: const Text(AppStrings.deleteReport)),
      ],
    ));
    if (confirmed != true) return;
    try {
      await AppServices.reports.delete(report.id);
      await AppServices.media.deleteMedia(report.id);
      if (context.mounted) Navigator.of(context).pop();
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.deleteFailed)));
    }
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Text(label, style: const TextStyle(color: AppColors.mutedInk, fontSize: 12)),
      const Spacer(),
      Flexible(child: Text(value, textAlign: TextAlign.right,
        style: const TextStyle(color: AppColors.ink, fontSize: 12,
          fontWeight: FontWeight.w700))),
    ]),
  );
}

class _DetailText extends StatelessWidget {
  const _DetailText(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ObservationFieldLabel(label),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(color: AppColors.ink, fontSize: 13, height: 1.4)),
    ]),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(this.label, this.icon, this.onPressed);
  final String label;
  final String icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: ObservationIcon(_icons, icon, 16),
    label: Text(label),
  );
}

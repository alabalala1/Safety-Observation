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
import '../../settings/presentation/active_site_bar.dart';
import '../../settings/data/report_date_format.dart';

const _icons = 'report_details';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key, required this.report});
  final ObservationReport report;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<String?>>(
    future: Future.wait([AppServices.reports.loadSetting('dateFormat'),
      AppServices.reports.loadSetting('timeFormat')]),
    builder: (context, preferences) => _content(context,
      preferences.data?.first ?? 'DD MMM YYYY'),
  );

  Widget _content(BuildContext context, String dateFormat) => Scaffold(
    body: SafeArea(child: Column(children: [
      const ActiveSiteBar(),
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
              ReportDateFormat.date(report.createdAt.toLocal(), dateFormat)),
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
        decoration: const BoxDecoration(color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(child: _FooterAction(AppStrings.edit, 'pencil', AppColors.orange,
              Colors.white, () => _edit(context), primary: true)),
            const SizedBox(width: 8),
            Expanded(child: _FooterAction(AppStrings.exportPdf, 'file_text', AppColors.ink,
              Colors.white, () => _exportPdf(context), primary: true)),
            const SizedBox(width: 8),
            SizedBox(width: 44, child: _FooterAction('', 'share',
              const Color(0xFFF8FAFC), AppColors.ink,
              () => _exportSafety(context))),
          ]),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.border)),
          SizedBox(width: double.infinity, child: _FooterAction(
            AppStrings.exportSafety, 'download', const Color(0xFFF8FAFC),
            AppColors.secondaryInk, () => _exportSafety(context), compact: true)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _FooterAction(AppStrings.duplicate, 'copy',
              const Color(0xFFF8FAFC), AppColors.secondaryInk,
              () => _duplicate(context), compact: true)),
            const SizedBox(width: 8),
            Expanded(child: _FooterAction(AppStrings.deleteReport, 'trash',
              const Color(0xFFFEE2E2), const Color(0xFFEF4444),
              () => _delete(context), compact: true, danger: true)),
          ]),
        ]),
      ),
      const Padding(padding: EdgeInsets.fromLTRB(20, 12, 20, 18),
        child: Column(children: [
          Text(AppStrings.buildInfo, style: TextStyle(fontSize: 11,
            fontWeight: FontWeight.w700, color: AppColors.mutedInk)),
          SizedBox(height: 4),
          Text(AppStrings.hardwareInfo, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: AppColors.mutedInk)),
        ])),
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
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => BasicInformationScreen(report: latest)));
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

class _FooterAction extends StatelessWidget {
  const _FooterAction(this.label, this.icon, this.background, this.foreground,
    this.onPressed, {this.primary = false, this.compact = false, this.danger = false});
  final String label, icon;
  final Color background, foreground;
  final VoidCallback onPressed;
  final bool primary, compact, danger;

  @override
  Widget build(BuildContext context) => Material(
    color: background,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(primary ? 10 : 8),
      side: primary ? BorderSide.none : BorderSide(
        color: danger ? const Color(0xFFEF4444) : AppColors.border)),
    child: InkWell(onTap: onPressed,
      borderRadius: BorderRadius.circular(primary ? 10 : 8),
      child: SizedBox(height: primary ? 44 : compact ? 34 : 44,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ObservationIcon(_icons, icon, compact ? 14 : 16),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 7),
            Flexible(child: Text(label, maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w700, color: foreground))),
          ],
        ])),
    ),
  );
}

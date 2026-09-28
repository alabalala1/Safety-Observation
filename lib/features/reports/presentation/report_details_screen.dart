import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../observations/domain/observation_report.dart';
import '../../observations/presentation/observation_form_widgets.dart';

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
        if (report.supervisorNotified && report.supervisorName.isNotEmpty) ...[
          const ObservationFieldLabel(AppStrings.supervisor),
          const SizedBox(height: 8),
          Row(children: [const ObservationIcon(_icons, 'check_circle', 18),
            const SizedBox(width: 8), Text(report.supervisorName)]),
        ],
      ])),
      Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          _ActionButton(AppStrings.edit, 'pencil', () => _pending(context)),
          _ActionButton(AppStrings.exportPdf, 'file_text', () => _pending(context)),
          _ActionButton(AppStrings.exportSafety, 'download', () => _pending(context)),
          _ActionButton(AppStrings.duplicate, 'copy', () => _pending(context)),
          _ActionButton(AppStrings.deleteReport, 'trash', () => _pending(context)),
        ]),
      ),
    ])),
  );

  void _pending(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text(AppStrings.reportActionsPending)));
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

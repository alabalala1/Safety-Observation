import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../app/app_services.dart';
import '../domain/observation_report.dart';
import 'observation_form_widgets.dart';

const _icons = 'review_and_save';

class ReviewAndSaveScreen extends StatelessWidget {
  const ReviewAndSaveScreen({super.key, required this.report});
  final ObservationReport report;

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(report.createdAt.toLocal());
    return ObservationStepScaffold(
      title: AppStrings.reviewAndSave,
      step: 10,
      showStepBadge: false,
      progress: 1,
      iconDirectory: _icons,
      buttonLabel: AppStrings.completeReport,
      onContinue: () => _save(context, complete: true),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white,
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(report.id, style: const TextStyle(color: AppColors.ink,
                  fontSize: 16, fontWeight: FontWeight.w800)),
                const Text(AppStrings.reportId, style: TextStyle(
                  color: AppColors.mutedInk, fontSize: 11)),
              ])),
              if (report.risk != null) Text(AppStrings.riskLabel(report.risk!),
                style: const TextStyle(color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w800, fontSize: 12)),
            ]),
            const Divider(height: 28),
            _SummaryRow(AppStrings.type, AppStrings.typeLabel(report.type)),
            const SizedBox(height: 8),
            _SummaryRow(AppStrings.area, report.area),
            const SizedBox(height: 8),
            _SummaryRow(AppStrings.dateRecorded, date),
          ]),
        ),
        const SizedBox(height: 20),
        if (report.safetyCategories.isNotEmpty) ...[
          const ObservationFieldLabel(AppStrings.selectedCategories),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6,
            children: report.safetyCategories.map((category) => Chip(label: Text(category),
              backgroundColor: const Color(0xFFFFEDD5))).toList()),
          const SizedBox(height: 20),
        ],
        _SummaryText(AppStrings.observedEvent, report.observedEvent),
        const SizedBox(height: 16),
        _SummaryText(AppStrings.potentialHazard, report.potentialHazard),
        const SizedBox(height: 16),
        _SummaryText(AppStrings.actionTaken, report.actionTaken),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () => _save(context, complete: false),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text(AppStrings.saveDraftOnly),
        ),
      ],
    );
  }

  Future<void> _save(BuildContext context, {required bool complete}) async {
    try {
      final current = await AppServices.reports.findById(report.id);
      if (current == null) throw StateError('Report not found');
      if (complete && (current.area.isEmpty || current.employeeName.isEmpty ||
          current.observedEvent.isEmpty || current.potentialHazard.isEmpty ||
          current.actionTaken.isEmpty || current.risk == null)) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.completeRequired)));
        return;
      }
      await AppServices.reports.update(report.id, (value) => value.withDetails(
        status: complete ? ReportStatus.completed : ReportStatus.draft));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
        complete ? AppStrings.reportCompleted : AppStrings.draftSaved)));
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.saveFailed)));
    }
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(label, style: const TextStyle(color: AppColors.mutedInk, fontSize: 13)),
    const Spacer(),
    Flexible(child: Text(value, textAlign: TextAlign.right,
      style: const TextStyle(color: AppColors.ink, fontSize: 13, fontWeight: FontWeight.w700))),
  ]);
}

class _SummaryText extends StatelessWidget {
  const _SummaryText(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ObservationFieldLabel(label),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(color: AppColors.ink, fontSize: 13, height: 1.4)),
    ],
  );
}

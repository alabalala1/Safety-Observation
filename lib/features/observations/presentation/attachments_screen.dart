import 'package:flutter/material.dart';

import '../../../app/app_services.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/observation_report.dart';
import 'observation_form_widgets.dart';
import 'review_and_save_screen.dart';

const _icons = 'attachments';

class AttachmentsScreen extends StatelessWidget {
  const AttachmentsScreen({super.key, required this.report});
  final ObservationReport report;

  Future<void> _continue(BuildContext context) async {
    try {
      final latest = await AppServices.reports.findById(report.id);
      if (latest == null) throw StateError('Draft not found');
      if (!context.mounted) return;
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ReviewAndSaveScreen(report: latest)));
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.loadFailed)));
    }
  }

  @override
  Widget build(BuildContext context) => ObservationStepScaffold(
    title: AppStrings.attachments,
    step: 10,
    showStepBadge: false,
    progress: .65,
    iconDirectory: _icons,
    onContinue: () => _continue(context),
    children: [
      const Text(AppStrings.uploadEvidencePhotos,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
          color: AppColors.ink)),
      const SizedBox(height: 16),
      EvidencePhotos(reportId: report.id, iconDirectory: _icons,
        initialPaths: report.attachmentPaths),
    ],
  );
}

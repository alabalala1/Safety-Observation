import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/observation_report.dart';
import 'observation_form_widgets.dart';
import 'review_and_save_screen.dart';

const _icons = 'attachments';

class AttachmentsScreen extends StatelessWidget {
  const AttachmentsScreen({super.key, required this.report});
  final ObservationReport report;

  @override
  Widget build(BuildContext context) => ObservationStepScaffold(
    title: AppStrings.attachments,
    step: 10,
    showStepBadge: false,
    progress: .65,
    iconDirectory: _icons,
    onContinue: () => Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ReviewAndSaveScreen(report: report),
    )),
    children: [
      Row(children: [
        const Expanded(child: Text(AppStrings.uploadEvidencePhotos,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.ink))),
        if (report.attachmentPaths.isNotEmpty)
          Text(AppStrings.photosAttached(report.attachmentPaths.length),
            style: const TextStyle(fontSize: 11, color: AppColors.orange,
              fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height: 20),
      InkWell(
        onTap: () => _pending(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(color: const Color(0xFFE2E8F0),
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(12)),
          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ObservationIcon(_icons, 'plus', 20),
            SizedBox(height: 6),
            Text(AppStrings.addMore, style: TextStyle(
              color: AppColors.secondaryInk, fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: _PhotoButton(label: AppStrings.takePhoto,
          icon: 'camera', onPressed: () => _pending(context))),
        const SizedBox(width: 12),
        Expanded(child: _PhotoButton(label: AppStrings.gallery,
          icon: 'gallery', onPressed: () => _pending(context))),
      ]),
    ],
  );

  void _pending(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text(AppStrings.photosPending)));
}

class _PhotoButton extends StatelessWidget {
  const _PhotoButton({required this.label, required this.icon, required this.onPressed});
  final String label;
  final String icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: ObservationIcon(_icons, icon, 18),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.secondaryInk,
      side: const BorderSide(color: AppColors.border, width: 1.5),
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

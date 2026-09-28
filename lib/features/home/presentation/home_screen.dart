import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../observations/presentation/observation_type_screen.dart';
import '../../reports/presentation/reports_history_screen.dart';
import '../../observations/domain/observation_report.dart';
import '../../reports/data/report_transfer.dart';
import '../../reports/presentation/report_details_screen.dart';
import '../../settings/presentation/settings_screen.dart';

const _assets = 'assets/icons/home';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.activeSite});

  final String? activeSite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 36,
              color: AppColors.ink,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _icon('map_pin', 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activeSite == null
                          ? AppStrings.activeSiteNotSet
                          : 'ACTIVE SITE: $activeSite',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(onSettings: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()))),
                    const SizedBox(height: 16),
                    _PrimaryCard(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ObservationTypeScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ActionCard(
                      title: AppStrings.myReports,
                      description: AppStrings.myReportsDescription,
                      icon: 'file_text',
                      chevron: 'chevron_right_reports',
                      onTap: () => _openReports(context),
                    ),
                    const SizedBox(height: 16),
                    _ActionCard(
                      title: AppStrings.importReport,
                      description: AppStrings.importReportDescription,
                      icon: 'download',
                      chevron: 'chevron_right_import',
                      onTap: () => _importReport(context),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      AppStrings.reportStatus,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryInk,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatusCard(
                          icon: 'pencil_line',
                          label: AppStrings.drafts,
                          onTap: () => _openReports(context, ReportStatus.draft),
                        ),
                        const SizedBox(width: 8),
                        _StatusCard(
                          icon: 'clock',
                          label: AppStrings.pending,
                          onTap: () => _openReports(context, ReportStatus.inProgress),
                        ),
                        const SizedBox(width: 8),
                        _StatusCard(
                          icon: 'check_circle',
                          label: AppStrings.completed,
                          onTap: () => _openReports(context, ReportStatus.completed),
                        ),
                        const SizedBox(width: 8),
                        _StatusCard(
                          icon: 'history',
                          label: AppStrings.recent,
                          onTap: () => _openReports(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.orangeTint,
                        border: Border.all(color: const Color(0xFFFED7AA)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _icon('alert_triangle', 18),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              AppStrings.offlineNotice,
                              style: TextStyle(
                                color: Color(0xFF9A3412),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openReports(BuildContext context, [ReportStatus? status]) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ReportsHistoryScreen(initialStatus: status),
      ));

  Future<void> _importReport(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['safety']);
      final path = result?.files.single.path;
      if (path == null) return;
      final report = await ReportTransfer.importReport(File(path));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.reportImported)));
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ReportDetailsScreen(report: report)));
    } on ReportAlreadyExists {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.reportAlreadyExists)));
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.importFailed)));
    }
  }

  static void _pending(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.featurePending)),
    );
  }
}

Widget _icon(String name, double size) => SvgPicture.asset(
      '$_assets/$name.svg',
      width: size,
      height: size,
    );

class _Header extends StatelessWidget {
  const _Header({required this.onSettings});
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 40,
          width: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: _icon('shield', 24),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.shortAppName,
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                AppStrings.subtitle,
                style: TextStyle(
                  color: AppColors.mutedInk,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.darkBadge,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _icon('cloud_off', 14),
              const SizedBox(width: 6),
              const Text(
                AppStrings.offline,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton(onPressed: onSettings, tooltip: AppStrings.settings,
          icon: const Icon(Icons.settings_outlined, color: AppColors.ink)),
      ],
    );
  }
}

class _PrimaryCard extends StatelessWidget {
  const _PrimaryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.orange,
      borderRadius: BorderRadius.circular(16),
      elevation: 7,
      shadowColor: AppColors.orange.withValues(alpha: 0.18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 116,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _icon('plus_circle', 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.newObservation,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        AppStrings.newObservationDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          color: Color(0xFFFFEBE0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _icon('arrow_right', 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.chevron,
    required this.onTap,
  });

  final String title;
  final String description;
  final String icon;
  final String chevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 88,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _icon(icon, 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondaryInk,
                        ),
                      ),
                    ],
                  ),
                ),
                _icon(chevron, 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _icon(icon, 20),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

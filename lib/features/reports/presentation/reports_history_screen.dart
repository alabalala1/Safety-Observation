import 'package:flutter/material.dart';

import '../../../app/app_services.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../observations/domain/observation_report.dart';
import '../../observations/presentation/observation_form_widgets.dart';
import '../../settings/data/report_date_format.dart';
import '../../settings/presentation/active_site_bar.dart';
import 'report_details_screen.dart';

const _icons = 'reports_history';

class ReportsHistoryScreen extends StatefulWidget {
  const ReportsHistoryScreen({super.key, this.initialStatus});
  final ReportStatus? initialStatus;

  @override
  State<ReportsHistoryScreen> createState() => _ReportsHistoryScreenState();
}

class _ReportsHistoryScreenState extends State<ReportsHistoryScreen> {
  String _query = '';
  String _dateFormat = 'DD MMM YYYY';
  ReportStatus? _filter;
  late Future<List<ObservationReport>> _results;
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _filter = widget.initialStatus;
    _reload();
    _loadDateFormat();
  }

  Future<void> _loadDateFormat() async {
    try {
      final value = await AppServices.reports.loadSetting('dateFormat');
      if (mounted) setState(() => _dateFormat = value ?? _dateFormat);
    } catch (_) {
      // The list remains usable with the default date format.
    }
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  void _reload() => _results = AppServices.reports.search(query: _query, status: _filter);

  void _changeQuery(String query) => setState(() {
    _query = query;
    _reload();
  });

  void _changeFilter(ReportStatus? status) => setState(() {
    _filter = status;
    _reload();
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Column(children: [
      const ActiveSiteBar(),
      Expanded(child: ListView(children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(children: [
            InkWell(onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.orange,
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.shield_outlined, color: Colors.white, size: 24))),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.myReports, style: TextStyle(fontSize: 20,
                  fontWeight: FontWeight.w800, color: AppColors.ink)),
                SizedBox(height: 2),
                Text(AppStrings.localLogs, style: TextStyle(fontSize: 10,
                  fontWeight: FontWeight.w700, color: AppColors.mutedInk)),
              ])),
            InkWell(onTap: () => _searchFocus.requestFocus(),
              borderRadius: BorderRadius.circular(10),
              child: Container(width: 38, height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10)),
                child: const ObservationIcon(_icons, 'search', 18))),
          ])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextField(focusNode: _searchFocus, onChanged: _changeQuery,
              style: const TextStyle(fontSize: 14, color: AppColors.ink),
              decoration: InputDecoration(hintText: AppStrings.searchReports,
                hintStyle: const TextStyle(color: AppColors.mutedInk),
                prefixIcon: const Padding(padding: EdgeInsets.all(14),
                  child: ObservationIcon(_icons, 'search', 16)),
                prefixIconConstraints: const BoxConstraints(minWidth: 48),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true, fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.orange)))),
            const SizedBox(height: 16),
            Wrap(spacing: 6, runSpacing: 6, children: [
              _FilterChip(AppStrings.all, _filter == null, () => _changeFilter(null)),
              _FilterChip(AppStrings.statusLabel(ReportStatus.draft),
                _filter == ReportStatus.draft, () => _changeFilter(ReportStatus.draft)),
              _FilterChip(AppStrings.statusLabel(ReportStatus.inProgress),
                _filter == ReportStatus.inProgress,
                () => _changeFilter(ReportStatus.inProgress)),
              _FilterChip(AppStrings.statusLabel(ReportStatus.completed),
                _filter == ReportStatus.completed,
                () => _changeFilter(ReportStatus.completed)),
              _FilterChip(AppStrings.statusLabel(ReportStatus.exported),
                _filter == ReportStatus.exported,
                () => _changeFilter(ReportStatus.exported)),
            ]),
          ])),
        Padding(padding: const EdgeInsets.all(20), child:
          FutureBuilder<List<ObservationReport>>(future: _results,
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text(AppStrings.loadFailed));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final reports = snapshot.data!;
              if (reports.isEmpty) return const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: Text(AppStrings.noReportsOnDevice,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.mutedInk, fontSize: 14))));
              return Column(children: [
                for (final report in reports) ...[
                  _ReportCard(report: report, dateFormat: _dateFormat,
                    onReturn: () => setState(_reload)),
                  const SizedBox(height: 12),
                ],
              ]);
            })),
        const Padding(padding: EdgeInsets.only(top: 8, bottom: 24),
          child: Column(children: [
            Text(AppStrings.buildInfo, style: TextStyle(fontSize: 11,
              fontWeight: FontWeight.w700, color: AppColors.mutedInk)),
            SizedBox(height: 5),
            Text(AppStrings.hardwareInfo,
              style: TextStyle(fontSize: 10, color: AppColors.mutedInk)),
          ])),
      ])),
    ])),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(this.label, this.selected, this.onTap);
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: selected ? AppColors.orange : Colors.white,
        border: Border.all(color: selected ? AppColors.orange : AppColors.border),
        borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
        color: selected ? Colors.white : AppColors.secondaryInk))),
  );
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.dateFormat, required this.onReturn});
  final ObservationReport report;
  final String dateFormat;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final (riskColor, riskTint, accent) = switch (report.risk) {
      RiskRanking.high => (const Color(0xFFEF4444), const Color(0xFFFEE2E2),
        const Color(0xFFEF4444)),
      RiskRanking.medium => (const Color(0xFFD97706), const Color(0xFFFEF3C7),
        AppColors.orange),
      RiskRanking.low => (AppColors.green, const Color(0xFFDCFCE7), AppColors.green),
      null => (AppColors.mutedInk, const Color(0xFFE2E8F0), AppColors.border),
    };
    final (statusColor, statusTint) = switch (report.status) {
      ReportStatus.completed => (AppColors.green, const Color(0xFFDCFCE7)),
      ReportStatus.exported => (AppColors.secondaryInk, const Color(0xFFE2E8F0)),
      ReportStatus.inProgress || ReportStatus.ready || ReportStatus.sentForCompletion =>
        (const Color(0xFFD97706), const Color(0xFFFEF3C7)),
      ReportStatus.received => (AppColors.secondaryInk, const Color(0xFFE2E8F0)),
      ReportStatus.draft => (AppColors.orange, AppColors.orangeTint),
    };
    return Material(color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border)),
      child: InkWell(onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => ReportDetailsScreen(report: report)));
          onReturn();
        }, borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(child: Row(children: [
          Container(width: 4, decoration: BoxDecoration(color: accent,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)))),
          Expanded(child: Padding(padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(report.id, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                    color: AppColors.ink))),
                const SizedBox(width: 6),
                _Badge(AppStrings.statusLabel(report.status), statusColor, statusTint, 11),
              ]),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 4, children: [
                _Badge(AppStrings.typeLabel(report.type), AppColors.secondaryInk,
                  const Color(0xFFF8FAFC), 11, border: true),
                if (report.risk != null) _Badge(report.risk!.name.toUpperCase(),
                  riskColor, riskTint, 10),
              ]),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: AppColors.border)),
              Row(children: [
                const ObservationIcon(_icons, 'map_pin', 14),
                const SizedBox(width: 4),
                Expanded(child: Text(report.area, maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600, color: AppColors.mutedInk))),
                const SizedBox(width: 8),
                const ObservationIcon(_icons, 'calendar', 14),
                const SizedBox(width: 4),
                Text(ReportDateFormat.date(report.createdAt.toLocal(), dateFormat),
                  style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w600, color: AppColors.mutedInk)),
              ]),
            ]))),
        ])),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color, this.tint, this.size, {this.border = false});
  final String label;
  final Color color, tint;
  final double size;
  final bool border;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: tint,
      border: border ? Border.all(color: AppColors.border) : null,
      borderRadius: BorderRadius.circular(6)),
    child: Text(label, style: TextStyle(color: color,
      fontSize: size, fontWeight: FontWeight.w800)),
  );
}

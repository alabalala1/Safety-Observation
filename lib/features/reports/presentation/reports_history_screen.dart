import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../app/app_services.dart';
import '../../observations/domain/observation_report.dart';
import '../../observations/presentation/observation_form_widgets.dart';
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
  ReportStatus? _filter;
  late Future<List<ObservationReport>> _results;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialStatus;
    _reload();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(children: [
            IconButton(onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back)),
            const SizedBox(width: 4),
            const Expanded(child: Text(AppStrings.myReports,
              style: TextStyle(color: AppColors.ink, fontSize: 20,
                fontWeight: FontWeight.w800))),
          ]),
        ),
        Expanded(child: ListView(padding: const EdgeInsets.all(20), children: [
          TextField(
            onChanged: _changeQuery,
            decoration: InputDecoration(
              hintText: AppStrings.searchReports,
              prefixIcon: const Center(widthFactor: 3,
                child: ObservationIcon(_icons, 'search', 18)),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(spacing: 6, runSpacing: 4, children: [
            ChoiceChip(label: const Text(AppStrings.all), selected: _filter == null,
              onSelected: (_) => _changeFilter(null)),
            for (final status in [ReportStatus.draft, ReportStatus.inProgress,
                ReportStatus.completed, ReportStatus.received, ReportStatus.exported])
              ChoiceChip(label: Text(AppStrings.statusLabel(status)),
                selected: _filter == status,
                onSelected: (_) => _changeFilter(status)),
          ]),
          const SizedBox(height: 20),
          FutureBuilder<List<ObservationReport>>(
            future: _results,
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text(AppStrings.loadFailed));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final reports = snapshot.data!;
              if (reports.isEmpty) return const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: Text(AppStrings.noReportsOnDevice,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.mutedInk, fontSize: 14))),
              );
              return Column(children: [
                for (final report in reports) ...[
                  _ReportCard(report: report, onReturn: () => setState(_reload)),
                  const SizedBox(height: 12),
                ],
              ]);
            },
          ),
        ])),
      ])),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.onReturn});
  final ObservationReport report;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.border)),
    child: InkWell(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => ReportDetailsScreen(report: report)));
        onReturn();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(report.id, style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink))),
            Text(AppStrings.statusLabel(report.status),
              style: const TextStyle(fontSize: 11, color: AppColors.orange)),
          ]),
          const SizedBox(height: 10),
          Text('${AppStrings.typeLabel(report.type)}   ${report.risk == null ? '' : AppStrings.riskLabel(report.risk!)}',
            style: const TextStyle(fontSize: 12, color: AppColors.secondaryInk)),
          const Divider(height: 20),
          Row(children: [
            const ObservationIcon(_icons, 'map_pin', 14),
            const SizedBox(width: 4),
            Expanded(child: Text(report.area, style: const TextStyle(fontSize: 12))),
            const ObservationIcon(_icons, 'calendar', 14),
            const SizedBox(width: 4),
            Text(MaterialLocalizations.of(context).formatMediumDate(report.createdAt.toLocal()),
              style: const TextStyle(fontSize: 12)),
          ]),
        ],
      )),
    ),
  );
}

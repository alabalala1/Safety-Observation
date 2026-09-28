import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/observation_report.dart';
import 'observation_form_widgets.dart';
import 'supervisor_notification_screen.dart';

const _icons = 'risk_ranking';

class RiskRankingScreen extends StatefulWidget {
  const RiskRankingScreen({super.key, required this.report});
  final ObservationReport report;

  @override
  State<RiskRankingScreen> createState() => _RiskRankingScreenState();
}

class _RiskRankingScreenState extends State<RiskRankingScreen> {
  RiskRanking? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.report.risk;
  }

  void _continue() {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.riskRequired)));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => SupervisorNotificationScreen(report: widget.report.withDetails(risk: _selected)),
    ));
  }

  @override
  Widget build(BuildContext context) => ObservationStepScaffold(
    title: AppStrings.riskRanking,
    step: 9,
    iconDirectory: _icons,
    onContinue: _continue,
    children: [
      const Text(AppStrings.riskNotice, style: TextStyle(
        color: AppColors.secondaryInk, fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 20),
      for (final risk in RiskRanking.values) ...[
        _RiskCard(risk: risk, selected: _selected == risk,
          onTap: () => setState(() => _selected = risk)),
        const SizedBox(height: 12),
      ],
    ],
  );
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({required this.risk, required this.selected, required this.onTap});
  final RiskRanking risk;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (risk) {
      RiskRanking.high => const Color(0xFFEF4444),
      RiskRanking.medium => AppColors.orange,
      RiskRanking.low => const Color(0xFF16A34A),
    };
    final label = switch (risk) {
      RiskRanking.high => AppStrings.highRisk,
      RiskRanking.medium => AppStrings.mediumRisk,
      RiskRanking.low => AppStrings.lowRisk,
    };
    final description = switch (risk) {
      RiskRanking.high => AppStrings.highRiskDescription,
      RiskRanking.medium => AppStrings.mediumRiskDescription,
      RiskRanking.low => AppStrings.lowRiskDescription,
    };
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? AppColors.orange : AppColors.border,
          width: selected ? 1.5 : 1)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 6))),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(color: AppColors.secondaryInk, fontSize: 12)),
            ])),
            Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? AppColors.orange : AppColors.border),
          ]),
        ),
      ),
    );
  }
}

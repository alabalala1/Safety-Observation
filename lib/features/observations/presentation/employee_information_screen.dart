import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../app/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/observation_report.dart';
import '../data/draft_autosave.dart';
import 'observation_form_widgets.dart';
import 'observed_event_screen.dart';

const _icons = 'employee_information';

class EmployeeInformationScreen extends StatefulWidget {
  const EmployeeInformationScreen({super.key, required this.report});
  final ObservationReport report;

  @override
  State<EmployeeInformationScreen> createState() => _EmployeeInformationScreenState();
}

class _EmployeeInformationScreenState extends State<EmployeeInformationScreen> {
  late final TextEditingController _name = TextEditingController(text: widget.report.employeeName);
  late final TextEditingController _number = TextEditingController(text: widget.report.employeeNumber);
  late final TextEditingController _department = TextEditingController(text: widget.report.employeeDepartment);
  late final DraftAutosave _autosave = DraftAutosave(widget.report.id, (_) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.saveFailed)));
  });

  @override
  void initState() {
    super.initState();
    _name.addListener(_schedule);
    _number.addListener(_schedule);
    _department.addListener(_schedule);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await AppServices.reports.loadProfile();
      if (!mounted) return;
      if (_name.text.isEmpty) _name.text = profile['name'] ?? '';
      if (_number.text.isEmpty) _number.text = profile['employeeNumber'] ?? '';
      if (_department.text.isEmpty) _department.text = profile['department'] ?? '';
    } catch (_) {
      // Manual entry remains available if profile lookup fails.
    }
  }

  void _schedule() {
    final name = _name.text.trim();
    final number = _number.text.trim();
    final department = _department.text.trim();
    _autosave.schedule((report) => report.withDetails(
      employeeName: name, employeeNumber: number,
      employeeDepartment: department));
  }

  @override
  void dispose() {
    _autosave.close();
    _name.dispose();
    _number.dispose();
    _department.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.employeeNameRequired)));
      return;
    }
    try {
      final report = await _autosave.flush();
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ObservedEventScreen(report: report),
      ));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.saveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(widget.report.createdAt.toLocal());
    return ObservationStepScaffold(
      title: AppStrings.employeeInfo,
      step: 3,
      iconDirectory: _icons,
      onContinue: _continue,
      children: [
        const ObservationNotice(text: AppStrings.employeeInfoNotice,
          iconDirectory: _icons, icon: 'user_info'),
        const SizedBox(height: 20),
        _EmployeeInput(label: AppStrings.employeeName, icon: 'user',
          controller: _name, hint: AppStrings.enterEmployeeName),
        const SizedBox(height: 16),
        _EmployeeInput(label: AppStrings.employeeNumber, icon: 'id_card',
          controller: _number, hint: AppStrings.enterEmployeeNumber),
        const SizedBox(height: 16),
        _EmployeeInput(label: AppStrings.department, icon: 'briefcase',
          controller: _department, hint: AppStrings.enterDepartment),
        const SizedBox(height: 16),
        const ObservationFieldLabel(AppStrings.dateRecorded, tag: AppStrings.auto),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white,
            border: Border.all(color: AppColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            const ObservationIcon(_icons, 'calendar', 16),
            const SizedBox(width: 10),
            Text(date, style: const TextStyle(color: AppColors.ink,
              fontSize: 15, fontWeight: FontWeight.w600)),
          ]),
        ),
      ],
    );
  }
}

class _EmployeeInput extends StatelessWidget {
  const _EmployeeInput({required this.label, required this.icon,
    required this.controller, required this.hint});
  final String label;
  final String icon;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ObservationFieldLabel(label),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Center(widthFactor: 3,
            child: ObservationIcon(_icons, icon, 16)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ],
  );
}

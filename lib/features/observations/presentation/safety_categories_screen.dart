import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/observation_report.dart';
import '../data/draft_autosave.dart';
import 'observation_form_widgets.dart';
import 'safe_unsafe_actions_screen.dart';

const _icons = 'safety_categories';

class SafetyCategoriesScreen extends StatefulWidget {
  const SafetyCategoriesScreen({super.key, required this.report});
  final ObservationReport report;

  @override
  State<SafetyCategoriesScreen> createState() => _SafetyCategoriesScreenState();
}

class _SafetyCategoriesScreenState extends State<SafetyCategoriesScreen> {
  late final Set<String> _selected = widget.report.safetyCategories.toSet();
  late final DraftAutosave _autosave = DraftAutosave(widget.report.id, (_) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.saveFailed)));
  });
  bool get _allCorrect => _selected.contains(AppStrings.allCorrect);

  @override
  void dispose() {
    _autosave.close();
    super.dispose();
  }

  void _toggle(String category) => setState(() {
    if (category == AppStrings.allCorrect) {
      if (_allCorrect) {
        _selected.clear();
      } else {
        _selected..clear()..add(AppStrings.allCorrect);
      }
    } else {
      _selected.remove(AppStrings.allCorrect);
      if (!_selected.add(category)) _selected.remove(category);
    }
    final categories = _selected.toList();
    _autosave.schedule((report) => report.withDetails(safetyCategories: categories));
  });

  Future<void> _continue() async {
    try {
      final report = await _autosave.flush();
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => SafeUnsafeActionsScreen(report: report)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.saveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) => ObservationStepScaffold(
    title: AppStrings.safetyCategories,
    step: 7,
    iconDirectory: _icons,
    onContinue: _continue,
    children: [
      Material(
        color: _allCorrect ? const Color(0xFFDCFCE7) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _allCorrect ? const Color(0xFFBBF7D0) : AppColors.border, width: 1.5)),
        child: CheckboxListTile(
          value: _allCorrect,
          onChanged: (_) => _toggle(AppStrings.allCorrect),
          activeColor: const Color(0xFF16A34A),
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(AppStrings.allCorrect, style: TextStyle(
            fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.ink)),
          subtitle: const Text(AppStrings.allCorrectHint, style: TextStyle(fontSize: 12)),
        ),
      ),
      const SizedBox(height: 16),
      for (final section in AppStrings.safetyCategorySections.entries) ...[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(color: Color(0xFFE2E8F0),
            border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Text(section.key.toUpperCase(), style: const TextStyle(
            color: AppColors.secondaryInk, fontSize: 11, fontWeight: FontWeight.w800)),
        ),
        for (final item in section.value)
          Container(
            decoration: const BoxDecoration(color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border))),
            child: CheckboxListTile(
              dense: true,
              value: _selected.contains(item),
              onChanged: (_) => _toggle(item),
              activeColor: AppColors.orange,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(item, style: const TextStyle(fontSize: 14,
                color: AppColors.secondaryInk, fontWeight: FontWeight.w500)),
            ),
          ),
      ],
    ],
  );
}

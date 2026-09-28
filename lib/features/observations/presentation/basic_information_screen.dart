import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/observation_report.dart';
import '../data/draft_autosave.dart';
import 'employee_information_screen.dart';

const _assets = 'assets/icons/basic_information';

class BasicInformationScreen extends StatefulWidget {
  const BasicInformationScreen({super.key, required this.report});

  final ObservationReport report;

  @override
  State<BasicInformationScreen> createState() => _BasicInformationScreenState();
}

class _BasicInformationScreenState extends State<BasicInformationScreen> {
  String? _area;
  late final DraftAutosave _autosave = DraftAutosave(widget.report.id, (_) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.saveFailed)));
  });

  @override
  void initState() {
    super.initState();
    _area = widget.report.area.isEmpty ? null : widget.report.area;
  }

  @override
  void dispose() {
    _autosave.close();
    super.dispose();
  }

  Future<void> _chooseArea() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => _AreaEntryDialog(initialArea: _area ?? ''),
    );
    if (!mounted || selected == null) return;
    setState(() => _area = selected.isEmpty ? null : selected);
    final area = _area ?? '';
    _autosave.schedule((report) => report.withDetails(area: area));
  }

  Future<void> _continue() async {
    if (_area == null || _area!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.areaRequired)),
      );
      return;
    }
    try {
      final report = await _autosave.flush();
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => EmployeeInformationScreen(report: report),
      ));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.saveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final recorded = widget.report.createdAt.toLocal();
    final date = localizations.formatMediumDate(recorded);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(recorded),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(
                    height: 64,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Material(
                            color: const Color(0xFFF8FAFC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 36,
                                height: 36,
                                child: Center(child: _icon('arrow_left', 18)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              AppStrings.basicInfo,
                              style: TextStyle(
                                color: AppColors.ink,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ink,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              AppStrings.stepTwoOfTen,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const LinearProgressIndicator(
                    value: 0.2,
                    minHeight: 4,
                    backgroundColor: Color(0xFFE2E8F0),
                    color: AppColors.orange,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        border: Border.all(color: const Color(0xFFFED7AA)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _icon('info', 16),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              AppStrings.autoRecordedNotice,
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
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const _FieldLabel(AppStrings.reportId),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            AppStrings.autoGenerated,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondaryInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _ReadOnlyField(
                      value: widget.report.id,
                      icon: 'lock',
                      filled: true,
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel(AppStrings.dateRecorded),
                    const SizedBox(height: 6),
                    _ReadOnlyField(value: date, icon: 'calendar'),
                    const SizedBox(height: 16),
                    const _FieldLabel(AppStrings.time),
                    const SizedBox(height: 6),
                    _ReadOnlyField(value: time, icon: 'clock'),
                    const SizedBox(height: 16),
                    const Text(
                      AppStrings.requiredAreaLabel,
                      style: TextStyle(
                        color: AppColors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: AppColors.orange,
                          width: 2,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: _chooseArea,
                        child: SizedBox(
                          height: 48,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _area ?? AppStrings.selectArea,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.secondaryInk,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                _icon('chevron_down', 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: ElevatedButton(
                onPressed: _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(49),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      AppStrings.continueLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _icon('arrow_right', 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Owns its text controller for the entire lifetime of the dialog route,
/// including its closing animation.
class _AreaEntryDialog extends StatefulWidget {
  const _AreaEntryDialog({required this.initialArea});

  final String initialArea;

  @override
  State<_AreaEntryDialog> createState() => _AreaEntryDialogState();
}

class _AreaEntryDialogState extends State<_AreaEntryDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialArea);

  void _save() => Navigator.of(context).pop(_controller.text.trim());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text(AppStrings.enterArea),
        content: TextField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: AppStrings.area,
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _save(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(onPressed: _save, child: const Text(AppStrings.save)),
        ],
      );
}

Widget _icon(String name, double size) => SvgPicture.asset(
      '$_assets/$name.svg',
      width: size,
      height: size,
    );

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.mutedInk,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.value,
    required this.icon,
    this.filled = false,
  });

  final String value;
  final String icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFFE2E8F0) : Colors.white,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: filled ? AppColors.secondaryInk : AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _icon(icon, 16),
        ],
      ),
    );
  }
}

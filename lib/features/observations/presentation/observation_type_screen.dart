import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../app/app_services.dart';
import '../domain/observation_report.dart';
import 'basic_information_screen.dart';

const _assets = 'assets/icons/observation_type';

class ObservationTypeScreen extends StatefulWidget {
  const ObservationTypeScreen({super.key});

  @override
  State<ObservationTypeScreen> createState() => _ObservationTypeScreenState();
}

class _ObservationTypeScreenState extends State<ObservationTypeScreen> {
  ObservationType? _selectedType;
  StopCardCategory? _stopCardCategory;

  bool get _canContinue =>
      _selectedType != null &&
      (_selectedType != ObservationType.stopCard || _stopCardCategory != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
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
                      AppStrings.newObservation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      AppStrings.stepOneOfTen,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      AppStrings.selectObservationType,
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final option in _options) ...[
                      _ObservationCard(
                        option: option,
                        selected: _selectedType == option.type,
                        category: _stopCardCategory,
                        onSelected: () => setState(() {
                          _selectedType = option.type;
                          if (option.type != ObservationType.stopCard) {
                            _stopCardCategory = null;
                          }
                        }),
                        onCategorySelected: (category) => setState(() {
                          _selectedType = ObservationType.stopCard;
                          _stopCardCategory = category;
                        }),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canContinue
                    ? () async {
                        final report = ObservationReport.newDraft(
                          type: _selectedType!,
                          stopCardCategory: _stopCardCategory,
                        );
                        try {
                          await AppServices.reports.save(report);
                        } catch (_) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text(AppStrings.saveFailed)));
                          return;
                        }
                        if (!context.mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BasicInformationScreen(report: report),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.border,
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
                      AppStrings.continueToForm,
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

Widget _icon(String name, double size) => SvgPicture.asset(
      '$_assets/$name.svg',
      width: size,
      height: size,
    );

class _TypeOption {
  const _TypeOption(this.type, this.title, this.description, this.icon);

  final ObservationType type;
  final String title;
  final String description;
  final String icon;
}

const _options = [
  _TypeOption(
    ObservationType.nearMiss,
    AppStrings.nearMiss,
    AppStrings.nearMissDescription,
    'alert_triangle',
  ),
  _TypeOption(
    ObservationType.tofs,
    AppStrings.tofs,
    AppStrings.tofsDescription,
    'eye',
  ),
  _TypeOption(
    ObservationType.hazardId,
    AppStrings.hazardId,
    AppStrings.hazardIdDescription,
    'shield_alert',
  ),
  _TypeOption(
    ObservationType.stopCard,
    AppStrings.stopCard,
    AppStrings.stopCardDescription,
    'hand',
  ),
];

class _ObservationCard extends StatelessWidget {
  const _ObservationCard({
    required this.option,
    required this.selected,
    required this.category,
    required this.onSelected,
    required this.onCategorySelected,
  });

  final _TypeOption option;
  final bool selected;
  final StopCardCategory? category;
  final VoidCallback onSelected;
  final ValueChanged<StopCardCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final isStopCard = option.type == ObservationType.stopCard;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.orange : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onSelected,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFFFF7ED)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _icon(option.icon, 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option.description,
                          style: const TextStyle(
                            color: AppColors.mutedInk,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  selected
                      ? _icon('radio_selected', 20)
                      : Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border,
                              width: 2,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
          if (selected && isStopCard)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  const Text(
                    AppStrings.stopCardCategory,
                    style: TextStyle(
                      color: AppColors.mutedInk,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _CategoryChip(
                        title: AppStrings.positive,
                        selected: category == StopCardCategory.positive,
                        onTap: () => onCategorySelected(
                          StopCardCategory.positive,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        title: AppStrings.unsafeCorrective,
                        selected: category == StopCardCategory.unsafeCorrective,
                        onTap: () => onCategorySelected(
                          StopCardCategory.unsafeCorrective,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? const Color(0xFFFFF7ED) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: selected ? AppColors.orange : AppColors.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 33,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    color: selected ? AppColors.orange : AppColors.mutedInk,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

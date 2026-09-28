import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';

class ObservationStepScaffold extends StatelessWidget {
  const ObservationStepScaffold({
    super.key,
    required this.title,
    required this.step,
    required this.iconDirectory,
    required this.children,
    required this.onContinue,
    this.showStepBadge = true,
    this.progress,
    this.buttonLabel = AppStrings.continueLabel,
  });

  final String title;
  final int step;
  final String iconDirectory;
  final List<Widget> children;
  final VoidCallback onContinue;
  final bool showStepBadge;
  final double? progress;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    final compositeBack = const {
      'observed_event', 'action_taken', 'safe_unsafe_actions',
      'risk_ranking', 'supervisor_notification', 'attachments', 'review_and_save',
    }.contains(iconDirectory);
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
                            if (compositeBack)
                              InkWell(
                                onTap: () => Navigator.of(context).pop(),
                                child: ObservationIcon(iconDirectory, 'arrow_left', 36),
                              )
                            else Material(
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
                                  child: Center(child: ObservationIcon(iconDirectory, 'arrow_left', 18)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  )),
                            ),
                            if (showStepBadge) Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.ink,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(AppStrings.stepOfTen(step),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    LinearProgressIndicator(
                      value: progress ?? step / 10,
                      minHeight: 4,
                      backgroundColor: const Color(0xFFE2E8F0),
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
                    children: children,
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
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(49),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(buttonLabel,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      ObservationIcon(iconDirectory, 'arrow_right', 20),
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

class ObservationIcon extends StatelessWidget {
  const ObservationIcon(this.directory, this.name, this.size, {super.key});
  final String directory;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/icons/$directory/$name.svg',
        width: size,
        height: size,
      );
}

class ObservationNotice extends StatelessWidget {
  const ObservationNotice({super.key, required this.text, required this.iconDirectory, required this.icon});
  final String text;
  final String iconDirectory;
  final String icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          border: Border.all(color: const Color(0xFFFED7AA)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            ObservationIcon(iconDirectory, icon, 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                    color: Color(0xFF9A3412),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  )),
            ),
          ],
        ),
      );
}

class ObservationFieldLabel extends StatelessWidget {
  const ObservationFieldLabel(this.text, {super.key, this.tag});
  final String text;
  final String? tag;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: const TextStyle(
            color: AppColors.mutedInk, fontSize: 11, fontWeight: FontWeight.w700,
          ))),
          if (tag != null) Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
            child: Text(tag!.toUpperCase(), style: const TextStyle(
              color: AppColors.secondaryInk, fontSize: 10, fontWeight: FontWeight.w700,
            )),
          ),
        ],
      );
}

class ObservationTextArea extends StatelessWidget {
  const ObservationTextArea({super.key, required this.label, required this.hint,
    required this.controller, this.height = 180});
  final String label;
  final String hint;
  final TextEditingController controller;
  final double height;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ObservationFieldLabel(label),
          const SizedBox(height: 8),
          SizedBox(
            height: height,
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              maxLength: 500,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) => Text('${value.text.characters.length} / 500',
                style: const TextStyle(color: AppColors.mutedInk, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );
}

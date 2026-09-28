import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';

class SignaturePadDialog extends StatefulWidget {
  const SignaturePadDialog({super.key});

  @override
  State<SignaturePadDialog> createState() => _SignaturePadDialogState();
}

class _SignaturePadDialogState extends State<SignaturePadDialog> {
  final List<Offset?> _points = [];
  static const _width = 300.0;
  static const _height = 160.0;

  Future<void> _save() async {
    if (_points.length < 2) return;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(2);
    canvas.drawRect(const Rect.fromLTWH(0, 0, _width, _height),
      Paint()..color = Colors.white);
    _SignaturePainter.paintLines(canvas, _points);
    final image = await recorder.endRecording().toImage(600, 320);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (mounted && data != null) Navigator.of(context).pop(data.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(AppStrings.supervisorSignature),
    content: SizedBox(
      width: _width,
      height: _height,
      child: GestureDetector(
        onPanStart: (details) => setState(() => _points.add(details.localPosition)),
        onPanUpdate: (details) => setState(() => _points.add(details.localPosition)),
        onPanEnd: (_) => setState(() => _points.add(null)),
        child: Container(
          decoration: BoxDecoration(color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10)),
          child: CustomPaint(painter: _SignaturePainter(_points),
            size: const Size(_width, _height)),
        ),
      ),
    ),
    actions: [
      TextButton(onPressed: () => setState(_points.clear),
        child: const Text(AppStrings.clear)),
      TextButton(onPressed: () => Navigator.of(context).pop(),
        child: const Text(AppStrings.cancel)),
      FilledButton(onPressed: _points.isEmpty ? null : _save,
        child: const Text(AppStrings.save)),
    ],
  );
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter(this.points);
  final List<Offset?> points;

  static void paintLines(Canvas canvas, List<Offset?> points) {
    final ink = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      if (previous != null && current != null) canvas.drawLine(previous, current, ink);
    }
  }

  @override
  void paint(Canvas canvas, Size size) => paintLines(canvas, points);

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}

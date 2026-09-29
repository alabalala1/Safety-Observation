import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:safety_observation/features/observations/domain/observation_report.dart';
import 'package:safety_observation/features/reports/data/report_pdf.dart';

Future<List<int>> _sampleImage() async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 600, 280),
    ui.Paint()..color = const ui.Color(0xFFDDE8EF));
  canvas.drawRect(const ui.Rect.fromLTWH(0, 190, 600, 110),
    ui.Paint()..color = const ui.Color(0xFF80919B));
  canvas.drawRect(const ui.Rect.fromLTWH(80, 50, 440, 130),
    ui.Paint()..color = const ui.Color(0xFF667783));
  canvas.drawRect(const ui.Rect.fromLTWH(115, 78, 360, 62),
    ui.Paint()..color = const ui.Color(0xFFB4C8D2));
  final image = await recorder.endRecording().toImage(600, 300);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Figma-styled PDF builds with real fields and media', (tester) async {
    final photo = File('${Directory.systemTemp.path}/report_pdf_sample.png');
    await photo.writeAsBytes(await _sampleImage());
    final report = ObservationReport.newDraft(type: ObservationType.nearMiss)
      .withDetails(
        status: ReportStatus.completed,
        area: 'Workshop - SEC-04 Refinery Wing',
        employeeName: 'Ahmed Al-Rashidi',
        employeeNumber: 'EMP-04821',
        employeeDepartment: 'Operations - Plant 3',
        observedEvent: 'During a routine pump operation check, a technician '
            'noticed pressurized steam venting from a relief valve. '
            'تم إيقاف العمل مؤقتًا لحماية العاملين.',
        potentialHazard: 'Steam burns and slippery condensation near a walkway.',
        actionTaken: 'The walkway was closed and control notified.',
        furtherActions: 'Replace the pressure seal gasket.',
        safetyCategories: [
          'Head Protection', 'Face & Eye Protection',
          'Stopping Work or Task', 'Moving / Changing Position',
          'Tools / Equipment Unsafe Condition',
        ],
        encouragement: 'Thanked the operator for identifying the risk.',
        immediateCorrectiveAction: 'Advised maintenance to check lock tags.',
        risk: RiskRanking.high,
        supervisorNotified: true,
        supervisorName: 'John Mitchell',
        supervisorFurtherAction: 'Maintenance ticket issued.',
        signaturePath: photo.path,
        attachmentPaths: [photo.path, photo.path, photo.path, photo.path],
      );
    final bytes = await ReportPdf.build(report);
    expect(bytes.length, greaterThan(1000));
    expect(bytes.take(4).toList(), [37, 80, 68, 70]);
    await Directory('build').create(recursive: true);
    await File('build/report-preview.pdf').writeAsBytes(bytes);
    await photo.delete();
  });
}

import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:safety_observation/features/observations/domain/observation_report.dart';
import 'package:safety_observation/features/reports/data/report_pdf.dart';

const _samplePng = 'iVBORw0KGgoAAAANSUhEUgAAAMgAAABkCAIAAABM5OhcAAABbUlEQVR4nO3bsU1DQRBAQYwoArkokPsgISEmdmIhkVGEBfUQW85ogRqQ9vkkM1PA3gVP95P9m+/zzw1Mu119Aa6TsEgIi4SwSAiLhLBICIuEsEgIi4SwSAiLhLBICIuEsEjcDc7aH94Hp7HEy/PTyBwvFglhkRAWCWGREBYJYZEQFglhkRAWCWGREBYJYZEQFglhkZhcm/mTh93jqqP/m6/j5+UP9WKREBYJYZEQFglhkRAWCWGREBYJYZEQFglhkRAWCWGREBYJYZEQFglhkRAWCWGREBaJZT9TLNnw52K8WCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgkhEVCWCQ2r28fU7NOp/PUKFbZbu9H5kyuzUzdiSvgU0hCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgkhEVCWCSERUJYJIRFQlgkhEVCWCSEReIXKFsQjNGDW7gAAAAASUVORK5CYII=';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Figma-styled PDF builds with real fields and media', () async {
    final photo = File('${Directory.systemTemp.path}/report_pdf_sample.png');
    await photo.writeAsBytes(base64Decode(_samplePng));
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

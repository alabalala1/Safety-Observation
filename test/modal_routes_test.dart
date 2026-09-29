import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safety_observation/features/observations/domain/observation_report.dart';
import 'package:safety_observation/features/observations/presentation/observation_form_widgets.dart';
import 'package:safety_observation/features/observations/presentation/signature_pad_dialog.dart';
import 'package:safety_observation/features/reports/presentation/report_details_screen.dart';

void main() {
  testWidgets('signature dialog opens and closes cleanly', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => showDialog<void>(context: context,
          builder: (_) => const SignaturePadDialog()),
        child: const Text('Open signature'),
      ),
    ))));
    await tester.tap(find.text('Open signature'));
    await tester.pumpAndSettle();
    expect(find.byType(SignaturePadDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(SignaturePadDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('photo source sheet opens and closes cleanly', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: EvidencePhotos(
      reportId: 'OBS-TEST', iconDirectory: 'attachments', initialPaths: [],
    ))));
    await tester.tap(find.text('Add Photo'));
    await tester.pumpAndSettle();
    expect(find.text('Take Photo'), findsOneWidget);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.text('Take Photo'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('delete confirmation can be canceled safely', (tester) async {
    final report = ObservationReport.newDraft(type: ObservationType.nearMiss);
    await tester.pumpWidget(MaterialApp(home: ReportDetailsScreen(report: report)));
    await tester.ensureVisible(find.text('Delete Report').first);
    await tester.tap(find.text('Delete Report').first);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

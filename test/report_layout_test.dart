import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safety_observation/features/observations/domain/observation_report.dart';
import 'package:safety_observation/features/reports/presentation/report_details_screen.dart';
import 'package:safety_observation/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('report actions fit a phone width and remain visible', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final report = ObservationReport.newDraft(type: ObservationType.nearMiss);
    await tester.pumpWidget(MaterialApp(home: ReportDetailsScreen(report: report)));
    await tester.pump();
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Export PDF'), findsOneWidget);
    expect(find.text('Export .safety file'), findsOneWidget);
    expect(find.text('Duplicate'), findsOneWidget);
    expect(find.text('Delete Report'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings sections remain reachable on a phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.pump();
    expect(find.text('Active Site'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Support & Help'), 400);
    expect(find.text('Export All Reports'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings editor can save and close without a disposed controller',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.tap(find.text('Name').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Updated Name');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Active Site').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Workshop Wing-B');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

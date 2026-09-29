import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safety_observation/features/observations/presentation/basic_information_screen.dart';

void main() {
  testWidgets('area can be entered, saved, reopened, and canceled', (tester) async {
    String? saved;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: AreaSelector(
      initialArea: '', onSaved: (value) => saved = value,
    ))));

    await tester.tap(find.text('Select Area'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.enterText(find.byType(TextField), '  Workshop A  ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved, 'Workshop A');
    expect(find.text('Workshop A'), findsOneWidget);

    await tester.tap(find.text('Workshop A'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Workshop B');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(saved, 'Workshop A');
    expect(find.text('Workshop A'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safety_observation/features/observations/presentation/basic_information_screen.dart';

void main() {
  testWidgets('area can only be selected from the configured list',
      (tester) async {
    String? saved;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: AreaSelector(
      initialArea: '',
      onSaved: (value) => saved = value,
    ))));

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(find.byType(DropdownMenuItem<String>), findsNWidgets(3));
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text('Warehouse').last);
    await tester.pumpAndSettle();
    expect(saved, 'Warehouse');
    expect(find.text('Warehouse'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

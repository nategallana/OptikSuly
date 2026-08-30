import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optik_suly/main.dart';

void main() {
  testWidgets('starts the assessment from the home screen', (tester) async {
    await tester.pumpWidget(const OptikSulyApp());

    expect(find.text('OptikSulyApp'), findsOneWidget);
    expect(find.text('Assessment Modules'), findsOneWidget);

    await tester.tap(find.byKey(const Key('start-assessment')));
    await tester.pumpAndSettle();

    expect(find.text('Patient Profile'), findsOneWidget);
    expect(find.text('Patient Demographics'), findsOneWidget);
  });
}

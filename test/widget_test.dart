import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ir_academy_app/main.dart';

void main() {
  testWidgets('Role select screen shows both role options', (WidgetTester tester) async {
    await tester.pumpWidget(const IrAcademyApp());

    expect(find.text('Continue as Student'), findsOneWidget);
    expect(find.text('Continue as Teacher'), findsOneWidget);
  });

  testWidgets('Student shell opens to Home tab', (WidgetTester tester) async {
    await tester.pumpWidget(const IrAcademyApp());

    await tester.tap(find.text('Continue as Student'));
    await tester.pumpAndSettle();

    expect(find.text('IR Academy'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}

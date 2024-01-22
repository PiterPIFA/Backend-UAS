// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testes/screen/login_screen.dart';

void main() {
  testWidgets('LoginPage UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: LoginPage(),
    ));
    expect(find.text('Me Apps'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Top Headlines'), findsOneWidget);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bimo_fe/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Allow SplashPage animations and navigation to complete
    // SplashPage waits 500ms for logo, then 2s for navigation.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify that the app builds without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

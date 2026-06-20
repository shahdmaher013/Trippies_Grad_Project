import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trippies/screens/home_screen.dart';

void main() {
  testWidgets('Home screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Verify that the header text appears.
    expect(find.text('Welcome back,'), findsOneWidget);
  });
}

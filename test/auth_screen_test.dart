import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trippies/screens/auth_screen.dart';

void main() {
  testWidgets('Auth screen renders', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Sign Up'), findsWidgets);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Full Name'), findsWidgets);
  });
}

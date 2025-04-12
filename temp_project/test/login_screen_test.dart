import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vini_drive_ops/screens/auth/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('renders login form elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Don\'t have an account? Register'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty form submission', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      
      // Find and tap the login button
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pump();
      
      // Verify error messages are shown for empty fields
      expect(find.text('Please enter your phone number'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('validates phone number format', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      
      // Enter invalid phone number
      await tester.enterText(find.widgetWithText(TextFormField, 'Phone'), '123');
      
      // Tap login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Verify phone format error is shown
      expect(find.text('Please enter a valid phone number'), findsOneWidget);
    });

    testWidgets('clears validation errors when form is filled correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      await tester.enterText(find.byType(TextFormField).first, '1234567890');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your phone number'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
    });
  });
}
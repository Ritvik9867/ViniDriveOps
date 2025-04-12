import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinidriveops/screens/auth/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('validates empty form fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      
      // Find the login button and tap it
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

    testWidgets('shows loading indicator during login', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      
      // Fill in valid form data
      await tester.enterText(find.widgetWithText(TextFormField, 'Phone'), '1234567890');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      
      // Tap login button and verify loading indicator
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message on login failure', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      
      // Fill in form data
      await tester.enterText(find.widgetWithText(TextFormField, 'Phone'), '1234567890');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'wrongpassword');
      
      // Tap login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Verify error message is displayed
      expect(find.text('Failed to login. Please try again.'), findsOneWidget);
    });
  });
}
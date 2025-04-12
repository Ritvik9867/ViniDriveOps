import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinidriveops/screens/registration_screen.dart';

void main() {
  group('RegistrationScreen Widget Tests', () {
    testWidgets('validates empty form fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));
      
      // Find the register button and tap it
      final registerButton = find.byType(ElevatedButton);
      await tester.tap(registerButton);
      await tester.pump();
      
      // Verify error messages are shown for empty fields
      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your phone number'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('validates email format', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));
      
      // Enter invalid email
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
      
      // Tap register button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Verify email format error is shown
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('validates password match', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));
      
      // Enter different passwords
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password456');
      
      // Tap register button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Verify password match error is shown
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('validates phone number length', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));
      
      // Enter short phone number
      await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '123456');
      
      // Tap register button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Verify phone number length error is shown
      expect(find.text('Please enter a valid phone number'), findsOneWidget);
    });

    testWidgets('shows loading indicator during registration', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));
      
      // Fill in valid form data
      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '1234567890');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');
      
      // Tap register button and verify loading indicator
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
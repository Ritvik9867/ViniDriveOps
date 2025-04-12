import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vini_drive_ops/screens/registration_screen.dart';

void main() {
  group('RegistrationScreen Widget Tests', () {
    testWidgets('renders registration form elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));

      expect(find.text('Driver Registration'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(5)); // name, email, phone, password, confirm password
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty form submission', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your phone number'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('validates email format', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));
      
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(find.text('Please enter a valid email address'), findsOneWidget);
      
      // Enter valid email
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(find.text('Please enter a valid email address'), findsNothing);
    });

    testWidgets('validates phone number format', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));
      
      await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(find.text('Please enter a valid phone number'), findsOneWidget);
      
      // Enter valid phone number
      await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '1234567890');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(find.text('Please enter a valid phone number'), findsNothing);
    });

    testWidgets('validates password length', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));
      
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('clears validation errors when form is filled correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));

      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'John Doe');
      await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '1234567890');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'john@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your name'), findsNothing);
      expect(find.text('Please enter your phone number'), findsNothing);
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
    });
  });
}
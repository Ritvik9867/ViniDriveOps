import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinidriveops/screens/auth/login_screen.dart';
import 'mocks/auth_service_mock.dart';
import 'package:mockito/mockito.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('renders login form elements correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(authService: mockAuthService),
        ),
      );

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Don\'t have an account? Register'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty form submission',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(authService: mockAuthService),
        ),
      );

      // Find and tap the login button
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pump();

      // Verify error messages are shown for empty fields
      expect(find.text('Please enter your phone number'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('validates phone number format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(authService: mockAuthService),
        ),
      );

      // Enter invalid phone number
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Phone'), '123');

      // Tap login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify phone format error is shown
      expect(find.text('Please enter a valid phone number'), findsOneWidget);
    });

    testWidgets('clears validation errors when form is filled correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(authService: mockAuthService),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, '1234567890');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your phone number'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
    });

    testWidgets('Login screen shows all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(authService: mockAuthService),
        ),
      );

      // Verify all form fields are present
      expect(find.text('Driver Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and Password
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Shows error messages for empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(authService: mockAuthService),
        ),
      );

      // Try to submit without filling any fields
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify error messages
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Shows error for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(authService: mockAuthService),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('Successful login shows success message', (WidgetTester tester) async {
      when(mockAuthService.login(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => {'success': true});

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(authService: mockAuthService),
        ),
      );

      // Fill in all fields correctly
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');

      // Submit form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Login successful!'), findsOneWidget);
    });
  });
}

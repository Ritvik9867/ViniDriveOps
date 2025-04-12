import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinidriveops/screens/auth/registration_screen.dart';
import 'package:vinidriveops/services/auth_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  testWidgets('Registration screen shows all required fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegistrationScreen(authService: mockAuthService),
      ),
    );

    // Verify all form fields are present
    expect(find.text('Driver Registration'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(5)); // Name, Email, Phone, Password, Confirm Password
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Shows error messages for empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegistrationScreen(authService: mockAuthService),
      ),
    );

    // Try to submit without filling any fields
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify error messages
    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your phone number'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('Shows error for invalid email', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegistrationScreen(authService: mockAuthService),
      ),
    );

    // Enter invalid email
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify error message
    expect(find.text('Please enter a valid email address'), findsOneWidget);
  });

  testWidgets('Shows error for password mismatch', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegistrationScreen(authService: mockAuthService),
      ),
    );

    // Enter different passwords
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password456');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify error message
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('Successful registration shows success message', (WidgetTester tester) async {
    when(mockAuthService.register(
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      phone: '1234567890',
    )).thenAnswer((_) async => {'success': true});

    await tester.pumpWidget(
      MaterialApp(
        home: RegistrationScreen(authService: mockAuthService),
      ),
    );

    // Fill in all fields correctly
    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '1234567890');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');

    // Submit form
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify success message
    expect(find.text('Registration successful! Please login.'), findsOneWidget);
  });
}

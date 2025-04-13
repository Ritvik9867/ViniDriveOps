import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vinidrive_ops/services/auth_service.dart';
import 'package:vinidrive_ops/screens/auth/registration_screen.dart';
import 'package:vinidrive_ops/models/auth_models.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  testWidgets('RegistrationScreen shows form fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegistrationScreen(authService: mockAuthService),
      ),
    );

    expect(find.text('Register'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('RegistrationScreen shows validation errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegistrationScreen(authService: mockAuthService),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your phone number'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('RegistrationScreen handles successful registration', (WidgetTester tester) async {
    when(mockAuthService.register(
      name: anyNamed('name'),
      phone: anyNamed('phone'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => AuthResponse.success());

    await tester.pumpWidget(
      MaterialApp(
        home: RegistrationScreen(authService: mockAuthService),
      ),
    );

    await tester.enterText(find.byKey(const Key('nameField')), 'Test User');
    await tester.enterText(find.byKey(const Key('phoneField')), '1234567890');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
    await tester.enterText(find.byKey(const Key('confirmPasswordField')), 'password123');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    verify(mockAuthService.register(
      name: 'Test User',
      phone: '1234567890',
      password: 'password123',
    )).called(1);
  });

  testWidgets('RegistrationScreen handles registration failure', (WidgetTester tester) async {
    when(mockAuthService.register(
      name: anyNamed('name'),
      phone: anyNamed('phone'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => AuthResponse.failure('Registration failed'));

    await tester.pumpWidget(
      MaterialApp(
        home: RegistrationScreen(authService: mockAuthService),
      ),
    );

    await tester.enterText(find.byKey(const Key('nameField')), 'Test User');
    await tester.enterText(find.byKey(const Key('phoneField')), '1234567890');
    await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
    await tester.enterText(find.byKey(const Key('confirmPasswordField')), 'password123');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Registration failed'), findsOneWidget);
  });
}

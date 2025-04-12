# Testing Guide for ViniDriveOps

## Overview
This guide outlines the testing strategy and practices for the ViniDriveOps Flutter application. We use Flutter's built-in testing framework to ensure application reliability and functionality.

## Test Types

### 1. Widget Tests
Widget tests verify that the UI components render correctly and handle user interactions as expected.

#### Existing Widget Tests:
- `login_screen_test.dart`: Tests the login screen functionality
  - Form validation
  - Error message display
  - Phone number format validation
  - Form submission behavior

### 2. Integration Tests
Integration tests verify that different parts of the application work together correctly.

#### Key Flows to Test:
- Complete login flow with API integration
- Driver registration process
- Admin dashboard operations
- Driver status updates

## Running Tests

### Widget Tests
```bash
flutter test test/widget_test.dart
flutter test test/login_screen_test.dart
```

### Integration Tests
```bash
flutter test integration_test
```

## Writing New Tests

### Widget Test Template
```dart
testWidgets('description of the test', (WidgetTester tester) async {
  // 1. Setup - Build the widget
  await tester.pumpWidget(const MaterialApp(home: YourWidget()));

  // 2. Action - Interact with the widget
  await tester.enterText(find.byType(TextFormField), 'test input');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  // 3. Assert - Verify the results
  expect(find.text('Expected Result'), findsOneWidget);
});
```

### Best Practices
1. Group related tests using `group()`
2. Test both success and failure scenarios
3. Verify error messages and validation
4. Mock external dependencies
5. Keep tests focused and independent

## Test Coverage
To generate and view test coverage:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Continuous Integration
Tests are automatically run in GitHub Actions on every pull request and push to main branch.

## Adding New Tests
When adding new features:
1. Create corresponding test files in the `test` directory
2. Follow the existing naming convention: `feature_name_test.dart`
3. Include both positive and negative test cases
4. Update this guide as needed
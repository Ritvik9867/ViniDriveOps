# Testing Guide

This document outlines the testing strategy and guidelines for the ViniDriveOps project.

## Overview

This project uses Flutter's testing framework to ensure code quality and reliability. We employ multiple testing levels:

### 1. Widget Tests

Widget tests focus on testing individual UI components in isolation.

#### Existing Widget Tests

- `registration_screen_test.dart`: Tests registration form validation and submission
- `home_screen_test.dart`: Tests navigation and UI elements
- `profile_screen_test.dart`: Tests user profile display and editing

### 2. Integration Tests

Integration tests verify that different parts of the app work together correctly.

#### Key Flows to Test

- Registration flow with form validation
- Profile update with image upload
- Navigation between main screens

## Test Structure

### Widget Tests

Widget tests should follow this structure:
1. Setup test dependencies (mocks)
2. Create the widget under test
3. Define test scenarios
4. Verify expected behavior

### Integration Tests

Integration tests should:
1. Setup test environment
2. Simulate user interactions
3. Verify system state changes
4. Clean up test data

### Widget Test Template

```dart
void main() {
  group('WidgetName', () {
    late MockDependency mockDependency;
    
    setUp(() {
      mockDependency = MockDependency();
    });
    
    testWidgets('description', (tester) async {
      await tester.pumpWidget(/* widget */);
      // Test steps
    });
  });
}
```

### Best Practices

2. Mock external dependencies
3. Test edge cases
4. Keep tests focused and atomic
5. Use meaningful test descriptions
6. Follow AAA pattern (Arrange, Act, Assert)

## Test Coverage

We aim for:
- 80% coverage for business logic
- 70% coverage for UI components
- 90% coverage for critical paths

## Continuous Integration

Tests run automatically on:
- Every push to main branch
- Pull request creation/update
- Manual workflow dispatch

## Adding New Tests

2. Follow existing test patterns
3. Update test documentation
4. Verify CI pipeline passes

## Tools and Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [mockito Package](https://pub.dev/packages/mockito)
- [flutter_test Package](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)

## Common Testing Scenarios

1. Form Validation
```dart
testWidgets('validates email format', (tester) async {
  await tester.enterText(find.byType(TextFormField), 'invalid-email');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  expect(find.text('Invalid email format'), findsOneWidget);
});
```

2. API Integration
```dart
test('handles API error gracefully', () async {
  when(mockApi.getData()).thenThrow(Exception('Network error'));
  await tester.tap(find.byType(RefreshButton));
  await tester.pump();
  expect(find.text('Error: Network error'), findsOneWidget);
});
```

3. Navigation
```dart
testWidgets('navigates to details screen', (tester) async {
  await tester.tap(find.byType(ListTile).first);
  await tester.pumpAndSettle();
  expect(find.byType(DetailsScreen), findsOneWidget);
});
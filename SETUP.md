# ViniDriveOps Setup Guide

This guide will help you set up the ViniDriveOps project locally for development.

## Prerequisites

1. Flutter SDK (3.22.0 or later)
2. Android Studio or VS Code with Flutter extensions
3. Git
4. Java Development Kit (JDK) 17
5. Android SDK (API level 33)

## Installation Steps

1. Clone the repository:
```bash
git clone https://github.com/yourusername/ViniDriveOps.git
cd ViniDriveOps
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Setup Android signing (for release builds):
   - Follow instructions in `docs/repository_secrets_setup.md`
   - Create keystore file
   - Configure signing in Android

4. Configure IDE:
   - Install Flutter and Dart plugins
   - Set Flutter SDK path
   - Configure Android SDK

5. Run the app:
```bash
# Development
flutter run

# Release
flutter build apk --release
# or
flutter build appbundle --release
```

## Project Structure

```
ViniDriveOps/
├── lib/
│   ├── screens/      # UI screens
│   ├── models/       # Data models
│   ├── services/     # Business logic
│   └── utils/        # Helper functions
├── test/            # Test files
├── android/         # Android-specific files
├── ios/            # iOS-specific files
└── docs/           # Documentation
```

## Development Workflow

1. Create a new branch for your feature
2. Write tests first (TDD approach)
3. Implement the feature
4. Run tests locally
5. Create a pull request

## Running Tests

```bash
# Unit and widget tests
flutter test

# With coverage
flutter test --coverage

# Integration tests
flutter test integration_test
```

## CI/CD Pipeline

The project uses GitHub Actions for:
1. Code quality checks
2. Running tests
3. Building release artifacts
4. Deployment (when configured)

## Troubleshooting

1. Build errors:
   - Clean build: `flutter clean`
   - Update dependencies: `flutter pub upgrade`
   - Check Android SDK setup

2. Test failures:
   - Check mock setup
   - Verify test environment
   - Update test dependencies

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Project Wiki](docs/README.md)
- [Contributing Guide](CONTRIBUTING.md)

## Support

For issues and questions:
1. Check existing GitHub issues
2. Create a new issue with details
3. Follow issue template guidelines
# ViniDriveOps Setup Guide

This guide will help you set up the ViniDriveOps project locally for development.

## Prerequisites

1. **Flutter SDK**: Version 3.16.9 or higher
2. **Dart SDK**: Version 3.2.6 or higher
3. **Android Studio**: Latest version with Android SDK
4. **Xcode**: Version 15.2 or higher (for iOS development)
5. **VS Code** (Recommended) with Flutter and Dart plugins

## Development Environment Setup

### Windows Setup

1. Enable Developer Mode:
   - Open Windows Settings
   - Navigate to System > For developers
   - Enable "Developer Mode"
   - Or run `start ms-settings:developers` in PowerShell

2. Install Required Tools:
   ```powershell
   # Install Flutter SDK
   winget install -e --id Google.Flutter

   # Install Git
   winget install -e --id Git.Git

   # Install Android Studio
   winget install -e --id Google.AndroidStudio
   ```

### Project Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/ViniDriveOps.git
   cd ViniDriveOps
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run code generation:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Setup Firebase:
   - Create a new Firebase project
   - Download `google-services.json` to `android/app/`
   - Download `GoogleService-Info.plist` to `ios/Runner/`

### Android Setup

1. Create `key.properties` in `android/` folder for release signing:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<path-to-keystore>/upload-keystore.jks
   ```

2. Generate keystore for signing:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

### iOS Setup

1. Install CocoaPods:
   ```bash
   sudo gem install cocoapods
   ```

2. Install iOS dependencies:
   ```bash
   cd ios
   pod install
   cd ..
   ```

## Running the App

### Development

```bash
# Run in debug mode
flutter run

# Run with specific flavor
flutter run --flavor development
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

### Building

```bash
# Build Android APK
flutter build apk --release

# Build Android App Bundle
flutter build appbundle

# Build iOS
flutter build ios --release
```

## CI/CD Setup

1. Add required secrets to GitHub repository:
   - `KEYSTORE_FILE`: Base64 encoded Android keystore
   - `KEY_PROPERTIES`: Contents of `key.properties`
   - `DISCORD_WEBHOOK`: Discord webhook URL for notifications

2. The CI/CD pipeline will automatically:
   - Run tests
   - Check code formatting
   - Analyze code
   - Build Android and iOS versions
   - Upload artifacts
   - Send notifications on failure

## Best Practices

1. Follow the [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
2. Write tests for all new features
3. Update documentation when making changes
4. Use proper commit messages following conventional commits
5. Create pull requests for all changes

## Troubleshooting

1. If you encounter build errors:
   ```bash
   flutter clean
   flutter pub get
   flutter pub run build_runner clean
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. For iOS build issues:
   ```bash
   cd ios
   pod deintegrate
   pod cache clean --all
   pod install
   cd ..
   ```

3. For Android build issues:
   - Delete `android/.gradle` folder
   - Delete `android/app/build` folder
   - Run `flutter clean && flutter pub get`

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

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Project Wiki](docs/README.md)
- [Contributing Guide](CONTRIBUTING.md)

## Support

For issues and questions:
1. Check existing GitHub issues
2. Create a new issue with details
3. Follow issue template guidelines
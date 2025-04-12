# Repository Secrets Setup Guide

This guide explains how to set up the required secrets for the GitHub Actions workflow.

## Required Secrets

### 1. KEY_PROPERTIES
This secret contains the key.properties file content for Android app signing.

Format:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=keystore.jks
```

### 2. KEYSTORE_FILE
This secret contains the base64-encoded keystore file for Android app signing.

## Setting Up Secrets

### Generate Keys
1. Create a keystore file:
```bash
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Convert keystore to base64:
```bash
base64 -i keystore.jks
```

### Add Secrets to GitHub

1. Navigate to your repository's Settings
2. Select "Secrets and variables" → "Actions"
3. Click "New repository secret"
4. Add each secret with its value
5. Verify secrets are added correctly

## Verification

1. Check repository settings
2. Verify secret names match workflow file
3. Run the workflow to test signing

## Security Notes

- Keep your keystore password secure
- Never commit keystore files to the repository
- Regularly rotate keys for security
- Follow Android signing best practices

## Troubleshooting

1. Workflow fails with signing error:
   - Verify secret names and values
   - Check keystore file encoding
   - Validate key.properties format

2. App won't install after signing:
   - Verify keystore validity
   - Check signing configuration
   - Validate build configuration

## Additional Resources

- [Android App Signing Guide](https://developer.android.com/studio/publish/app-signing)
- [GitHub Actions Secrets Guide](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Flutter Android Release Guide](https://docs.flutter.dev/deployment/android)
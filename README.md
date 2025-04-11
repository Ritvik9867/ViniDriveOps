# ViniDriveOps - Driver Management System

A comprehensive driver management system built with Flutter and Google Apps Script backend.

## Detailed Setup Guide

### 1. Repository Setup

1. Create a new repository on GitHub:
   - Visit [GitHub](https://github.com)
   - Click the '+' icon in the top-right corner
   - Select 'New repository'
   - Name it 'ViniDriveOps'
   - Set it as Public
   - Click 'Create repository'

2. Initialize your local repository:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/ViniDriveOps.git
   git push -u origin main
   ```

### 2. Google Apps Script Setup

1. Create Google Cloud Project:
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Create a new project
   - Enable Google Sheets API
   - Create credentials (API key)
   - Save the API key securely

2. Set up Google Apps Script:
   - Visit [Google Apps Script](https://script.google.com)
   - Create a new project
   - Copy contents from:
     - `backend/Code.gs` → Code.gs
     - `backend/config.gs` → config.gs
     - `backend/setup_sheets.gs` → setup_sheets.gs
   - Update configuration in `config.gs` with your spreadsheet IDs

3. Deploy the web app:
   - Click 'Deploy' > 'New deployment'
   - Choose 'Web app'
   - Set access to 'Anyone'
   - Click 'Deploy'
   - Authorize the app when prompted
   - Copy the deployment URL

### 3. GitHub Repository Configuration

1. Set up repository secrets:
   - Go to your repository on GitHub
   - Navigate to Settings > Secrets and Variables > Actions
   - Add new repository secrets:
     - Name: `GOOGLE_SHEETS_API_KEY`
       Value: Your Google Cloud API key
     - Name: `JWT_SECRET`
       Value: Generate a secure random string (e.g., using an online generator)

2. GitHub Actions workflow is already configured in `.github/workflows/flutter_ci.yml`

### 4. Flutter App Setup

1. Configure API endpoint:
   - Open `lib/services/api_service.dart`
   - Update the `baseUrl` with your Google Apps Script web app URL

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### 5. Testing the Setup

1. Create a test driver account:
   - Launch the app
   - Click 'Register'
   - Fill in driver details
   - Submit the form

2. Verify data flow:
   - Check your Google Sheet for the new entry
   - Try logging in with the created account
   - Test the driver dashboard functionality

## Project Structure

```
ViniDriveOps/
├── .github/workflows/    # CI/CD configuration
├── backend/              # Google Apps Script backend
├── lib/                  # Flutter app source code
│   ├── models/           # Data models
│   ├── screens/          # UI screens
│   └── services/         # Business logic and API services
└── pubspec.yaml          # Flutter dependencies
```

## Support

For issues and feature requests, please create a new issue in the GitHub repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
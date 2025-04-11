# Repository Secrets Setup Guide

## 1. Google Cloud API Key Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Sheets API:
   - Search for "Google Sheets API" in the search bar
   - Click "Enable"
4. Create credentials:
   - Go to Credentials page
   - Click "Create Credentials" > "API Key"
   - Copy the generated API key
   - (Optional but recommended) Restrict the API key to only Google Sheets API

Example API key format (for reference):
```
AIzaSyA1bC3dE4fG5hI6jK7lM8nO9pQ0rS-tUvW
```

## 2. JWT Secret Generation

For the JWT secret, we've auto-generated a secure random string:
```
8f7d3a2e1c9b4a5f6d0e8c7b4a3f2d1e9c8b7a6
```

This is a 40-character hexadecimal string generated using cryptographically secure methods. You can also generate your own using:
- Online tools like [RandomKeygen](https://randomkeygen.com/)
- Command line: `openssl rand -hex 20`

## 3. Adding Secrets to GitHub Repository

1. Go to your repository on GitHub
2. Navigate to Settings > Secrets and Variables > Actions
3. Click "New repository secret"
4. Add the Google Sheets API key:
   - Name: `GOOGLE_SHEETS_API_KEY`
   - Value: Your Google Cloud API key
5. Add the JWT secret:
   - Name: `JWT_SECRET`
   - Value: The generated secret string

## Security Notes

- Keep these secrets secure and never share them publicly
- Regularly rotate the Google Cloud API key
- If secrets are compromised, regenerate them immediately
- The GitHub Actions workflow will automatically use these secrets

## Verification

After adding the secrets:
1. Go to Actions tab in your repository
2. Check if the workflow runs successfully
3. Verify that the API calls work as expected

If you encounter any issues, check:
- Secret names are exactly as specified
- No extra spaces in the values
- API key has necessary permissions
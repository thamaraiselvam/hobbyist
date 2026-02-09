# Building Hobbyist with Environment Variables

## Overview
Firebase credentials are now loaded from environment variables during build time for security. This prevents sensitive API keys from being committed to the repository.

## Setup

### 1. Create `.env` file (optional, for local reference)
```bash
cp .env.example .env
# Edit .env with your Firebase credentials
```

### 2. Get Firebase Credentials
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings > Your apps > Android app
4. Copy the configuration values

## Building with Environment Variables

### Method 1: Command Line (Recommended for CI/CD)
```bash
flutter build apk --release \
  --dart-define=FIREBASE_API_KEY=your_api_key \
  --dart-define=FIREBASE_APP_ID=your_app_id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=FIREBASE_STORAGE_BUCKET=your_storage_bucket
```

### Method 2: Run with Environment Variables
```bash
flutter run --release \
  --dart-define=FIREBASE_API_KEY=your_api_key \
  --dart-define=FIREBASE_APP_ID=your_app_id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=FIREBASE_STORAGE_BUCKET=your_storage_bucket
```

### Method 3: Using Shell Script
Create a `build.sh` script:
```bash
#!/bin/bash

# Source environment variables from .env file
source .env

flutter build apk --release \
  --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY \
  --dart-define=FIREBASE_APP_ID=$FIREBASE_APP_ID \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID \
  --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID \
  --dart-define=FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET
```

Make it executable:
```bash
chmod +x build.sh
./build.sh
```

## CI/CD Setup

### GitHub Actions
Add secrets to your repository:
1. Go to Settings > Secrets and variables > Actions
2. Add each environment variable as a secret

Example workflow:
```yaml
- name: Build APK
  run: |
    flutter build apk --release \
      --dart-define=FIREBASE_API_KEY=${{ secrets.FIREBASE_API_KEY }} \
      --dart-define=FIREBASE_APP_ID=${{ secrets.FIREBASE_APP_ID }} \
      --dart-define=FIREBASE_MESSAGING_SENDER_ID=${{ secrets.FIREBASE_MESSAGING_SENDER_ID }} \
      --dart-define=FIREBASE_PROJECT_ID=${{ secrets.FIREBASE_PROJECT_ID }} \
      --dart-define=FIREBASE_STORAGE_BUCKET=${{ secrets.FIREBASE_STORAGE_BUCKET }}
```

## Verification
After building, verify that credentials are not hardcoded:
```bash
# Check firebase_options.dart
cat lib/firebase_options.dart

# Should see String.fromEnvironment() instead of hardcoded values
```

## Troubleshooting

### Empty credentials error
If you get errors about missing Firebase options, ensure:
1. All environment variables are set
2. You're using `--dart-define` flags (not system env vars)
3. Variable names match exactly (case-sensitive)

### Build fails
- Clean build: `flutter clean && flutter pub get`
- Verify all required variables are provided
- Check for typos in variable names

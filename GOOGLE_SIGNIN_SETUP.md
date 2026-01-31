# Google Sign-In Setup Instructions

## Overview
The Hobbyist app now supports Google Sign-In authentication. Follow these steps to complete the setup.

## Prerequisites
- Firebase project already configured for the app
- Access to [Firebase Console](https://console.firebase.google.com)

## Setup Steps

### 1. Enable Google Sign-In in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (Hobbyist)
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Google** provider
5. Toggle **Enable** switch
6. Set the **Project support email** (required)
7. Click **Save**

### 2. Configure iOS (if building for iOS)

1. In Firebase Console, go to **Project Settings** → **Your apps**
2. Select the iOS app
3. Download the updated `GoogleService-Info.plist`
4. Replace the existing file in `ios/Runner/GoogleService-Info.plist`
5. Open `GoogleService-Info.plist` and find the `REVERSED_CLIENT_ID`
6. In `ios/Runner/Info.plist`, replace `com.googleusercontent.apps.REVERSED_CLIENT_ID` with the actual value from step 5

### 3. Configure Android (if building for Android)

1. In Firebase Console, go to **Project Settings** → **Your apps**
2. Select the Android app
3. Add your SHA-1 certificate fingerprint:
   - For debug builds: Run `keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore`
   - Password is usually `android`
   - Copy the SHA-1 fingerprint
   - Add it to Firebase Console
4. Download the updated `google-services.json`
5. Replace the existing file in `android/app/google-services.json`

### 4. Get SHA-1 Fingerprint (Android)

For **debug** builds:
```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
```
Password: `android`

For **release** builds:
```bash
keytool -list -v -alias your-key-alias -keystore your-keystore-path
```

### 5. Test the Integration

1. Rebuild the app: `flutter clean && flutter pub get`
2. Run the app on a device or emulator
3. On the landing page, tap "Continue with Google"
4. Complete the Google Sign-In flow
5. Verify that:
   - You're redirected to the dashboard
   - Your name appears in Settings
   - Your email is shown below your name
   - The Logout button appears in Settings

## Features

### Landing Page
- **Continue with Google**: Sign in with Google account
- **Continue Offline**: Traditional name input flow (no Google account needed)

### Settings Page
- Shows Google account name (if signed in with Google)
- Shows email address below name (if signed in with Google)
- Name is not editable for Google accounts (synced from Google)
- **Logout** button appears when signed in with Google
- Logging out returns to landing page

### Flow Logic
1. **Google Sign-In Flow**: Landing → Google Auth → Dashboard (no name input)
2. **Offline Flow**: Landing → Name Input → Dashboard
3. **Logout**: Settings → Logout → Landing Page

## Troubleshooting

### Issue: Google Sign-In popup closes but returns to landing page (doesn't navigate to dashboard)

**Symptoms**: 
- Google account selection popup appears
- User selects account
- Popup closes but app stays on landing page
- No error message shown

**Solutions**:
1. **Check Firebase Console Setup**:
   - Verify Google Sign-In is enabled in Authentication → Sign-in method
   - Ensure support email is set
   
2. **Check OAuth Client Configuration**:
   - In Firebase Console → Project Settings → Your apps
   - Verify OAuth client IDs are configured for your platform
   - For Android: SHA-1 certificate must be added
   - For iOS: Bundle ID must match and GoogleService-Info.plist must be present

3. **Check Debug Logs**:
   ```bash
   # Run app with logs
   flutter run
   ```
   Look for these log messages:
   - `🔐 Starting Google Sign-In...`
   - `✅ Google account selected: [email]`
   - `🔑 Got auth tokens`
   - `🔓 Signing in to Firebase...`
   - `✅ Firebase sign-in successful: [email]`
   - `💾 User data saved`
   
   If you see `❌ Error signing in with Google:`, check the error message

4. **Common Fixes**:
   - Run `flutter clean && flutter pub get`
   - Uninstall and reinstall the app
   - Check internet connection
   - Verify google-services.json is up to date (Android)
   - Verify GoogleService-Info.plist is present (iOS)

5. **Android Specific**:
   - Ensure you're using an emulator with Google Play Services or a real device
   - Verify SHA-1 is for the correct keystore (debug vs release)
   - Check that `minSdkVersion` is 23 or higher in build.gradle

6. **iOS Specific**:
   - Ensure URL scheme in Info.plist matches REVERSED_CLIENT_ID from GoogleService-Info.plist
   - Clean iOS build: `cd ios && rm -rf Pods Podfile.lock && pod install`

### Issue: "Sign in failed" or "Unable to sign in"
- Verify SHA-1 certificate is added to Firebase Console
- Ensure `google-services.json` / `GoogleService-Info.plist` are up to date
- Check that Google Sign-In is enabled in Firebase Console
- Run `flutter clean && flutter pub get` and rebuild

### Issue: "REVERSED_CLIENT_ID not found" (iOS)
- Download the latest `GoogleService-Info.plist` from Firebase
- Update the URL scheme in `ios/Runner/Info.plist` with the correct reversed client ID

### Issue: "PlatformException" on Android
- Verify SHA-1 fingerprint is correct
- Make sure you're using a **real device** or **emulator with Google Play Services**
- Check `android/app/google-services.json` is present and valid

### Issue: Still shows name input after Google Sign-In
- Clear app data and reinstall
- Check that `hasCompletedOnboarding` is set in SharedPreferences after sign-in

## Code Changes Summary

### New Files
- `lib/services/auth_service.dart` - Handles Google Sign-In and logout

### Modified Files
- `lib/screens/landing_screen.dart` - Added Google Sign-In button
- `lib/screens/settings_screen.dart` - Shows email, logout button for Google users
- `lib/screens/name_input_screen.dart` - Uses auth service for offline users
- `ios/Runner/Info.plist` - Added URL scheme for Google Sign-In
- `pubspec.yaml` - Added `google_sign_in` and `firebase_auth` packages

## Privacy Notes
- All hobby data remains stored locally in SQLite
- Google Sign-In only stores: display name and email in settings
- No data is sent to external servers
- Logging out clears Google account info but keeps hobby data intact

## Next Steps (Optional)
- Add cloud sync for hobbies (Firebase Firestore)
- Add profile picture from Google account
- Add multi-device sync
- Add backup/restore functionality

---

**Last Updated**: January 2026  
**Version**: 1.0.0+1

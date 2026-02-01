# Hobbyist - Quick Start Guide

## 🚀 Google Sign-In Not Working?

### Step 1: Enable in Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Authentication** → **Sign-in method**
4. Click **Google** and toggle **Enable**
5. Set support email and **Save**

### Step 2: Add SHA-1 Certificate (Android Only)

**Get your SHA-1:**
```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
```
Password: `android`

**Add to Firebase:**
1. Firebase Console → Project Settings
2. Select your Android app
3. Add the SHA-1 fingerprint
4. Download updated `google-services.json`
5. Replace file in `android/app/google-services.json`

### Step 3: Test the App

**Run with logs:**
```bash
flutter clean
flutter pub get
flutter run
```

**Expected logs when working:**
```
🔐 Starting Google Sign-In...
✅ Google account selected: [your-email]
🔑 Got auth tokens
🔓 Signing in to Firebase...
✅ Firebase sign-in successful: [your-email]
💾 User data saved
```

**If you see errors:**
- Check that Google Sign-In is enabled in Firebase
- Verify SHA-1 is correct and added to Firebase
- Ensure internet connection is active
- Use real device or emulator with Google Play Services

---

## 📱 Landing Page Features

### Visual Elements
- ✅ Gradient separator line above buttons
- ✅ White "Continue with Google" button
- ✅ "or" divider between options
- ✅ Purple outlined "Continue Offline" button
- ✅ Privacy note: "All your data stays private and secure on your device."
- ✅ Bottom indicator bar

### User Flows

**Option 1: Google Sign-In**
1. Tap "Continue with Google"
2. Select Google account
3. **Automatically navigate to Dashboard**
4. Name synced from Google account
5. Email shown in Settings

**Option 2: Offline Mode**
1. Tap "Continue Offline"
2. Enter your name
3. Navigate to Dashboard
4. Works completely offline
5. No email tracking

---

## 🔧 Build & Deploy

### Quick Build (Debug)
```bash
flutter build apk --debug
```

### Full Build (Release)
```bash
flutter build apk --release
```

### iOS Build
```bash
flutter build ios --release
```

---

## 🐛 Common Issues

### Google Sign-In returns to landing page
- **Cause**: Firebase OAuth not configured
- **Fix**: Complete Step 1 & 2 above

### "Sign in cancelled" message
- **Cause**: User closed popup without selecting account
- **Fix**: Normal behavior, try again

### Loading spinner stuck
- **Cause**: Network timeout or Firebase error
- **Fix**: Check internet connection, restart app

### App crashes on sign-in
- **Cause**: Missing google-services.json or incorrect minSdk
- **Fix**: Verify files and ensure minSdkVersion is 23+

---

## 📂 Project Structure

```
lib/
├── services/
│   ├── auth_service.dart       # 🔐 Google Sign-In logic
│   ├── hobby_service.dart      # Database operations
│   └── notification_service.dart
├── screens/
│   ├── landing_screen.dart     # 🏠 Entry point with login
│   ├── settings_screen.dart    # ⚙️ Shows email & logout
│   └── daily_tasks_screen.dart # 📊 Main dashboard
└── main.dart                   # App entry
```

---

## ✅ Testing Checklist

Before deploying:
- [ ] Google Sign-In enabled in Firebase
- [ ] SHA-1 added to Firebase (Android)
- [ ] google-services.json is latest version
- [ ] Build completes without errors
- [ ] Google Sign-In navigates to dashboard
- [ ] Name shows correctly in Settings
- [ ] Email shows for Google users
- [ ] Logout button appears for Google users
- [ ] Offline mode still works
- [ ] Hobbies persist after logout

---

**Need more help?** See `GOOGLE_SIGNIN_SETUP.md` for detailed setup instructions.

# SHA-1 Certificate - Complete Guide

## 🤔 What is SHA-1?

**SHA-1 is NOT a file you create or store.** It's a **fingerprint** of your Android signing key that already exists on your computer.

Think of it like this:
- Your Android app is signed with a key (like a signature)
- SHA-1 is the fingerprint of that signature
- Google needs this fingerprint to verify your app when users sign in

**You don't generate it - you READ it from an existing file!**

---

## 📂 Where is the Key Stored?

Android automatically creates a debug key when you install Android Studio/Flutter:

**Location**: `~/.android/debug.keystore`

This file already exists on your Mac! We just need to read its SHA-1 fingerprint.

---

## 🔑 Get Your SHA-1 (Step-by-Step)

### Step 1: Open Terminal

### Step 2: Run This Command

```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
```

### Step 3: When Asked for Password

Type: `android`

(This is the default password for debug keystore)

### Step 4: Copy the SHA-1

You'll see output like this:

```
Certificate fingerprints:
     SHA1: 1A:2B:3C:4D:5E:6F:7G:8H:9I:0J:1K:2L:3M:4N:5O:6P:7Q:8R:9S:0T
     SHA256: ...
```

**Copy the SHA-1 value** (the part after "SHA1:")

Example: `1A:2B:3C:4D:5E:6F:7G:8H:9I:0J:1K:2L:3M:4N:5O:6P:7Q:8R:9S:0T`

---

## 🔥 Add SHA-1 to Firebase

### Step 1: Go to Firebase Console
https://console.firebase.google.com

### Step 2: Select Your Project
Click on your Hobbyist project

### Step 3: Go to Project Settings
Click the gear icon (⚙️) → Project settings

### Step 4: Find Your Android App
Scroll down to "Your apps" section → Click on your Android app

### Step 5: Add SHA-1
1. Scroll to "SHA certificate fingerprints"
2. Click "Add fingerprint"
3. Paste your SHA-1 (the one you copied)
4. Click "Save"

### Step 6: Download Updated Config
1. Still in Project Settings → Your apps
2. Click "Download google-services.json"
3. Replace the file in your project:
   ```
   android/app/google-services.json
   ```

---

## ❓ Common Questions

### Q: What if the keystore file doesn't exist?
A: Run any Flutter Android build once, and it will be created automatically:
```bash
flutter build apk --debug
```

### Q: What if I lose the SHA-1?
A: **You can't "lose" it!** The SHA-1 is just a fingerprint. As long as you have the keystore file (`~/.android/debug.keystore`), you can always read the SHA-1 again using the keytool command.

### Q: What if I lose the keystore file?
A: For **debug** builds, it will be auto-regenerated with a new SHA-1. You'll just need to add the new SHA-1 to Firebase.

For **release** builds (production apps), losing the keystore is serious - you can't update your app on Play Store. Always backup your release keystore!

### Q: Do I need different SHA-1 for debug and release?
A: YES!
- **Debug**: Use debug.keystore SHA-1 (for development/testing)
- **Release**: Create your own keystore and add its SHA-1 (for production)

### Q: Can I add multiple SHA-1s?
A: YES! You can (and should) add both:
- Debug SHA-1 (for testing)
- Release SHA-1 (for production)
- Even different developers' debug SHA-1s

### Q: Does iOS need SHA-1?
A: NO! SHA-1 is Android-only. iOS uses a different setup (GoogleService-Info.plist with URL schemes).

---

## 🚀 Quick Commands Reference

### Get Debug SHA-1 (Mac/Linux)
```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
```
Password: `android`

### Get Debug SHA-1 (Windows)
```bash
keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore
```
Password: `android`

### Get SHA-256 (also useful)
The same command shows SHA-256 - copy that too! Firebase accepts both.

---

## 📋 After Adding SHA-1

1. ✅ Download updated `google-services.json`
2. ✅ Replace file in `android/app/google-services.json`
3. ✅ Run `flutter clean`
4. ✅ Run `flutter pub get`
5. ✅ Run `flutter run` and test Google Sign-In

---

## 🎯 Complete Checklist

- [ ] Google Sign-In enabled in Firebase Console
- [ ] SHA-1 obtained from debug keystore
- [ ] SHA-1 added to Firebase Console
- [ ] Downloaded latest google-services.json
- [ ] Replaced google-services.json in project
- [ ] Ran `flutter clean && flutter pub get`
- [ ] Tested Google Sign-In on device/emulator

---

## 🐛 Troubleshooting

### Error: "keytool: command not found"
**Solution**: Java JDK is not installed or not in PATH.

Check if Java is installed:
```bash
java -version
```

If not installed, install Java JDK and try again.

### Error: "Keystore was tampered with, or password was incorrect"
**Solution**: Try these passwords in order:
1. `android` (default)
2. `changeit`
3. Leave blank (press Enter)

### Firebase Still Not Working After Adding SHA-1
1. Wait 5 minutes (Firebase needs time to propagate changes)
2. Uninstall app completely from device
3. Reinstall: `flutter run`
4. Try Google Sign-In again

---

**Need Help?** Check logs when running:
```bash
flutter run
```

Look for these emoji logs:
- 🔐 Starting Google Sign-In...
- ✅ Google account selected
- 🔑 Got auth tokens
- ✅ Firebase sign-in successful

If you see ❌ errors, they'll tell you what's wrong!

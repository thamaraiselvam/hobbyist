# Firebase DebugView - Step-by-Step Guide

## ✅ Current Status

Your Firebase Analytics is **WORKING**! Events are being sent, but you need to view them in **DebugView** mode because:
- Standard Analytics Dashboard has a 24-48 hour delay
- DebugView shows events in real-time

## 🔧 What's Already Done

✅ Firebase initialized successfully (confirmed in logs)
✅ Debug mode enabled on your device
✅ Events are being logged (`screen_view` confirmed)
✅ App is connected to Firebase project: hobbyist-dfe13

## 📱 Step-by-Step Instructions

### Step 1: Open Firebase Console

1. Go to: **https://console.firebase.google.com/**
2. Select project: **hobbyist-dfe13**

### Step 2: Open DebugView

1. In the left sidebar, click **Analytics**
2. Click **DebugView** (NOT Dashboard)
3. You should see a page that says "Select a device"

### Step 3: Verify Device Connection

Your device should appear as:
- Device ID: R5CX810KBYX
- Status: Green dot (active)

If you DON'T see your device:
```bash
# Run this command again:
adb shell setprop debug.firebase.analytics.app tham.hobbyist.app

# Restart your app
adb shell am force-stop tham.hobbyist.app
adb shell am start -n tham.hobbyist.app/.MainActivity
```

### Step 4: Generate Events

In your app, perform these actions:
1. **Navigate between screens** → triggers `screen_view`
2. **Create a new hobby** → triggers `hobby_created`
3. **Toggle completion** → triggers `completion_toggled`
4. **View analytics screen** → triggers `analytics_viewed`

### Step 5: Watch Events in DebugView

You should see events appear in real-time:
- `screen_view`
- `hobby_created` 
- `completion_toggled`
- `analytics_viewed`
- etc.

Click on any event to see its parameters.

## 🔍 Troubleshooting

### Issue: Device Not Showing in DebugView

**Solution 1**: Verify debug mode
```bash
adb shell getprop debug.firebase.analytics.app
# Should output: tham.hobbyist.app
```

**Solution 2**: Check internet connection
- Your device needs internet (WiFi or mobile data)
- Firebase sends events to Google servers

**Solution 3**: Restart everything
```bash
# 1. Disable debug mode
adb shell setprop debug.firebase.analytics.app .none.

# 2. Uninstall app
adb uninstall tham.hobbyist.app

# 3. Reinstall
cd /Users/tham/repo/github/hobbyist
adb install build/app/outputs/flutter-apk/app-debug.apk

# 4. Re-enable debug mode
adb shell setprop debug.firebase.analytics.app tham.hobbyist.app

# 5. Launch app
adb shell am start -n tham.hobbyist.app/.MainActivity
```

### Issue: Events Not Appearing

**Check logs**:
```bash
adb logcat -s FA-SVC:V | grep "Logging event"
```

You should see lines like:
```
Logging event: origin=app,name=hobby_created,params=...
```

### Issue: Network Error

If you see "Connection refused" or "ERR_CONNECTION_REFUSED":
1. Check device has internet connection
2. Try switching between WiFi and mobile data
3. Disable VPN if running
4. Check firewall settings

## 📊 What to Expect

### In DebugView (Real-time):
✅ Events appear immediately
✅ Can see event parameters
✅ Can monitor multiple devices

### In Analytics Dashboard (24-48 hours):
- Historical data
- Aggregated metrics  
- User counts
- Conversion funnels

## 🎯 Quick Test

Run this to verify analytics is working:

```bash
# 1. Clear logs
adb logcat -c

# 2. Restart app
adb shell am force-stop tham.hobbyist.app
adb shell am start -n tham.hobbyist.app/.MainActivity

# 3. Wait 3 seconds then check
sleep 3
adb logcat -d -s FA-SVC:V | grep "Logging event"
```

You should see output like:
```
V/FA-SVC: Logging event: origin=auto,name=screen_view...
```

## ✅ Verification Checklist

- [ ] Firebase Console open
- [ ] DebugView page open (not Dashboard)
- [ ] Device shows as connected (green dot)
- [ ] Performed actions in app
- [ ] Events appearing in DebugView
- [ ] Can click events to see parameters

## 📞 If Still Not Working

1. **Screenshot** your Firebase DebugView page
2. **Run** this command and share output:
```bash
adb logcat -d -s FA-SVC:V | grep "Logging event" | tail -20
```

## 🎉 Success Indicators

You'll know it's working when you see:
- ✅ Events listed in DebugView
- ✅ Event count incrementing
- ✅ Parameters visible when clicking events
- ✅ Multiple event types (screen_view, hobby_created, etc.)

---

**Remember**: DebugView is for REAL-TIME testing. Standard Analytics Dashboard takes 24-48 hours to populate.

Your analytics IS working - you just need to view it in the right place! 🚀

# Firebase Analytics - Quick Start Guide

## 🔥 View Your Analytics

1. **Firebase Console**: https://console.firebase.google.com/
2. **Project**: hobbyist-dfe13
3. **Package**: tham.hobbyist.app

## 📊 Real-Time Debugging

```bash
# Enable debug mode
adb shell setprop debug.firebase.analytics.app tham.hobbyist.app

# View logs
adb logcat -v time -s FA FA-SVC

# Disable debug mode
adb shell setprop debug.firebase.analytics.app .none.
```

Then open Firebase Console → DebugView to see events in real-time.

## 🎯 Key Events Being Tracked

| Event | When | Where |
|-------|------|-------|
| `app_open` | App launches | Automatic |
| `screen_view` | Screen changes | Automatic |
| `hobby_created` | New hobby | HobbyService |
| `hobby_updated` | Edit hobby | HobbyService |
| `hobby_deleted` | Delete hobby | HobbyService |
| `completion_toggled` | Mark complete | HobbyService |
| `streak_milestone` | 7/14/30/50/100/365 days | HobbyService |
| `user_onboarding_complete` | Finish setup | NameInputScreen |
| `analytics_viewed` | Open analytics | AnalyticsScreen |
| `setting_changed` | Change setting | HobbyService |

## 🚀 Adding New Events

Edit `lib/services/analytics_service.dart`:

```dart
Future<void> logMyEvent({
  required String param1,
}) async {
  await _analytics?.logEvent(
    name: 'my_event',
    parameters: {
      'param1': param1,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
  );
}
```

Use in code:
```dart
await AnalyticsService().logMyEvent(param1: 'value');
```

## 📈 Common Metrics to Monitor

- **Daily Active Users**: Count of `app_open` events
- **Hobby Creation Rate**: Count of `hobby_created` events
- **Completion Rate**: `completion_toggled` (completed=true) / total hobbies
- **7-Day Streaks**: Count of `streak_milestone` (streak_count=7)
- **Onboarding Rate**: Count of `user_onboarding_complete` events

## 🔐 Privacy Notes

✅ No user names or personal data tracked
✅ All data is anonymized by Firebase
✅ Device IDs are hashed
✅ GDPR/CCPA compliant

## 📚 Full Documentation

See `FIREBASE_ANALYTICS_INTEGRATION.md` for complete details.

---

*Quick reference for Firebase Analytics in Hobbyist app*

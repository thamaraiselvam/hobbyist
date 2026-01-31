# Firebase Analytics - What Data is Being Collected & Where to View It

**Last Updated**: January 31, 2026  
**App**: Hobbyist (tham.hobbyist.app)

---

## 📊 Summary

| Data Type | Collected? | Where to View |
|-----------|------------|---------------|
| **Phone Model** | ✅ Automatic | Audience → Tech → Devices |
| **OS Version** | ✅ Automatic | Audience → Tech → Operating Systems |
| **App Version** | ✅ Automatic | Audience → Tech → App Versions |
| **Country/Region** | ✅ Automatic | Audience → Demographics |
| **Device Language** | ✅ Automatic | Audience → Demographics |
| **Screen Resolution** | ✅ Automatic | Audience → Tech → Devices |
| **Database Performance** | ❌ **NOT Tracked** | N/A (needs implementation) |

---

## ✅ AUTOMATIC DATA COLLECTION (Already Working)

Firebase Analytics **automatically collects** the following without any code:

### 1. Device Information

**What's Collected**:
- Device model (e.g., "SM-G998B" = Samsung Galaxy S21 Ultra)
- Device manufacturer (e.g., "samsung", "google")
- Device category (mobile, tablet, desktop)
- Screen resolution (e.g., 1440x3200)
- Device brand

**Where to View**:
```
Firebase Console → Analytics → Audience → Tech → Devices
```

You'll see charts like:
- Top device models
- Usage by device
- Active users per device

---

### 2. Operating System Information

**What's Collected**:
- OS name (Android, iOS)
- OS version (e.g., "Android 13", "Android 14")
- API level (e.g., API 33, API 34)

**Where to View**:
```
Firebase Console → Analytics → Audience → Tech → Operating Systems
```

You'll see:
- Android version distribution
- OS update adoption
- Active users by OS version

---

### 3. App Version Information

**What's Collected**:
- App version (currently 1.0.0)
- Version code (currently 1)
- First install time
- Last update time

**Where to View**:
```
Firebase Console → Analytics → Audience → Tech → App Versions
```

Useful for:
- Tracking update adoption
- Identifying which versions have issues
- A/B testing between versions

---

### 4. Geographic Information

**What's Collected** (based on IP address):
- Country
- Region/State (approximate)
- City (approximate)
- Time zone

**Where to View**:
```
Firebase Console → Analytics → Audience → Demographics → Countries
Firebase Console → Analytics → Audience → Demographics → Cities
```

**Privacy Note**: Location is derived from IP, not GPS. It's approximate and anonymous.

---

### 5. User Engagement Metrics

**What's Collected**:
- Session duration (how long user used app)
- Session count (number of app opens)
- Active users (daily, weekly, monthly)
- Engagement time (active time in app)
- First open (when user first opened app)
- Last engagement time

**Where to View**:
```
Firebase Console → Analytics → Engagement → Overview
Firebase Console → Analytics → Retention → User Engagement
```

---

### 6. Language & Locale

**What's Collected**:
- Device language setting
- App locale

**Where to View**:
```
Firebase Console → Analytics → Audience → Demographics → Languages
```

---

## ❌ DATABASE PERFORMANCE (NOT Currently Tracked)

**Status**: Method exists but **NOT IMPLEMENTED**

We created the method `logDatabaseQueryTime()` in AnalyticsService but never actually call it anywhere in the code. 

**What it WOULD track** (if implemented):
- Query execution time
- Query type (SELECT, INSERT, UPDATE, DELETE)
- Slow query detection

**Current State**:
```dart
// Method exists in analytics_service.dart
Future<void> logDatabaseQueryTime({
  required String queryType,
  required int durationMs,
}) async {
  // ... code exists but NEVER CALLED
}
```

**To actually track database performance**, we would need to:
1. Measure query execution time in DatabaseHelper
2. Call `AnalyticsService().logDatabaseQueryTime()` after each query
3. This is NOT currently done

---

## 🔍 WHERE TO VIEW ALL YOUR DATA

### Quick Access Guide

**1. Real-Time Events** (Live, as they happen)
```
Firebase Console → Analytics → DebugView
```
- See events instantly
- View event parameters
- Monitor your test device

**2. Device & OS Data** (24-48 hour delay)
```
Firebase Console → Analytics → Audience → Tech
```
Then select:
- **Devices** → See phone models
- **Operating Systems** → See Android versions
- **App Versions** → See app version distribution

**3. Geographic Data**
```
Firebase Console → Analytics → Audience → Demographics
```
Then select:
- **Countries** → Where users are located
- **Cities** → City-level distribution
- **Languages** → User language preferences

**4. Custom Events**
```
Firebase Console → Analytics → Events
```
- See all your custom events (hobby_created, etc.)
- View event parameters
- Track event frequency

**5. User Behavior Flow**
```
Firebase Console → Analytics → User Journey
```
- See how users navigate your app
- Identify drop-off points
- Understand user paths

---

## 📱 EXAMPLE: View Your Phone Model Data

**Step-by-Step**:

1. Go to: https://console.firebase.google.com/
2. Select: **hobbyist-dfe13**
3. In left sidebar: **Analytics** → **Audience**
4. Click: **Tech details**
5. Click: **Devices**

**You'll see**:
```
Device Model          | Active Users | Percentage
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SM-G998B              | 1           | 100%
(Samsung Galaxy S21)
```

---

## 💾 EXAMPLE: View OS Information

**Step-by-Step**:

1. Go to: https://console.firebase.google.com/
2. Select: **hobbyist-dfe13**
3. In left sidebar: **Analytics** → **Audience**
4. Click: **Tech details**
5. Click: **Operating Systems**

**You'll see**:
```
OS Version    | Active Users | Percentage
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Android 13    | 1           | 100%
```

---

## 🌍 EXAMPLE: View Geographic Data

**Step-by-Step**:

1. Go to: https://console.firebase.google.com/
2. Select: **hobbyist-dfe13**
3. In left sidebar: **Analytics** → **Audience**
4. Click: **Demographics**
5. Click: **Countries**

**You'll see**:
```
Country       | Active Users | Percentage
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
India         | 1           | 100%
```

---

## ⏰ DATA AVAILABILITY TIMELINE

| View | Data Availability |
|------|-------------------|
| **DebugView** | Instant (real-time) |
| **Events Tab** | ~1-4 hours delay |
| **Audience (Devices/OS)** | 24-48 hours delay |
| **Demographics** | 24-48 hours delay |
| **Reports** | 24-48 hours delay |

**Note**: First-time data can take longer to appear (up to 72 hours).

---

## 🔐 PRIVACY & DATA COLLECTION

### What Firebase Knows About Users:

**Collected**:
- ✅ Device model (e.g., "SM-G998B")
- ✅ OS version (e.g., "Android 13")
- ✅ Approximate location (country/city from IP)
- ✅ App usage patterns
- ✅ Device language

**NOT Collected**:
- ❌ User names (we don't send this)
- ❌ Personal information
- ❌ Email addresses
- ❌ Phone numbers
- ❌ Exact GPS location
- ❌ Photos or files
- ❌ Contacts

### User Identifiers:

Firebase uses:
- **App Instance ID** (randomly generated per app install)
- **User ID** (anonymized hash, NOT your user's name)

Both are anonymous and can't be traced back to real people.

---

## 🛠️ TO ENABLE DATABASE PERFORMANCE TRACKING

If you want to track database performance, we need to implement it:

**1. Update DatabaseHelper** to measure queries:
```dart
Future<List<Map<String, dynamic>>> query(...) async {
  final startTime = DateTime.now();
  
  final result = await db.query(...);
  
  final duration = DateTime.now().difference(startTime).inMilliseconds;
  
  // Log to analytics
  AnalyticsService().logDatabaseQueryTime(
    queryType: 'query_hobbies',
    durationMs: duration,
  );
  
  return result;
}
```

**2. Do this for**:
- query() operations
- insert() operations
- update() operations
- delete() operations

**3. Then view in Firebase**:
```
Firebase Console → Analytics → Events → db_query_performance
```

**Currently**: This is **NOT implemented**, so no database performance data is being collected.

---

## 📊 WHAT YOU'RE CURRENTLY TRACKING

### Automatic (From Firebase):
✅ Device model, OS version, app version
✅ Country, language, timezone
✅ Session duration, active users
✅ Screen resolution

### Manual (Our Custom Events):
✅ hobby_created, hobby_updated, hobby_deleted
✅ completion_toggled, streak_milestone
✅ user_onboarding_complete
✅ analytics_viewed, setting_changed
✅ And 10+ more custom events

### NOT Tracking:
❌ Database query performance
❌ Memory usage
❌ Network requests
❌ Battery consumption

---

## 🎯 RECOMMENDED: Add Performance Monitoring

To get more technical metrics (including performance), add **Firebase Performance Monitoring**:

```dart
// Add to pubspec.yaml
firebase_performance: ^0.9.3

// In code
final trace = FirebasePerformance.instance.newTrace('db_query');
await trace.start();

// ... do database query ...

await trace.stop();
```

This would give you:
- App startup time
- Screen rendering performance
- Network request timing
- Custom performance traces

**Cost**: FREE  
**Effort**: 1 day  
**Value**: High for production apps

---

## ✅ VERIFICATION

To see if your device data is showing up:

**1. Check DebugView** (should work now):
```
Firebase Console → Analytics → DebugView
Select your device → See events in real-time
```

**2. Check Events** (1-4 hours):
```
Firebase Console → Analytics → Events
Look for your custom events
```

**3. Check Device Data** (24-48 hours):
```
Firebase Console → Analytics → Audience → Tech → Devices
Should show your phone model
```

**If you don't see data yet**: Wait 24-48 hours for the Analytics Dashboard to populate. Use DebugView for immediate feedback.

---

## 📞 SUMMARY

**Q: Is Firebase collecting my phone model info?**  
✅ **YES** - Automatically, visible in Analytics → Audience → Tech → Devices

**Q: Is Firebase collecting OS info?**  
✅ **YES** - Automatically, visible in Analytics → Audience → Tech → Operating Systems

**Q: Is Firebase collecting database performance?**  
❌ **NO** - We created the method but haven't implemented the calls

**Where to view everything?**  
📊 Firebase Console → Analytics (multiple sections as detailed above)

---

*Your device and OS data is being collected automatically and will appear in Firebase Console within 24-48 hours.*

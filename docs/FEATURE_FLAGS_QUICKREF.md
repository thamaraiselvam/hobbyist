# Feature Flags Quick Reference

## Firebase Console Setup

**Parameter**: `developer_settings`

**Value**:
```json
{
  "feature_access_by_email": {
    "itistham4@gmail.com": {
      "settings_developer_options": true,
      "pull_down_to_refresh": true,
      "settings_analytics_and_crash_reports": true
    }
  }
}
```

## Code Usage

```dart
// Import
import '../services/feature_flags_service.dart';

// Check feature
if (FeatureFlagsService().isDeveloperOptionsEnabled) {
  // Show feature
}

// Check any feature
if (FeatureFlagsService().isFeatureEnabled('my_feature')) {
  // Show feature  
}

// Get all enabled features
List<String> features = FeatureFlagsService().getEnabledFeatures();

// Refresh from Firebase
await FeatureFlagsService().refresh();
```

## Available Features

| Feature Key | Getter | What It Does |
|------------|--------|--------------|
| `settings_developer_options` | `isDeveloperOptionsEnabled` | Shows Developer Options in Settings |
| `pull_down_to_refresh` | `isPullToRefreshEnabled` | Enables pull-to-refresh (not yet implemented) |
| `settings_analytics_and_crash_reports` | `isAnalyticsAndCrashReportsEnabled` | Shows Analytics toggle in Settings |

## Important Notes

✅ **Works only for Google Sign-In users** (requires email)  
❌ **Does NOT work for offline users** (no email = no features)  
🔄 **Auto-refresh every 12 hours** or call `refresh()` manually  
📧 **Email must match exactly** (case-sensitive)

## Testing

```bash
# 1. Add email to Firebase Console Remote Config
# 2. Publish changes
# 3. In app, test with:

# Authorized user
itistham4@gmail.com → Features visible

# Unauthorized user  
other@gmail.com → Features hidden

# Offline user
Skip sign-in → Features hidden
```

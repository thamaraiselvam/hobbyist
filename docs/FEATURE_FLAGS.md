# Feature Flags System

The Hobbyist app uses Firebase Remote Config to enable/disable features for specific users based on their email address.

## Overview

The `FeatureFlagsService` reads a JSON configuration from Firebase Remote Config parameter called `developer_settings` and enables features only for authorized email addresses.

## How It Works

1. **Firebase Remote Config**: Store feature flags in a JSON structure
2. **Email-Based Access**: Features are enabled per user email (from Google Sign-In)
3. **Offline Users**: Feature flags are NOT available for offline users (no email = no features)
4. **Real-time Updates**: Changes in Remote Config can be fetched without app updates

## Configuration Format

In Firebase Console, add a parameter named `developer_settings` with this JSON structure:

```json
{
  "feature_access_by_email": {
    "user1@example.com": {
      "settings_developer_options": true,
      "pull_down_to_refresh": true,
      "settings_analytics_and_crash_reports": true
    },
    "user2@example.com": {
      "settings_developer_options": false,
      "pull_down_to_refresh": true,
      "settings_analytics_and_crash_reports": false
    }
  }
}
```

## Available Features

### 1. `settings_developer_options`
- Shows/hides the "Developer Options" section in Settings
- Grants access to advanced debugging and testing features

### 2. `pull_down_to_refresh`
- Enables pull-to-refresh gesture on screens
- Useful for testing data refresh without restarting app

### 3. `settings_analytics_and_crash_reports`
- Shows/hides "Analytics & Crash Reports" toggle in Settings
- Allows users to manage telemetry opt-in/out

## Usage in Code

### Check if a feature is enabled

```dart
import '../services/feature_flags_service.dart';

// Check specific feature
if (FeatureFlagsService().isFeatureEnabled('settings_developer_options')) {
  // Show developer options
}

// Use convenience getters
if (FeatureFlagsService().isDeveloperOptionsEnabled) {
  // Show developer options
}

if (FeatureFlagsService().isPullToRefreshEnabled) {
  // Enable pull-to-refresh
}

if (FeatureFlagsService().isAnalyticsAndCrashReportsEnabled) {
  // Show analytics toggle
}
```

### Get all enabled features for current user

```dart
List<String> enabledFeatures = FeatureFlagsService().getEnabledFeatures();
print('Enabled features: $enabledFeatures');
```

### Refresh feature flags from Remote Config

```dart
await FeatureFlagsService().refresh();
```

## Example: Conditional UI

```dart
Widget build(BuildContext context) {
  return Column(
    children: [
      // Always visible
      Text('Welcome to Hobbyist'),
      
      // Only visible if feature flag is enabled for user's email
      if (FeatureFlagsService().isDeveloperOptionsEnabled) ...[
        Divider(),
        Text('Developer Mode Active'),
        ElevatedButton(
          onPressed: () => _showDebugInfo(),
          child: Text('Debug Info'),
        ),
      ],
    ],
  );
}
```

## Setup Instructions

### 1. Configure Firebase Remote Config

1. Go to Firebase Console → Remote Config
2. Add a new parameter:
   - **Parameter key**: `developer_settings`
   - **Default value**:
     ```json
     {"feature_access_by_email":{}}
     ```
3. Add conditional values for specific app versions or user segments if needed
4. Publish changes

### 2. Add User Email Access

Update the JSON to include the user's email:

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

### 3. User Must Sign In with Google

- Feature flags only work for users signed in with Google (provides email)
- Offline users will NOT see any feature-flagged content
- Check `AuthService().isLoggedIn` and `AuthService().userEmail` for status

## Testing

### Test Feature Flag Behavior

1. **As authorized user** (itistham4@gmail.com):
   - Sign in with Google using authorized email
   - Navigate to Settings
   - Verify "Developer Options" appears
   - Verify "Analytics & Crash Reports" appears

2. **As unauthorized user**:
   - Sign in with different Google account
   - Navigate to Settings
   - Verify "Developer Options" is hidden
   - Verify "Analytics & Crash Reports" is hidden (or default behavior)

3. **As offline user**:
   - Skip Google Sign-In
   - Navigate to Settings
   - Verify all feature-flagged sections are hidden

### Update Remote Config

To test real-time updates:

```dart
// Manually trigger fetch
await FeatureFlagsService().refresh();
setState(() {}); // Rebuild UI with new flags
```

## Privacy & Security

- ✅ Feature flags use email addresses (already known by Firebase Auth)
- ✅ No additional PII is collected
- ✅ Email-to-feature mapping stored in Firebase (server-side)
- ✅ Offline users are excluded (no tracking possible)
- ⚠️ Email addresses visible in Remote Config (use Firebase security rules)

## Adding New Features

1. Add feature to `developer_settings` JSON in Firebase Console
2. Add convenience getter to `FeatureFlagsService`:
   ```dart
   bool get isMyNewFeatureEnabled => isFeatureEnabled('my_new_feature');
   ```
3. Use in UI:
   ```dart
   if (FeatureFlagsService().isMyNewFeatureEnabled) {
     // Show feature
   }
   ```

## Troubleshooting

### Feature not showing for authorized email

1. Check Firebase Console → Remote Config
2. Verify JSON syntax is correct
3. Verify email matches exactly (case-sensitive)
4. Check app logs for parsing errors
5. Try manual refresh: `await FeatureFlagsService().refresh()`

### Features showing for offline users

- Verify you're checking `AuthService().isLoggedIn` before `FeatureFlagsService()` check
- Ensure `isFeatureEnabled()` returns `false` when user is not logged in

### JSON parsing errors

```
❌ Error parsing developer_settings: ...
```

- Validate JSON at https://jsonlint.com
- Ensure all keys are strings in quotes
- Ensure boolean values are `true`/`false` (not strings)

## Architecture

```
Firebase Remote Config
       ↓
RemoteConfigService (fetches config)
       ↓
FeatureFlagsService (parses & checks email)
       ↓
UI Components (conditional rendering)
```

## Files

- `lib/services/feature_flags_service.dart` - Main service
- `lib/services/remote_config_service.dart` - Firebase Remote Config wrapper
- `lib/services/auth_service.dart` - Google Sign-In and email provider
- `lib/main.dart` - Initialization of FeatureFlagsService
- `lib/screens/settings_screen.dart` - Example usage

## Notes

- Feature flags load on app startup
- Changes require `fetchAndActivate()` or manual `refresh()`
- Default fetch interval: 12 hours (configurable in RemoteConfigService)
- Use sparingly to avoid cluttering Remote Config
- Consider using for beta features, A/B testing, or admin-only tools

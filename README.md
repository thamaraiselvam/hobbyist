# Hobby Tracker

A Flutter application to track your daily hobbies with a GitHub-style contribution chart.

## Features

- **Create & Edit Hobbies**: Add new hobbies with custom names, descriptions, and colors
- **Daily Tracking**: Mark hobbies as complete for each day with a simple tap
- **Contribution Chart**: Visualize your consistency with a GitHub-style heatmap showing 12 weeks of activity
- **Analytics Dashboard**: See your progress at a glance
- **Persistent Storage**: All data saved locally using SharedPreferences

## Project Structure

```
hobby_tracker/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── hobby.dart            # Hobby data model
│   ├── services/
│   │   └── hobby_service.dart    # Data persistence service
│   ├── screens/
│   │   ├── dashboard_screen.dart # Main dashboard with chart
│   │   └── hobby_form_screen.dart # Add/edit hobby form
│   └── widgets/
│       └── contribution_chart.dart # GitHub-style contribution chart
└── pubspec.yaml                  # Dependencies
```

## Installation

1. Ensure Flutter is installed on your system
2. Navigate to the project directory:
   ```bash
   cd hobby_tracker
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. **Add a Hobby**: Tap the + button to create a new hobby with a name, description, and color
2. **Complete Today**: Tap on any hobby card to mark it complete for today
3. **Edit Hobby**: Use the edit icon to modify hobby details
4. **Delete Hobby**: Use the delete icon to remove a hobby
5. **View Analytics**: The contribution chart shows your completion pattern over the last 12 weeks

## Dependencies

- `shared_preferences`: Local data storage
- `intl`: Date formatting
- `flutter_colorpicker`: Color selection for hobbies

## License

This project is created for personal use and learning purposes.

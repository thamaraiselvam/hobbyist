# Hobby Tracker - Feature Specifications

## 🎨 UI/UX Features

### Dashboard Screen
```
┌─────────────────────────────────────┐
│  Hobby Tracker                    ⚙ │
├─────────────────────────────────────┤
│                                     │
│  Contribution Overview              │
│  ┌───────────────────────────────┐ │
│  │ Jan  Feb  Mar                 │ │
│  │ ▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢ │ │
│  │ ▢▢■■▢■▢▢■■■▢▢■▢■▢■■■▢▢▢■▢▢▢▢ │ │
│  │ ▢■■▢■■▢■▢■▢▢■■■■▢▢■▢▢■▢■■▢▢■ │ │
│  │ ■▢■■■▢■▢■■▢■▢■▢■■■▢■■■■▢■■■▢ │ │
│  │ ▢■▢■▢■■■▢■■■■▢■▢■▢■■▢■▢■▢■▢■■ │ │
│  │ ■■■▢■■▢■■▢■▢■■■▢■■■▢■■■▢■■▢■ │ │
│  │ ▢■▢■■▢■▢■■■■▢■▢■■▢■■■▢■■■▢■■ │ │
│  │                               │ │
│  │ Less ▢▢■■■ More               │ │
│  └───────────────────────────────┘ │
│                                     │
├─────────────────────────────────────┤
│  Today's Hobbies      Jan 27, 2026 │
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐ │
│  │ 🔵 Morning Yoga          ✏️ 🗑️ │ │
│  │    15 minutes stretching      │ │
│  └───────────────────────────────┘ │
│  ┌───────────────────────────────┐ │
│  │ ✅ Reading               ✏️ 🗑️ │ │
│  │    30 pages daily             │ │
│  └───────────────────────────────┘ │
│  ┌───────────────────────────────┐ │
│  │ 🟣 Guitar Practice       ✏️ 🗑️ │ │
│  │    20 minutes practice        │ │
│  └───────────────────────────────┘ │
│                                     │
│                                [+]  │
└─────────────────────────────────────┘
```

### Add/Edit Hobby Screen
```
┌─────────────────────────────────────┐
│ ← Add Hobby                         │
├─────────────────────────────────────┤
│                                     │
│  Hobby Name                         │
│  ┌───────────────────────────────┐ │
│  │ Morning Meditation            │ │
│  └───────────────────────────────┘ │
│                                     │
│  Description                        │
│  ┌───────────────────────────────┐ │
│  │ 10 minutes of mindfulness     │ │
│  │                               │ │
│  │                               │ │
│  └───────────────────────────────┘ │
│                                     │
│  Color                              │
│  ┌───────────────────────────────┐ │
│  │   Tap to change color         │ │
│  │       (Blue Background)       │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │      CREATE HOBBY             │ │
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

## 🔧 Technical Features

### Data Model
```dart
class Hobby {
  String id;                    // Unique identifier
  String name;                  // "Morning Yoga"
  String description;           // "15 minutes stretching"
  int color;                    // Color.value (0xFF...)
  Map<String, bool> completions; // {"2026-01-27": true}
}
```

### Storage Strategy
- **Technology**: SharedPreferences (local key-value storage)
- **Format**: JSON serialization
- **Key**: "hobbies"
- **Persistence**: Automatic, survives app restarts

### Operations Supported
1. **Create** - Add new hobby
2. **Read** - Load all hobbies
3. **Update** - Edit hobby details
4. **Delete** - Remove hobby
5. **Toggle** - Mark day complete/incomplete

## 📊 Analytics Features

### Contribution Chart Specifications
- **Time Range**: 12 weeks (84 days)
- **Grid Layout**: 7 rows (days) × 12 columns (weeks)
- **Cell Size**: 12×12 pixels with 1px margin
- **Color Scale**: 
  - 0 completions: Light gray (#E0E0E0)
  - 1 completion: Light green (#A5D6A7)
  - 2 completions: Medium green (#66BB6A)
  - 3 completions: Dark green (#43A047)
  - 4+ completions: Darkest green (#2E7D32)

### Statistics Displayed
- Total completions per day
- Visual heatmap over time
- Month labels for context
- Day labels (M, W, F)

## 🎯 User Interactions

### Dashboard Interactions
1. **Tap hobby card** → Toggle today's completion
2. **Tap + button** → Open add hobby form
3. **Tap edit icon** → Open edit hobby form
4. **Tap delete icon** → Show confirmation dialog
5. **Scroll chart** → View historical data

### Form Interactions
1. **Tap color bar** → Open color picker
2. **Select color** → Update preview
3. **Fill fields** → Enable save button
4. **Tap save** → Create/update hobby

## 🎨 Design Principles

### Colors
- **Primary**: Indigo (#3F51B5)
- **Accent**: Various user-selected colors
- **Success**: Green shades for contribution chart
- **Error**: Red for delete actions
- **Background**: White/Light gray

### Typography
- **Title**: 20px, Bold
- **Body**: 16px, Regular
- **Caption**: 14px, Regular
- **Small**: 10-12px for labels

### Spacing
- **Screen padding**: 16px
- **Card margin**: 8px vertical, 16px horizontal
- **Button padding**: 16px vertical
- **Component spacing**: 8-16px

## 🚀 Performance Considerations

### Optimizations
- Lazy loading of chart cells
- Efficient date calculations
- Minimal rebuilds with proper state management
- Local storage for instant data access

### Scalability
- Supports unlimited hobbies
- Efficient JSON serialization
- Horizontal scrolling for long time periods
- Smooth animations and transitions

## 🔐 Data Privacy
- All data stored locally on device
- No internet connection required
- No third-party analytics
- No user accounts or authentication
- Complete privacy and control

## 📱 Platform Support
- ✅ Android (API 21+)
- ✅ iOS (iOS 11+)
- ✅ Web (optional)
- ✅ Material Design 3

# 🤖 Hobbyist - AI Agents & Design Patterns

## Overview
This document outlines the architectural patterns, service layer design, and configuration strategies used in the Hobbyist app. It serves as a guide for AI agents and developers working with this codebase.

---

## 🏗️ Architecture Pattern

### **Service-Oriented Architecture**
The app follows a clean service-oriented architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────────┐
│                  UI Layer (Screens)              │
│  - Presentation logic                            │
│  - User interactions                             │
│  - StatefulWidget with setState                  │
└───────────────────┬─────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│             Service Layer (Services)             │
│  - Business logic                                │
│  - Data transformation                           │
│  - Coordination between DB and UI                │
└───────────────────┬─────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│          Data Layer (DatabaseHelper)             │
│  - SQLite operations                             │
│  - Schema management                             │
│  - Query optimization                            │
└─────────────────────────────────────────────────┘
```

---

## 📦 Service Agents

### 1. **HobbyService** (`lib/services/hobby_service.dart`)

**Role**: Primary data service managing hobby CRUD operations and completions.

**Responsibilities**:
- Load hobbies with completions
- Create new hobbies
- Update hobby details
- Delete hobbies
- Toggle completion status
- Coordinate between UI and database

**Key Methods**:
```dart
Future<List<Hobby>> loadHobbies()           // Load all hobbies with completions
Future<void> createHobby(Hobby hobby)       // Create new hobby
Future<void> updateHobby(Hobby hobby)       // Update existing hobby
Future<void> deleteHobby(String id)         // Delete hobby and completions
Future<void> toggleCompletion(String id, String date, bool completed)
```

**Pattern**: Singleton-like instance via DatabaseHelper
**Dependencies**: DatabaseHelper, Hobby model

---

### 2. **DatabaseHelper** (`lib/database/database_helper.dart`)

**Role**: Database management and abstraction layer.

**Responsibilities**:
- Initialize SQLite database
- Manage database schema
- Execute raw SQL queries
- Handle database migrations
- Enable foreign keys
- Create indexes for performance

**Key Methods**:
```dart
Future<Database> get database              // Get database instance
Future<Database> _initDB(String filePath)  // Initialize database
Future<void> _createDB(Database db, int version) // Create schema
```

**Pattern**: Singleton (static instance)
**Database File**: `hobbyist.db`
**Version**: 1

**Schema Components**:
1. **hobbies** table - Main hobby data
2. **completions** table - Completion records with CASCADE delete
3. **settings** table - User preferences and configuration
4. **Indexes** - Performance optimization on key columns

---

### 3. **QuoteService** (`lib/services/quote_service.dart`)

**Role**: Motivational quote provider.

**Responsibilities**:
- Store collection of motivational quotes
- Provide random quotes
- Support UI motivation features

**Pattern**: Stateless utility service
**Data**: Hardcoded quote collection

---

### 4. **SoundService** (`lib/services/sound_service.dart`)

**Role**: Audio feedback manager.

**Responsibilities**:
- Play completion sound effects
- Manage audio player lifecycle
- Handle audio settings

**Pattern**: Singleton instance
**Dependencies**: audioplayers package
**Asset**: `assets/sounds/completion.wav`

---

## 🎯 Data Models

### **Hobby Model** (`lib/models/hobby.dart`)

**Core Domain Entity**

```dart
class Hobby {
  final String id;              // UUID
  final String name;            // Hobby name
  final String notes;           // Description
  final String repeatMode;      // daily, weekly, custom
  final String priority;        // low, medium, high
  final int color;              // Color code (0xFFRRGGBB)
  final Map<String, HobbyCompletion> completions;
  final DateTime? createdAt;
}
```

**Computed Properties**:
- `currentStreak` - Calculate consecutive completion days
- `completionRate(days)` - Calculate completion percentage
- `lastCompletedDate` - Get most recent completion

**Nested Class**:
```dart
class HobbyCompletion {
  final bool completed;
  final DateTime? completedAt;
}
```

**Serialization**: Database row mapping (no JSON)

---

## 🗄️ Database Schema

### **Tables**

#### 1. hobbies
```sql
CREATE TABLE hobbies (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  notes TEXT,
  repeat_mode TEXT NOT NULL DEFAULT 'daily',
  priority TEXT NOT NULL DEFAULT 'medium',
  color INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
```

**Indexes**:
- `idx_hobbies_created_at` on created_at
- `idx_hobbies_priority` on priority

#### 2. completions
```sql
CREATE TABLE completions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  hobby_id TEXT NOT NULL,
  date TEXT NOT NULL,  -- YYYY-MM-DD format
  completed INTEGER NOT NULL DEFAULT 0,
  completed_at INTEGER,
  FOREIGN KEY (hobby_id) REFERENCES hobbies (id) ON DELETE CASCADE,
  UNIQUE(hobby_id, date)
)
```

**Indexes**:
- `idx_completions_hobby_id` on hobby_id
- `idx_completions_date` on date
- `idx_completions_completed` on completed
- `idx_completions_hobby_date` on (hobby_id, date) -- Composite

**Constraints**:
- UNIQUE(hobby_id, date) - Prevents duplicate completions
- ON DELETE CASCADE - Auto-cleanup on hobby deletion

#### 3. settings
```sql
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at INTEGER NOT NULL
)
```

**Default Settings**:
- `user_name` = 'Tham'
- `push_notifications` = 'true'
- `completion_sound` = 'true'
- `has_seen_landing` = 'false'

---

## 🎨 UI Patterns

### **State Management**
- **Primary**: StatefulWidget with setState()
- **Scope**: Local component state
- **Rebuilds**: Targeted with minimal widget rebuilds

### **Screen Navigation**
- **Router**: MaterialApp with named routes
- **Flow**: Splash → Landing → Name Input → Daily Tasks
- **Pattern**: Linear onboarding, then main dashboard

### **Screen Components**:
1. **SplashScreen** - Branding and initialization
2. **LandingScreen** - Onboarding welcome
3. **NameInputScreen** - User setup
4. **DailyTasksScreen** - Main dashboard with contribution chart
5. **AddHobbyScreen** - Hobby creation/editing
6. **AnalyticsScreen** - Statistics and insights
7. **SettingsScreen** - User preferences

---

## 🔧 Configuration

### **Theme Configuration** (`lib/main.dart`)
```dart
ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFF6C3FFF),          // Purple
  scaffoldBackgroundColor: Color(0xFF1A1625), // Dark purple
  cardColor: Color(0xFF2A2238),             // Card background
  useMaterial3: true,
)
```

**Color Palette**:
- Primary: #6C3FFF (Purple)
- Secondary: #8B5CF6 (Light purple)
- Background: #1A1625 (Dark purple)
- Surface: #2A2238 (Card background)

### **App Configuration** (`pubspec.yaml`)
```yaml
name: hobbyist
version: 1.0.0+1
```

**Key Dependencies**:
- `sqflite` - SQLite database
- `shared_preferences` - Simple key-value storage
- `intl` - Date formatting
- `flutter_colorpicker` - Color selection
- `path_provider` - File system paths
- `audioplayers` - Sound effects

---

## 🔄 Data Flow Patterns

### **Read Flow** (Loading Hobbies)
```
UI Screen
  └─> HobbyService.loadHobbies()
      └─> DatabaseHelper.database
          └─> db.query('hobbies')
          └─> db.query('completions')
          └─> Build Hobby objects with completions map
      └─> Return List<Hobby>
  └─> setState() to update UI
```

### **Write Flow** (Toggle Completion)
```
UI (Tap on hobby)
  └─> HobbyService.toggleCompletion(id, date, completed)
      └─> db.insert/update 'completions' table
      └─> Update completed_at timestamp
  └─> Reload hobbies
  └─> setState() to update UI
  └─> Play sound effect (SoundService)
```

### **Create Flow** (New Hobby)
```
AddHobbyScreen form
  └─> Validate inputs
  └─> Create Hobby object with UUID
  └─> HobbyService.createHobby(hobby)
      └─> db.insert into 'hobbies' table
      └─> Set created_at, updated_at timestamps
  └─> Navigate back to dashboard
  └─> Reload hobbies list
```

---

## 🎯 Design Patterns Used

### 1. **Singleton Pattern**
- **DatabaseHelper**: Single database instance
- **SoundService**: Single audio player instance

### 2. **Repository Pattern**
- **HobbyService**: Acts as repository abstracting data source
- Hides database complexity from UI

### 3. **Factory Pattern**
- **Hobby.fromMap()**: Creates objects from database rows
- **Hobby.toMap()**: Converts objects for database storage

### 4. **Observer Pattern**
- StatefulWidget setState() notifies listeners
- UI rebuilds on state changes

### 5. **Strategy Pattern**
- Different repeat modes (daily, weekly, custom)
- Priority levels (low, medium, high)

---

## 🚀 Performance Optimizations

### **Database Level**:
1. **Indexes** on frequently queried columns
2. **Composite indexes** for multi-column queries
3. **Foreign keys** with CASCADE for automatic cleanup
4. **UNIQUE constraints** prevent duplicates
5. **Batch operations** where possible

### **Application Level**:
1. **Lazy loading** - Load only visible data
2. **Const constructors** - Reduce widget rebuilds
3. **ListView.builder** - Efficient list rendering
4. **SingleChildScrollView** - Smooth scrolling
5. **Async/await** - Non-blocking operations

### **Memory Management**:
1. **Singleton services** - Single instance reuse
2. **Database connection pooling** via sqflite
3. **Efficient date formatting** - Cached patterns

---

## 🔐 Security & Privacy

### **Data Storage**:
- ✅ All data stored locally in SQLite
- ✅ No cloud sync or external API calls
- ✅ Encrypted at OS level (Android/iOS)
- ✅ Deleted on app uninstall
- ✅ No PII collection

### **Best Practices**:
- ✅ Foreign key constraints for referential integrity
- ✅ ACID compliance via SQLite transactions
- ✅ Input validation on forms
- ✅ Safe date parsing with error handling

---

## 🧪 Testing Strategy

### **Unit Testing**:
- Service layer methods
- Data model serialization
- Business logic (streak calculation, completion rate)

### **Widget Testing**:
- Screen rendering
- User interactions
- Navigation flow

### **Integration Testing**:
- End-to-end user flows
- Database operations
- State persistence

**Test Files**: Located in `test/` directory

---

## 📝 AI Agent Guidelines

When working with this codebase, AI agents should:

### **1. Understand the Service Layer**
- All data operations go through `HobbyService`
- Never bypass service layer to access database directly from UI
- Use async/await for all database operations

### **2. Respect the Schema**
- Dates are stored as TEXT in YYYY-MM-DD format
- Timestamps are INTEGER (milliseconds since epoch)
- Boolean values are INTEGER (0 or 1)
- Maintain foreign key relationships

### **3. Follow State Management**
- Use setState() for local state updates
- Reload data after mutations
- Handle loading states with CircularProgressIndicator

### **4. Maintain UI Consistency**
- Follow Material Design 3 guidelines
- Use theme colors from main.dart
- Keep dark theme consistency
- Add proper error handling and user feedback

### **5. Handle Edge Cases**
- Empty states (no hobbies)
- First-time user experience
- Date boundary conditions
- Network/storage errors

### **6. Performance Considerations**
- Use indexes when adding new queries
- Avoid N+1 query problems
- Batch database operations when possible
- Use const constructors for static widgets

### **7. Code Organization**
```
lib/
├── main.dart              # App entry and theme
├── models/                # Data models only
├── services/              # Business logic and data access
├── database/              # Database schema and queries
├── screens/               # UI screens (presentation)
├── widgets/               # Reusable UI components
└── utils/                 # Helper functions
```

---

## 🔄 Migration & Versioning

### **Database Migrations**:
Currently at version 1. Future versions should:
1. Increment version number in DatabaseHelper
2. Add migration logic in `onUpgrade` callback
3. Preserve existing data
4. Update schema documentation

### **Example Migration Pattern**:
```dart
Future<Database> _initDB(String filePath) async {
  return await openDatabase(
    dbPath,
    version: 2,  // Increment version
    onCreate: _createDB,
    onUpgrade: _onUpgrade,  // Handle migration
  );
}

Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    // Add new column or table
    await db.execute('ALTER TABLE hobbies ADD COLUMN new_field TEXT');
  }
}
```

---

## 📊 Analytics & Metrics

### **Computed Metrics**:
1. **Current Streak** - Consecutive days completed
2. **Completion Rate** - Percentage over time period
3. **Total Completions** - Lifetime count
4. **Last Completed** - Most recent completion date

### **Chart Visualization**:
- GitHub-style contribution chart
- 12-week rolling window
- 5 intensity levels (0-4 completions per day)
- Month and day labels

---

## 🎓 Learning Resources

### **Key Concepts Demonstrated**:
1. Flutter app architecture
2. SQLite database design
3. CRUD operations with foreign keys
4. State management with setState
5. Material Design 3 theming
6. Date/time manipulation
7. Custom widget development
8. Service layer pattern

### **Recommended Reading**:
- [sqflite documentation](https://pub.dev/packages/sqflite)
- [Flutter state management](https://flutter.dev/docs/development/data-and-backend/state-mgmt)
- [Material Design 3](https://m3.material.io/)
- [Database normalization](https://en.wikipedia.org/wiki/Database_normalization)

---

## 🚀 Future Enhancements

### **Potential Agents to Add**:

1. **NotificationService**
   - Schedule daily reminders
   - Smart notification timing
   - Streak alerts

2. **SyncService**
   - Cloud backup (Firebase/Supabase)
   - Multi-device sync
   - Conflict resolution

3. **AnalyticsService**
   - Advanced statistics
   - Trend analysis
   - Goal tracking

4. **ExportService**
   - CSV export
   - JSON backup
   - Data import

5. **ThemeService**
   - Multiple theme options
   - Custom color schemes
   - Light/dark mode toggle

---

## 📞 Contact & Contribution

This project is open for contributions. When adding features:

1. ✅ Maintain existing patterns
2. ✅ Add appropriate tests
3. ✅ Update this documentation
4. ✅ Follow Flutter/Dart style guide
5. ✅ Use meaningful commit messages

---

## 📄 Summary

**Architecture**: Service-Oriented with clean separation
**Database**: SQLite with normalized schema and indexes
**State Management**: StatefulWidget with setState
**UI Framework**: Flutter with Material Design 3
**Data Flow**: UI → Service → Database → Service → UI
**Key Services**: HobbyService, DatabaseHelper, QuoteService, SoundService
**Models**: Hobby with nested HobbyCompletion
**Storage**: Local SQLite (hobbyist.db)
**Privacy**: 100% local, no external communication

---

*Last Updated: January 2026*
*App Version: 1.0.0+1*
*Database Version: 1*

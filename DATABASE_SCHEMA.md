# 🗄️ **Hobbyist App - SQLite Database Structure**

## **Database Information**
- **Database Name:** `hobbyist.db`
- **Location (Android):** `/data/data/com.example.hobby_tracker/app_flutter/hobbyist.db`
- **ORM:** sqflite (Flutter SQLite plugin)
- **Version:** 1
- **Foreign Keys:** Enabled

---

## **📊 Database Schema**

### **1. HOBBIES Table**
Stores all hobby/task information.

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

**Columns:**
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | TEXT | PRIMARY KEY | Unique identifier (UUID) |
| `name` | TEXT | NOT NULL | Task/hobby name |
| `notes` | TEXT | - | Optional description |
| `repeat_mode` | TEXT | NOT NULL, DEFAULT 'daily' | Frequency (daily/weekly/custom) |
| `priority` | TEXT | NOT NULL, DEFAULT 'medium' | Priority level (low/medium/high) |
| `color` | INTEGER | NOT NULL | Color code for UI |
| `created_at` | INTEGER | NOT NULL | Unix timestamp (milliseconds) |
| `updated_at` | INTEGER | NOT NULL | Unix timestamp (milliseconds) |

**Indexes:**
- `idx_hobbies_created_at` on `created_at`
- `idx_hobbies_priority` on `priority`

---

### **2. COMPLETIONS Table**
Stores completion records for each hobby.

```sql
CREATE TABLE completions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  hobby_id TEXT NOT NULL,
  date TEXT NOT NULL,
  completed INTEGER NOT NULL DEFAULT 0,
  completed_at INTEGER,
  FOREIGN KEY (hobby_id) REFERENCES hobbies (id) ON DELETE CASCADE,
  UNIQUE(hobby_id, date)
)
```

**Columns:**
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Auto-increment ID |
| `hobby_id` | TEXT | NOT NULL, FOREIGN KEY | References hobbies.id |
| `date` | TEXT | NOT NULL | Date in YYYY-MM-DD format |
| `completed` | INTEGER | NOT NULL, DEFAULT 0 | 0 = incomplete, 1 = complete |
| `completed_at` | INTEGER | - | Unix timestamp when completed |

**Constraints:**
- UNIQUE constraint on `(hobby_id, date)` - prevents duplicate entries
- ON DELETE CASCADE - automatically deletes completions when hobby is deleted

**Indexes:**
- `idx_completions_hobby_id` on `hobby_id`
- `idx_completions_date` on `date`
- `idx_completions_completed` on `completed`
- `idx_completions_hobby_date` on `(hobby_id, date)` (composite)

---

### **3. SETTINGS Table**
Stores app configuration and user preferences.

```sql
CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at INTEGER NOT NULL
)
```

**Columns:**
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `key` | TEXT | PRIMARY KEY | Setting identifier |
| `value` | TEXT | NOT NULL | Setting value (stored as string) |
| `updated_at` | INTEGER | NOT NULL | Unix timestamp (milliseconds) |

**Default Settings:**
| Key | Default Value | Description |
|-----|---------------|-------------|
| `user_name` | 'Tham' | User's display name |
| `push_notifications` | 'true' | Push notification preference |
| `completion_sound` | 'true' | Sound on task completion |
| `has_seen_landing` | 'false' | First-time onboarding flag |

---

## **🔗 Relationships**

```
hobbies (1) ──< completions (many)
  └─ ON DELETE CASCADE
```

- One hobby can have many completions
- Deleting a hobby automatically deletes all its completions

---

## **🚀 Performance Optimizations**

### **Indexed Columns:**
1. **hobbies.created_at** - Fast sorting by creation date
2. **hobbies.priority** - Quick filtering by priority
3. **completions.hobby_id** - Fast lookup of hobby's completions
4. **completions.date** - Quick date-based queries
5. **completions.completed** - Efficient filtering by completion status
6. **completions.(hobby_id, date)** - Composite index for common queries

### **Foreign Key Optimization:**
- Cascade deletes reduce need for manual cleanup
- Automatic referential integrity

---

## **💾 Storage Size**

**Estimated per record:**
- Hobby: ~200 bytes
- Completion: ~100 bytes
- Setting: ~50 bytes

**Example with 10 hobbies and 7 days history:**
- 10 hobbies × 200 bytes = 2 KB
- 70 completions × 100 bytes = 7 KB
- 4 settings × 50 bytes = 0.2 KB
- **Total: ~10 KB** (extremely lightweight!)

---

## **🔍 Common Queries**

### Get all hobbies with completions:
```sql
SELECT * FROM hobbies
ORDER BY created_at DESC
```

### Get today's tasks:
```sql
SELECT h.*, c.completed 
FROM hobbies h
LEFT JOIN completions c ON h.id = c.hobby_id AND c.date = '2026-01-27'
ORDER BY h.priority, h.name
```

### Get completion rate for a date range:
```sql
SELECT 
  COUNT(*) as total,
  SUM(completed) as completed
FROM completions
WHERE date BETWEEN '2026-01-21' AND '2026-01-27'
```

### Get streak for a hobby:
```sql
SELECT date, completed
FROM completions
WHERE hobby_id = 'hobby123'
ORDER BY date DESC
```

---

## **🛠️ Database Tools**

### Access database on Android:
```bash
adb shell
run-as com.example.hobby_tracker
cd app_flutter
sqlite3 hobbyist.db
```

### View schema:
```sql
.schema
```

### List all tables:
```sql
.tables
```

### View data:
```sql
SELECT * FROM hobbies;
SELECT * FROM completions;
SELECT * FROM settings;
```

---

## **🔄 Migration from SharedPreferences**

The app now uses SQLite instead of SharedPreferences, providing:
- ✅ **Better performance** with indexed queries
- ✅ **Relational data** with foreign keys
- ✅ **ACID compliance** for data integrity
- ✅ **Complex queries** with SQL
- ✅ **Scalability** for large datasets
- ✅ **Data normalization** reducing redundancy

**Old format:** JSON blob in SharedPreferences  
**New format:** Normalized SQLite tables with indexes

---

## **🔐 Data Privacy**

- ✅ All data stored locally in SQLite
- ✅ No cloud sync (optional feature)
- ✅ Encrypted at OS level (Android/iOS encryption)
- ✅ Deleted on app uninstall
- ✅ No external access without root/jailbreak


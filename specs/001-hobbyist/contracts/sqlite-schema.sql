-- SQLite schema contract for Hobbyist
-- Source of truth: lib/database/database_helper.dart
-- DB version: 3

PRAGMA foreign_keys = ON;

CREATE TABLE hobbies (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  notes TEXT,
  repeat_mode TEXT NOT NULL DEFAULT 'daily',
  priority TEXT NOT NULL DEFAULT 'medium',
  color INTEGER NOT NULL,
  reminder_time TEXT,
  custom_day INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE TABLE completions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  hobby_id TEXT NOT NULL,
  date TEXT NOT NULL,
  completed INTEGER NOT NULL DEFAULT 0,
  completed_at INTEGER,
  FOREIGN KEY (hobby_id) REFERENCES hobbies (id) ON DELETE CASCADE,
  UNIQUE(hobby_id, date)
);

CREATE TABLE settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX idx_hobbies_created_at ON hobbies(created_at);
CREATE INDEX idx_hobbies_priority ON hobbies(priority);

CREATE INDEX idx_completions_hobby_id ON completions(hobby_id);
CREATE INDEX idx_completions_date ON completions(date);
CREATE INDEX idx_completions_completed ON completions(completed);
CREATE INDEX idx_completions_hobby_date ON completions(hobby_id, date);

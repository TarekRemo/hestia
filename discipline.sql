PRAGMA foreign_keys = ON;

CREATE TABLE DISCIPLINE_BADGE (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  label TEXT NOT NULL,
  min_streak INTEGER NOT NULL,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  update_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE APP_USER (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  discipline_badge_id INTEGER,
  total_score INTEGER DEFAULT 0,
  mail TEXT UNIQUE NOT NULL,
  firstname TEXT NOT NULL,
  lastname TEXT NOT NULL,
  gender TEXT NOT NULL CHECK (gender IN ('male', 'female')),
  birth_date TEXT NOT NULL,
  current_discipline_streak INTEGER NOT NULL DEFAULT 0,
  max_discipline_streak INTEGER NOT NULL DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  update_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (discipline_badge_id) REFERENCES DISCIPLINE_BADGE(id)
);

CREATE TABLE ACTION_IMPORTANCE (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  label TEXT NOT NULL,
  points INTEGER NOT NULL,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  update_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ACTION (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  action_importance_id INTEGER,
  name TEXT NOT NULL,
  description TEXT,
  frequency INTEGER,
  is_positive INTEGER DEFAULT 1, -- 1=true, 0=false
  current_streak INTEGER NOT NULL DEFAULT 0,
  record_streak INTEGER NOT NULL DEFAULT 0 CHECK (record_streak >= current_streak),
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  update_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES APP_USER(id),
  FOREIGN KEY (action_importance_id) REFERENCES ACTION_IMPORTANCE(id)
);

CREATE TABLE ACTION_TIME_SLOT (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  action_id INTEGER,
  start_time TEXT NOT NULL, -- format HH:MM
  end_time TEXT NOT NULL,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  update_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (action_id) REFERENCES ACTION(id)
);

CREATE TABLE ACTION_HISTORY (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  action_id INTEGER,
  date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  -- -1 = unknown ; 0 = not done ; 1 = done
  action_status INTEGER DEFAULT -1 CHECK (action_status IN (-1, 0, 1)),
  user_comment TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  update_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (action_id) REFERENCES ACTION(id)
);

CREATE TABLE ACTION_NOTIFICATION (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  action_id INTEGER,
  title TEXT NOT NULL,
  message TEXT,
  -- 1 = motivation before ; 2 = reminder if the action is forgotten ; 3 = success ; 4 = failure
  notification_type INTEGER NOT NULL CHECK (notification_type IN (1,2,3,4)),
  FOREIGN KEY (action_id) REFERENCES ACTION(id)
);

CREATE INDEX idx_action_user ON ACTION(user_id);
CREATE INDEX idx_action_history_action ON ACTION_HISTORY(action_id);
CREATE INDEX idx_time_slot_action ON ACTION_TIME_SLOT(action_id);
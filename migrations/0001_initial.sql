PRAGMA foreign_keys = ON;

CREATE TABLE lists (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL,
  name TEXT NOT NULL,
  sort_key REAL NOT NULL,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  UNIQUE (id, owner_id)
);

CREATE TABLE todos (
  id TEXT PRIMARY KEY,
  list_id TEXT NOT NULL,
  owner_id TEXT NOT NULL,
  parent_id TEXT,
  title TEXT NOT NULL DEFAULT '',
  notes TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'Unsorted' CHECK (
    status IN (
      'Unsorted',
      'Future',
      'NowIfTime',
      'NowMustDo',
      'Underway',
      'Paused',
      'ResolveDone',
      'ResolveNo'
    )
  ),
  due_date TEXT,
  sort_key REAL NOT NULL,
  version INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  deleted_at TEXT,
  CHECK (parent_id IS NULL OR parent_id <> id),
  UNIQUE (id, list_id, owner_id),
  FOREIGN KEY (list_id, owner_id)
    REFERENCES lists(id, owner_id)
    ON DELETE CASCADE,
  FOREIGN KEY (parent_id, list_id, owner_id)
    REFERENCES todos(id, list_id, owner_id)
    ON DELETE CASCADE
);

CREATE INDEX lists_by_owner
  ON lists(owner_id, sort_key);

CREATE INDEX todos_tree
  ON todos(owner_id, list_id, parent_id, deleted_at, sort_key);

CREATE INDEX todos_by_status
  ON todos(owner_id, status, deleted_at);

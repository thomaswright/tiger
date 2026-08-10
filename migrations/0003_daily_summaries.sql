CREATE TABLE daily_summaries (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL,
  summary_date TEXT NOT NULL CHECK (
    summary_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
  ),
  heading TEXT NOT NULL DEFAULT '',
  body TEXT NOT NULL DEFAULT '',
  version INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  UNIQUE (owner_id, summary_date)
);

CREATE INDEX daily_summaries_by_owner_and_date
  ON daily_summaries(owner_id, summary_date DESC);

ALTER TABLE lists
  ADD COLUMN is_default INTEGER NOT NULL DEFAULT 0
  CHECK (is_default IN (0, 1));

CREATE UNIQUE INDEX one_default_list_per_owner
  ON lists(owner_id)
  WHERE is_default = 1;

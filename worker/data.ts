import {
  TODO_STATUSES,
  type CreateTodoInput,
  type DeleteTodoInput,
  type DeleteTodoResponse,
  type MoveTodoInput,
  type PersonalList,
  type Todo,
  type TodoStatus,
  type UpdateTodoInput,
} from "../src/shared/domain";
import type { UserIdentity } from "../src/shared/domain";

interface ListRow {
  id: string;
  name: string;
  sort_key: number;
  is_default: number;
  created_at: string;
  updated_at: string;
}

interface TodoRow {
  id: string;
  list_id: string;
  parent_id: string | null;
  title: string;
  notes: string;
  status: TodoStatus;
  due_date: string | null;
  sort_key: number;
  version: number;
  created_at: string;
  updated_at: string;
}

export class DataError extends Error {
  readonly status: 400 | 404 | 409;

  constructor(message: string, status: 400 | 404 | 409) {
    super(message);
    this.status = status;
  }
}

const mapList = (row: ListRow): PersonalList => ({
  id: row.id,
  name: row.name,
  sortKey: row.sort_key,
  isDefault: row.is_default === 1,
  createdAt: row.created_at,
  updatedAt: row.updated_at,
});

const mapTodo = (row: TodoRow): Todo => ({
  id: row.id,
  listId: row.list_id,
  parentId: row.parent_id,
  title: row.title,
  notes: row.notes,
  status: row.status,
  dueDate: row.due_date,
  sortKey: row.sort_key,
  version: row.version,
  createdAt: row.created_at,
  updatedAt: row.updated_at,
});

const listSelect = `
  SELECT id, name, sort_key, is_default, created_at, updated_at
  FROM lists
  WHERE owner_id = ?
  ORDER BY sort_key, id
`;

const todoSelect = `
  SELECT id, list_id, parent_id, title, notes, status, due_date,
         sort_key, version, created_at, updated_at
  FROM todos
`;

export async function getLists(
  db: D1Database,
  user: UserIdentity,
): Promise<PersonalList[]> {
  let result = await db.prepare(listSelect).bind(user.id).all<ListRow>();

  if (!result.results.some((list) => list.is_default === 1)) {
    const listId = crypto.randomUUID();
    await db
      .prepare(
        `INSERT OR IGNORE INTO lists
          (id, owner_id, name, sort_key, is_default)
         VALUES (?, ?, 'Tasks', 100, 1)`,
      )
      .bind(listId, user.id)
      .run();
    result = await db.prepare(listSelect).bind(user.id).all<ListRow>();
  }

  return result.results.map(mapList);
}

const assertOwnedList = async (
  db: D1Database,
  userId: string,
  listId: string,
) => {
  const list = await db
    .prepare("SELECT id FROM lists WHERE id = ? AND owner_id = ?")
    .bind(listId, userId)
    .first<{ id: string }>();

  if (!list) {
    throw new DataError("List not found", 404);
  }
};

export async function getTodos(
  db: D1Database,
  user: UserIdentity,
  listId: string,
): Promise<Todo[]> {
  await assertOwnedList(db, user.id, listId);
  const result = await db
    .prepare(
      `${todoSelect}
       WHERE owner_id = ? AND list_id = ? AND deleted_at IS NULL
       ORDER BY parent_id, sort_key, id`,
    )
    .bind(user.id, listId)
    .all<TodoRow>();

  return result.results.map(mapTodo);
}

const isTodoStatus = (value: unknown): value is TodoStatus =>
  typeof value === "string" &&
  TODO_STATUSES.some((status) => status === value);

const isUuid = (value: string) =>
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(
    value,
  );

const isNullableUuid = (value: unknown): value is string | null =>
  value === null || (typeof value === "string" && isUuid(value));

const parseVersion = (value: unknown) => {
  if (!Number.isInteger(value) || (value as number) < 1) {
    throw new DataError("Invalid todo version", 400);
  }
  return value as number;
};

export function parseCreateTodoInput(value: unknown): CreateTodoInput {
  if (!value || typeof value !== "object") {
    throw new DataError("Invalid todo", 400);
  }

  const input = value as Partial<CreateTodoInput>;
  if (typeof input.id !== "string" || !isUuid(input.id)) {
    throw new DataError("Todo id must be a UUID", 400);
  }
  if (typeof input.title !== "string" || input.title.trim().length === 0) {
    throw new DataError("Todo title is required", 400);
  }
  if (input.title.length > 1000) {
    throw new DataError("Todo title is too long", 400);
  }
  if (input.parentId !== null && typeof input.parentId !== "string") {
    throw new DataError("Invalid parent todo", 400);
  }
  if (!isTodoStatus(input.status)) {
    throw new DataError("Invalid todo status", 400);
  }

  return {
    id: input.id,
    title: input.title.trim(),
    parentId: input.parentId,
    status: input.status,
  };
}

export async function createTodo(
  db: D1Database,
  user: UserIdentity,
  listId: string,
  input: CreateTodoInput,
): Promise<Todo> {
  await assertOwnedList(db, user.id, listId);

  if (input.parentId) {
    const parent = await db
      .prepare(
        `SELECT id FROM todos
         WHERE id = ? AND list_id = ? AND owner_id = ? AND deleted_at IS NULL`,
      )
      .bind(input.parentId, listId, user.id)
      .first<{ id: string }>();

    if (!parent) {
      throw new DataError("Parent todo not found", 404);
    }
  }

  try {
    await db
      .prepare(
        `INSERT INTO todos
          (id, list_id, owner_id, parent_id, title, status, sort_key)
         VALUES (
           ?, ?, ?, ?, ?, ?,
           COALESCE((
             SELECT MAX(sort_key) + 100
             FROM todos
             WHERE owner_id = ? AND list_id = ? AND deleted_at IS NULL
               AND (parent_id = ? OR (parent_id IS NULL AND ? IS NULL))
           ), 100)
         )`,
      )
      .bind(
        input.id,
        listId,
        user.id,
        input.parentId,
        input.title,
        input.status,
        user.id,
        listId,
        input.parentId,
        input.parentId,
      )
      .run();
  } catch (error) {
    if (error instanceof Error && error.message.includes("UNIQUE")) {
      throw new DataError("Todo already exists", 409);
    }
    throw error;
  }

  const todo = await db
    .prepare(`${todoSelect} WHERE id = ? AND owner_id = ?`)
    .bind(input.id, user.id)
    .first<TodoRow>();

  if (!todo) {
    throw new Error("Created todo could not be read");
  }

  return mapTodo(todo);
}

export function parseUpdateTodoInput(value: unknown): UpdateTodoInput {
  if (!value || typeof value !== "object") {
    throw new DataError("Invalid todo update", 400);
  }

  const input = value as Partial<UpdateTodoInput>;
  const update: UpdateTodoInput = { version: parseVersion(input.version) };

  if (input.title !== undefined) {
    if (typeof input.title !== "string" || input.title.trim().length === 0) {
      throw new DataError("Todo title is required", 400);
    }
    if (input.title.length > 1000) {
      throw new DataError("Todo title is too long", 400);
    }
    update.title = input.title.trim();
  }

  if (input.status !== undefined) {
    if (!isTodoStatus(input.status)) {
      throw new DataError("Invalid todo status", 400);
    }
    update.status = input.status;
  }

  if (input.notes !== undefined) {
    if (typeof input.notes !== "string" || input.notes.length > 10000) {
      throw new DataError("Todo notes are too long", 400);
    }
    update.notes = input.notes;
  }

  if (input.dueDate !== undefined) {
    const parsedDate =
      typeof input.dueDate === "string"
        ? new Date(`${input.dueDate}T00:00:00Z`)
        : null;
    if (
      input.dueDate !== null &&
      (typeof input.dueDate !== "string" ||
        !/^\d{4}-\d{2}-\d{2}$/.test(input.dueDate) ||
        !parsedDate ||
        Number.isNaN(parsedDate.valueOf()) ||
        parsedDate.toISOString().slice(0, 10) !== input.dueDate)
    ) {
      throw new DataError("Invalid due date", 400);
    }
    update.dueDate = input.dueDate;
  }

  if (
    update.title === undefined &&
    update.status === undefined &&
    update.notes === undefined &&
    update.dueDate === undefined
  ) {
    throw new DataError("Todo update is empty", 400);
  }

  return update;
}

export function parseMoveTodoInput(value: unknown): MoveTodoInput {
  if (!value || typeof value !== "object") {
    throw new DataError("Invalid todo move", 400);
  }

  const input = value as Partial<MoveTodoInput>;
  if (!isNullableUuid(input.parentId)) {
    throw new DataError("Invalid parent todo", 400);
  }
  if (!isNullableUuid(input.previousId) || !isNullableUuid(input.nextId)) {
    throw new DataError("Invalid move neighbors", 400);
  }
  if (input.previousId && input.previousId === input.nextId) {
    throw new DataError("Move neighbors must be different", 400);
  }

  return {
    parentId: input.parentId,
    previousId: input.previousId,
    nextId: input.nextId,
    version: parseVersion(input.version),
  };
}

const getOwnedTodoRow = async (
  db: D1Database,
  userId: string,
  todoId: string,
) => {
  const todo = await db
    .prepare(
      `${todoSelect}
       WHERE id = ? AND owner_id = ? AND deleted_at IS NULL`,
    )
    .bind(todoId, userId)
    .first<TodoRow>();

  if (!todo) {
    throw new DataError("Todo not found", 404);
  }

  return todo;
};

export async function updateTodo(
  db: D1Database,
  user: UserIdentity,
  todoId: string,
  input: UpdateTodoInput,
): Promise<Todo> {
  const current = await getOwnedTodoRow(db, user.id, todoId);
  const result = await db
    .prepare(
      `UPDATE todos
       SET title = ?, status = ?, notes = ?, due_date = ?, version = version + 1,
           updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
       WHERE id = ? AND owner_id = ? AND version = ? AND deleted_at IS NULL`,
    )
    .bind(
      input.title ?? current.title,
      input.status ?? current.status,
      input.notes ?? current.notes,
      input.dueDate === undefined ? current.due_date : input.dueDate,
      todoId,
      user.id,
      input.version,
    )
    .run();

  if (result.meta.changes !== 1) {
    throw new DataError("Todo changed elsewhere; refresh and try again", 409);
  }

  return mapTodo(await getOwnedTodoRow(db, user.id, todoId));
}

export function parseDeleteTodoInput(value: unknown): DeleteTodoInput {
  if (!value || typeof value !== "object") {
    throw new DataError("Invalid todo deletion", 400);
  }
  const input = value as Partial<DeleteTodoInput>;
  if (typeof input.deletionToken !== "string" || !isUuid(input.deletionToken)) {
    throw new DataError("Invalid deletion token", 400);
  }
  return {
    deletionToken: input.deletionToken,
    version: parseVersion(input.version),
  };
}

export function parseRestoreTodosInput(value: unknown): string {
  if (!value || typeof value !== "object") {
    throw new DataError("Invalid restore request", 400);
  }
  const token = (value as { deletionToken?: unknown }).deletionToken;
  if (typeof token !== "string" || !isUuid(token)) {
    throw new DataError("Invalid deletion token", 400);
  }
  return token;
}

export async function deleteTodo(
  db: D1Database,
  user: UserIdentity,
  todoId: string,
  input: DeleteTodoInput,
): Promise<DeleteTodoResponse> {
  const current = await getOwnedTodoRow(db, user.id, todoId);
  if (current.version !== input.version) {
    throw new DataError("Todo changed elsewhere; refresh and try again", 409);
  }

  const result = await db
    .prepare(
      `WITH RECURSIVE subtree(id) AS (
         SELECT id FROM todos
         WHERE id = ? AND owner_id = ? AND version = ? AND deleted_at IS NULL
         UNION ALL
         SELECT child.id FROM todos child
         JOIN subtree parent ON child.parent_id = parent.id
         WHERE child.owner_id = ? AND child.list_id = ? AND child.deleted_at IS NULL
       )
       UPDATE todos
       SET deleted_at = ?, version = version + 1,
           updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
       WHERE id IN (SELECT id FROM subtree) AND owner_id = ?`,
    )
    .bind(
      todoId,
      user.id,
      input.version,
      user.id,
      current.list_id,
      input.deletionToken,
      user.id,
    )
    .run();

  if (result.meta.changes === 0) {
    throw new DataError("Todo changed elsewhere; refresh and try again", 409);
  }

  const deleted = await db
    .prepare(
      "SELECT id FROM todos WHERE owner_id = ? AND deleted_at = ? ORDER BY id",
    )
    .bind(user.id, input.deletionToken)
    .all<{ id: string }>();
  return {
    deletedIds: deleted.results.map((row) => row.id),
    deletionToken: input.deletionToken,
  };
}

export async function restoreTodos(
  db: D1Database,
  user: UserIdentity,
  deletionToken: string,
): Promise<Todo[]> {
  const deleted = await db
    .prepare(
      `SELECT id FROM todos WHERE owner_id = ? AND deleted_at = ? ORDER BY id`,
    )
    .bind(user.id, deletionToken)
    .all<{ id: string }>();
  if (deleted.results.length === 0) {
    throw new DataError("Deleted todos not found", 404);
  }

  await db
    .prepare(
      `UPDATE todos
       SET deleted_at = NULL, version = version + 1,
           updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
       WHERE owner_id = ? AND deleted_at = ?`,
    )
    .bind(user.id, deletionToken)
    .run();

  const restored = await db
    .prepare(
      `${todoSelect}
       WHERE owner_id = ? AND id IN (SELECT value FROM json_each(?))`,
    )
    .bind(user.id, JSON.stringify(deleted.results.map((row) => row.id)))
    .all<TodoRow>();

  return restored.results.map(mapTodo);
}

const getDestinationSibling = async (
  db: D1Database,
  userId: string,
  listId: string,
  parentId: string | null,
  siblingId: string,
) => {
  const sibling = await db
    .prepare(
      `SELECT id, sort_key FROM todos
       WHERE id = ? AND owner_id = ? AND list_id = ? AND deleted_at IS NULL
         AND (parent_id = ? OR (parent_id IS NULL AND ? IS NULL))`,
    )
    .bind(siblingId, userId, listId, parentId, parentId)
    .first<{ id: string; sort_key: number }>();

  if (!sibling) {
    throw new DataError("Move neighbor not found", 400);
  }

  return sibling;
};

export async function moveTodo(
  db: D1Database,
  user: UserIdentity,
  todoId: string,
  input: MoveTodoInput,
): Promise<Todo> {
  const current = await getOwnedTodoRow(db, user.id, todoId);

  if (input.previousId === todoId || input.nextId === todoId) {
    throw new DataError("A todo cannot be its own move neighbor", 400);
  }

  if (input.parentId) {
    const invalidParent = await db
      .prepare(
        `WITH RECURSIVE descendants(id) AS (
           SELECT id FROM todos
           WHERE id = ? AND owner_id = ? AND list_id = ? AND deleted_at IS NULL
           UNION ALL
           SELECT child.id FROM todos child
           JOIN descendants parent ON child.parent_id = parent.id
           WHERE child.owner_id = ? AND child.list_id = ?
             AND child.deleted_at IS NULL
         )
         SELECT id FROM descendants WHERE id = ? LIMIT 1`,
      )
      .bind(
        todoId,
        user.id,
        current.list_id,
        user.id,
        current.list_id,
        input.parentId,
      )
      .first<{ id: string }>();

    if (invalidParent) {
      throw new DataError("A todo cannot be moved into itself or a descendant", 400);
    }

    const parent = await getOwnedTodoRow(db, user.id, input.parentId);
    if (parent.list_id !== current.list_id) {
      throw new DataError("Destination parent belongs to another list", 400);
    }
  }

  const previous = input.previousId
    ? await getDestinationSibling(
        db,
        user.id,
        current.list_id,
        input.parentId,
        input.previousId,
      )
    : null;
  const next = input.nextId
    ? await getDestinationSibling(
        db,
        user.id,
        current.list_id,
        input.parentId,
        input.nextId,
      )
    : null;

  if (previous && next && previous.sort_key >= next.sort_key) {
    throw new DataError("Move neighbors are out of order", 400);
  }

  const interveningCondition = previous
    ? next
      ? "sort_key > ? AND sort_key < ?"
      : "sort_key > ?"
    : next
      ? "sort_key < ?"
      : null;
  if (interveningCondition) {
    const positionValues = previous
      ? next
        ? [previous.sort_key, next.sort_key]
        : [previous.sort_key]
      : [next!.sort_key];
    const intervening = await db
      .prepare(
        `SELECT COUNT(*) AS count FROM todos
         WHERE owner_id = ? AND list_id = ? AND deleted_at IS NULL
           AND id <> ?
           AND (parent_id = ? OR (parent_id IS NULL AND ? IS NULL))
           AND ${interveningCondition}`,
      )
      .bind(
        user.id,
        current.list_id,
        todoId,
        input.parentId,
        input.parentId,
        ...positionValues,
      )
      .first<{ count: number }>();

    if ((intervening?.count ?? 0) > 0) {
      throw new DataError("Move neighbors are not adjacent", 400);
    }
  }

  let sortKey: number;
  if (previous && next) {
    sortKey = (previous.sort_key + next.sort_key) / 2;
  } else if (previous) {
    sortKey = previous.sort_key + 100;
  } else if (next) {
    sortKey = next.sort_key - 100;
  } else {
    const last = await db
      .prepare(
        `SELECT MAX(sort_key) AS sort_key FROM todos
         WHERE owner_id = ? AND list_id = ? AND deleted_at IS NULL
           AND id <> ?
           AND (parent_id = ? OR (parent_id IS NULL AND ? IS NULL))`,
      )
      .bind(user.id, current.list_id, todoId, input.parentId, input.parentId)
      .first<{ sort_key: number | null }>();
    sortKey = (last?.sort_key ?? 0) + 100;
  }

  const result = await db
    .prepare(
      `UPDATE todos
       SET parent_id = ?, sort_key = ?, version = version + 1,
           updated_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
       WHERE id = ? AND owner_id = ? AND version = ? AND deleted_at IS NULL`,
    )
    .bind(input.parentId, sortKey, todoId, user.id, input.version)
    .run();

  if (result.meta.changes !== 1) {
    throw new DataError("Todo changed elsewhere; refresh and try again", 409);
  }

  return mapTodo(await getOwnedTodoRow(db, user.id, todoId));
}

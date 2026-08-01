import {
  TODO_STATUSES,
  type CreateTodoInput,
  type PersonalList,
  type Todo,
  type TodoStatus,
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

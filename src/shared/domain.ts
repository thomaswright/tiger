export const TODO_STATUSES = [
  "Unsorted",
  "Future",
  "NowIfTime",
  "NowMustDo",
  "Underway",
  "Paused",
  "ResolveDone",
  "ResolveNo",
] as const;

export type TodoStatus = (typeof TODO_STATUSES)[number];

export interface UserIdentity {
  id: string;
  email: string;
}

export interface PersonalList {
  id: string;
  name: string;
  sortKey: number;
  isDefault: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface Todo {
  id: string;
  listId: string;
  parentId: string | null;
  title: string;
  notes: string;
  status: TodoStatus;
  dueDate: string | null;
  sortKey: number;
  version: number;
  createdAt: string;
  updatedAt: string;
}

export interface MeResponse {
  user: UserIdentity;
}

export interface ListsResponse {
  lists: PersonalList[];
}

export interface TodosResponse {
  todos: Todo[];
}

export interface CreateTodoInput {
  id: string;
  title: string;
  parentId: string | null;
  status: TodoStatus;
}

export interface ApiErrorResponse {
  error: string;
}

export interface HealthResponse {
  status: "ok" | "degraded";
  database: "ready" | "migration-required";
}

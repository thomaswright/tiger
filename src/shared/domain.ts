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

export interface DailySummary {
  id: string;
  date: string;
  body: string;
  version: number;
  createdAt: string;
  updatedAt: string;
}

export interface DailySummariesResponse {
  dailySummaries: DailySummary[];
}

export interface CreateDailySummaryInput {
  id: string;
  date: string;
  body: string;
}

export interface UpdateDailySummaryInput {
  body: string;
  version: number;
}

export interface CreateTodoInput {
  id: string;
  title: string;
  parentId: string | null;
  previousId: string | null;
  nextId: string | null;
  status: TodoStatus;
}

export interface UpdateTodoInput {
  title?: string;
  status?: TodoStatus;
  notes?: string;
  dueDate?: string | null;
  version: number;
}

export interface MoveTodoInput {
  parentId: string | null;
  previousId: string | null;
  nextId: string | null;
  version: number;
}

export interface DeleteTodoInput {
  deletionToken: string;
  version: number;
}

export interface DeleteTodoResponse {
  deletedIds: string[];
  deletionToken: string;
}

export interface RestoreTodosResponse {
  todos: Todo[];
}

export interface ApiErrorResponse {
  error: string;
}

export interface HealthResponse {
  status: "ok" | "degraded";
  database: "ready" | "migration-required";
}

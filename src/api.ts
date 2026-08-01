import type {
  ApiErrorResponse,
  CreateTodoInput,
  DeleteTodoInput,
  DeleteTodoResponse,
  ListsResponse,
  MeResponse,
  MoveTodoInput,
  Todo,
  TodosResponse,
  UpdateTodoInput,
  RestoreTodosResponse,
} from "./shared/domain";

export class ApiError extends Error {
  readonly status: number;

  constructor(message: string, status: number) {
    super(message);
    this.status = status;
  }
}

async function requestJson<T extends object>(
  url: string,
  init?: RequestInit,
): Promise<T> {
  const response = await fetch(url, init);
  const body = (await response.json()) as T | ApiErrorResponse;

  if (!response.ok) {
    const message = "error" in body ? body.error : "Request failed";
    throw new ApiError(message, response.status);
  }

  return body as T;
}

export const getMe = () => requestJson<MeResponse>("/api/me");

export const getLists = () => requestJson<ListsResponse>("/api/lists");

export const getTodos = (listId: string) =>
  requestJson<TodosResponse>(
    `/api/lists/${encodeURIComponent(listId)}/todos`,
  );

export const createTodo = (listId: string, input: CreateTodoInput) =>
  requestJson<Todo>(`/api/lists/${encodeURIComponent(listId)}/todos`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(input),
  });

export const updateTodo = (todoId: string, input: UpdateTodoInput) =>
  requestJson<Todo>(`/api/todos/${encodeURIComponent(todoId)}`, {
    method: "PATCH",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(input),
  });

export const moveTodo = (todoId: string, input: MoveTodoInput) =>
  requestJson<Todo>(`/api/todos/${encodeURIComponent(todoId)}/move`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(input),
  });

export const deleteTodo = (todoId: string, input: DeleteTodoInput) =>
  requestJson<DeleteTodoResponse>(`/api/todos/${encodeURIComponent(todoId)}`, {
    method: "DELETE",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(input),
  });

export const restoreTodos = (deletionToken: string) =>
  requestJson<RestoreTodosResponse>("/api/todos/restore", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ deletionToken }),
  });

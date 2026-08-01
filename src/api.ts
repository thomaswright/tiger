import type {
  ApiErrorResponse,
  CreateTodoInput,
  ListsResponse,
  MeResponse,
  Todo,
  TodosResponse,
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

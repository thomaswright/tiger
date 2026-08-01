import type {
  ApiErrorResponse,
  HealthResponse,
  ListsResponse,
  MeResponse,
  Todo,
  TodosResponse,
} from "../src/shared/domain";
import { authenticate, AuthError, type AuthEnv } from "./auth";
import {
  createTodo,
  DataError,
  getLists,
  getTodos,
  moveTodo,
  parseCreateTodoInput,
  parseMoveTodoInput,
  parseUpdateTodoInput,
  updateTodo,
} from "./data";

interface Env extends AuthEnv {
  DB: D1Database;
}

type JsonBody =
  | ApiErrorResponse
  | HealthResponse
  | ListsResponse
  | MeResponse
  | Todo
  | TodosResponse;

const json = (body: JsonBody, status = 200) =>
  Response.json(body, {
    status,
    headers: {
      "cache-control": "no-store",
    },
  });

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "GET" && url.pathname === "/api/health") {
      const todosTable = await env.DB.prepare(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'todos'",
      ).first<{ name: string }>();

      if (!todosTable) {
        return json(
          { status: "degraded", database: "migration-required" },
          503,
        );
      }

      return json({ status: "ok", database: "ready" });
    }

    if (!url.pathname.startsWith("/api/")) {
      return new Response(null, { status: 404 });
    }

    try {
      const user = await authenticate(request, env);

      if (request.method === "GET" && url.pathname === "/api/me") {
        return json({ user });
      }

      if (request.method === "GET" && url.pathname === "/api/lists") {
        return json({ lists: await getLists(env.DB, user) });
      }

      const todosMatch = url.pathname.match(
        /^\/api\/lists\/([^/]+)\/todos$/,
      );
      if (todosMatch) {
        const listId = decodeURIComponent(todosMatch[1]);

        if (request.method === "GET") {
          return json({ todos: await getTodos(env.DB, user, listId) });
        }

        if (request.method === "POST") {
          let body: unknown;
          try {
            body = await request.json();
          } catch {
            throw new DataError("Request body must be JSON", 400);
          }

          const todo = await createTodo(
            env.DB,
            user,
            listId,
            parseCreateTodoInput(body),
          );
          return json(todo, 201);
        }
      }

      const todoMatch = url.pathname.match(/^\/api\/todos\/([^/]+)$/);
      if (todoMatch && request.method === "PATCH") {
        const todoId = decodeURIComponent(todoMatch[1]);
        let body: unknown;
        try {
          body = await request.json();
        } catch {
          throw new DataError("Request body must be JSON", 400);
        }

        return json(
          await updateTodo(
            env.DB,
            user,
            todoId,
            parseUpdateTodoInput(body),
          ),
        );
      }

      const moveMatch = url.pathname.match(/^\/api\/todos\/([^/]+)\/move$/);
      if (moveMatch && request.method === "POST") {
        const todoId = decodeURIComponent(moveMatch[1]);
        let body: unknown;
        try {
          body = await request.json();
        } catch {
          throw new DataError("Request body must be JSON", 400);
        }

        return json(
          await moveTodo(
            env.DB,
            user,
            todoId,
            parseMoveTodoInput(body),
          ),
        );
      }

      return json({ error: "Not found" }, 404);
    } catch (error) {
      if (error instanceof AuthError || error instanceof DataError) {
        return json({ error: error.message }, error.status);
      }

      console.error("Unhandled API error", error);
      return json({ error: "Internal server error" }, 500);
    }
  },
} satisfies ExportedHandler<Env>;

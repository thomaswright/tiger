import type {
  ApiErrorResponse,
  DailySummariesResponse,
  DailySummary,
  HealthResponse,
  ListsResponse,
  MeResponse,
  Todo,
  TodosResponse,
} from "../src/shared/domain";
import { authenticate, AuthError, type AuthEnv } from "./auth";
import {
  createDailySummary,
  createTodo,
  deleteTodo,
  DataError,
  getDailySummaries,
  getLists,
  getTodos,
  moveTodo,
  parseCreateDailySummaryInput,
  parseCreateTodoInput,
  parseDeleteTodoInput,
  parseRestoreTodosInput,
  parseMoveTodoInput,
  parseUpdateDailySummaryInput,
  parseUpdateTodoInput,
  restoreTodos,
  updateDailySummary,
  updateTodo,
} from "./data";

interface Env extends AuthEnv {
  DB: D1Database;
}

type JsonBody =
  | ApiErrorResponse
  | DailySummariesResponse
  | DailySummary
  | HealthResponse
  | ListsResponse
  | MeResponse
  | Todo
  | TodosResponse
  | { deletedIds: string[]; deletionToken: string };

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
      const requiredTables = await env.DB.prepare(
        `SELECT COUNT(*) AS count FROM sqlite_master
         WHERE type = 'table' AND name IN ('todos', 'daily_summaries')`,
      ).first<{ count: number }>();

      if (requiredTables?.count !== 2) {
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

      if (url.pathname === "/api/daily-summaries") {
        if (request.method === "GET") {
          return json({
            dailySummaries: await getDailySummaries(env.DB, user),
          });
        }

        if (request.method === "POST") {
          let body: unknown;
          try {
            body = await request.json();
          } catch {
            throw new DataError("Request body must be JSON", 400);
          }
          return json(
            await createDailySummary(
              env.DB,
              user,
              parseCreateDailySummaryInput(body),
            ),
            201,
          );
        }
      }

      const dailySummaryMatch = url.pathname.match(
        /^\/api\/daily-summaries\/([^/]+)$/,
      );
      if (dailySummaryMatch && request.method === "PATCH") {
        let body: unknown;
        try {
          body = await request.json();
        } catch {
          throw new DataError("Request body must be JSON", 400);
        }
        return json(
          await updateDailySummary(
            env.DB,
            user,
            decodeURIComponent(dailySummaryMatch[1]),
            parseUpdateDailySummaryInput(body),
          ),
        );
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

      if (
        request.method === "POST" &&
        url.pathname === "/api/todos/restore"
      ) {
        let body: unknown;
        try {
          body = await request.json();
        } catch {
          throw new DataError("Request body must be JSON", 400);
        }
        return json({
          todos: await restoreTodos(
            env.DB,
            user,
            parseRestoreTodosInput(body),
          ),
        });
      }

      const todoMatch = url.pathname.match(/^\/api\/todos\/([^/]+)$/);
      if (
        todoMatch &&
        (request.method === "PATCH" || request.method === "DELETE")
      ) {
        const todoId = decodeURIComponent(todoMatch[1]);
        let body: unknown;
        try {
          body = await request.json();
        } catch {
          throw new DataError("Request body must be JSON", 400);
        }

        if (request.method === "DELETE") {
          return json(
            await deleteTodo(
              env.DB,
              user,
              todoId,
              parseDeleteTodoInput(body),
            ),
          );
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

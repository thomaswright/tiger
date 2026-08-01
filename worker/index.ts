import type { HealthResponse } from "../src/shared/domain";

interface Env {
  DB: D1Database;
}

const json = (body: HealthResponse | { error: string }, status = 200) =>
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

    if (url.pathname.startsWith("/api/")) {
      return json({ error: "Not found" }, 404);
    }

    return new Response(null, { status: 404 });
  },
} satisfies ExportedHandler<Env>;

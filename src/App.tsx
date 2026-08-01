import { useEffect, useState } from "react";
import type { HealthResponse } from "./shared/domain";
import logoUrl from "./assets/tiger.svg";

type ConnectionState = "checking" | "ready" | "unavailable";

function App() {
  const [connection, setConnection] = useState<ConnectionState>("checking");

  useEffect(() => {
    const controller = new AbortController();

    fetch("/api/health", { signal: controller.signal })
      .then(async (response) => {
        if (!response.ok) {
          throw new Error(`Health check failed with ${response.status}`);
        }

        return response.json() as Promise<HealthResponse>;
      })
      .then((health) => {
        setConnection(health.status === "ok" ? "ready" : "unavailable");
      })
      .catch((error: unknown) => {
        if (error instanceof DOMException && error.name === "AbortError") {
          return;
        }

        setConnection("unavailable");
      });

    return () => controller.abort();
  }, []);

  return (
    <main className="min-h-dvh p-6 text-[var(--t10)]">
      <div className="flex items-center gap-2">
        <img src={logoUrl} width="24" alt="" />
        <h1 className="text-2xl font-bold">Tiger Todo</h1>
      </div>
      <p className="mt-4 text-sm text-[var(--t7)]">
        {connection === "checking" && "Connecting to Tiger…"}
        {connection === "ready" && "Cloudflare Worker and D1 are ready."}
        {connection === "unavailable" &&
          "Tiger could not reach its local database."}
      </p>
    </main>
  );
}

export default App;

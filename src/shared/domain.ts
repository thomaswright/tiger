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

export interface HealthResponse {
  status: "ok" | "degraded";
  database: "ready" | "migration-required";
}

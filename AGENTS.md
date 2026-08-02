# Tiger project guide

This file is the handoff for future Codex work in this repository. Read it before
changing the application, then inspect the relevant code rather than assuming
this document is perfectly current.

## Product direction

Tiger is an infrequently used personal todo application. It is being rebuilt
from scratch around Cloudflare Workers, D1, and Access; there is no Supabase data
or legacy behavior to preserve. The intended product is deliberately small:

- Personal lists only. There is no collaboration or sharing model.
- Arbitrarily nested todos that can be reordered and reparented.
- No offline mode and no real-time synchronization.
- Fast, local-feeling interaction backed by optimistic mutations.
- Statuses are, in order: `Unsorted`, `Future`, `NowIfTime`, `NowMustDo`,
  `Underway`, `Paused`, `ResolveDone`, and `ResolveNo`.

Keep the small custom UI components and visual character. Functional UI may be
reshaped when needed, but do not casually replace distinctive components with
generic equivalents. In particular, `Calendar.tsx` is a deliberate recreation
of the old application's continuous multi-month calendar, including its month
outlines, rotated labels, scrolling window, and range shifters.

## Current state

The local application is functional. It has React 18, TypeScript, Vite,
Tailwind, a Cloudflare Worker API, local D1 migrations, and localhost development
authentication. ReScript and Supabase are no longer part of the application.

Production infrastructure has **not** been provisioned. The D1 `database_id` in
`wrangler.jsonc` is a placeholder, and production Access values still need to be
configured. Do not deploy, create remote resources, or modify a Cloudflare
account unless the user explicitly asks.

Some compiled files may remain under `lib/bs/` from the former ReScript app.
They are not application source and should not influence new work. Removing
stale generated artifacts is safe only after checking that the user has not put
uncommitted work there.

## Architecture map

- `src/App.tsx`: server-state queries and optimistic create/update/move/delete/
  restore mutations. The first returned list is currently the active list.
- `src/TodoTree.tsx`: recursive tree rendering, keyboard behavior, drag and drop,
  projected tree state, and reorder animation.
- `src/tree.ts`: pure tree traversal, move planning, nesting projection, and
  optimistic move application. Prefer adding tests here before changing drag or
  keyboard movement semantics.
- `src/shared/domain.ts`: types shared by the browser and Worker. Keep client,
  request parsers, and persistence aligned with this file.
- `src/api.ts`: browser API client.
- `src/Calendar.tsx`, `src/DateSelect.tsx`, `src/date.ts`: custom date UI and
  timezone-safe `YYYY-MM-DD` conversion.
- `worker/index.ts`: HTTP routing, authentication boundary, and error mapping.
- `worker/auth.ts`: localhost identity and Cloudflare Access JWT verification.
- `worker/data.ts`: request validation, ownership checks, D1 reads/writes,
  optimistic concurrency, moves, soft deletion, and restoration.
- `migrations/`: the active D1 schema history. Never edit an already-applied
  migration for a schema change; add the next numbered migration.
- `old_migrations/`: historical Supabase material only. Do not use it as the
  current schema or migrate its data.

The browser uses TanStack Query as the canonical client cache. Mutations cancel
the relevant query, update it optimistically, roll back on failure, reconcile
with the response, and invalidate afterward. Preserve this pattern so ordinary
editing never feels like round-trip CRUD. D1 remains authoritative, and todo
`version` values enforce optimistic concurrency with HTTP 409 conflicts.

Tree order is represented by `parentId` plus numeric `sortKey`. Client requests
describe placement semantically with `previousId` and `nextId`; the server
validates that those neighbors belong to the destination sibling group and are
adjacent. Do not send client-calculated sort keys to the API.

Every query and write must remain scoped to the authenticated `owner_id`. The
Worker is the security boundary: never trust owner, list, parent, neighbor,
version, status, or date values supplied by the browser without validation.

## Interaction contracts

These behaviors are intentional and have received manual browser testing:

- Dragging uses Atlassian Pragmatic Drag and Drop. Vertical position reorders;
  horizontal movement changes depth. Nesting supports grandchildren and deeper
  descendants. A todo cannot be dropped into its own subtree.
- Reordering is animated during the drag and after the drop. Projected order is
  kept local during query reconciliation to prevent flashes and faded duplicate
  rows. Be especially careful around the comments and layout measurements near
  `visualTree` in `TodoTree.tsx`.
- `Tab` at the start of a title indents; `Shift+Tab` outdents.
- At the end of a title, `ArrowDown` focuses the next visible title. At the
  beginning, `ArrowUp` focuses the previous visible title.
- `Enter` at the end creates an empty focused todo. If the current todo has
  children, the new todo is its first child; otherwise it is the next sibling.
- On an empty title, the first plain `Backspace` arms deletion and highlights
  the complete subtree light red. A second deletes it. Any other key, pointer
  action, or blur cancels the armed state.
- Deletion soft-deletes the entire subtree. Focus moves to the end of the
  previous visible title, and a ten-second Undo restores the deletion-token
  group.
- Due dates are date-only values, not timestamps. Store and transport strict
  `YYYY-MM-DD` strings so locale and timezone changes cannot shift the day.

When touching one of these areas, preserve all of the others and ask the user to
browser-test nuanced pointer or focus behavior. Automated tests should cover the
pure planning/validation logic, but they do not replace interaction testing.

## Local workflow

Use the checked-in scripts:

```sh
npm install
cp .dev.vars.example .dev.vars
npm run db:migrate:local
npm run dev
```

`.dev.vars` is local-only and must not be committed. The development identity is
accepted only on `localhost`, `127.0.0.1`, and `::1`; non-local requests must
pass a valid Cloudflare Access assertion.

Before handing off a change, run the checks appropriate to it. For ordinary
code changes, run all of these:

```sh
npm run lint
npm test
npm run build
git diff --check
```

Also inspect `git status` before editing and before finishing. The user may have
uncommitted changes; preserve them and avoid broad cleanup unrelated to the
request. Add focused tests in `src/tree.test.ts`, `src/date.test.ts`, or
`worker/data.test.ts` when changing the corresponding logic.

## Cloudflare rollout plan

The next infrastructure milestone, once the user wants remote resources, is:

1. Confirm the desired Cloudflare account, production hostname, and Access
   identity policy. This is an external-account change and requires explicit
   user authorization.
2. Create the production D1 database and put its real ID in `wrangler.jsonc`.
3. Apply `migrations/` to remote D1 and verify `/api/health` reports `ready`.
4. Create the Worker/application deployment and route the chosen hostname.
5. Put the hostname behind Cloudflare Access for the intended personal identity.
6. Configure `TEAM_DOMAIN` and `POLICY_AUD` for the Worker; do not commit secrets
   or environment-specific credentials.
7. Smoke-test Access rejection, login, default-list creation, todo CRUD, deep
   reparenting, conflict behavior, subtree delete/restore, and due dates.
8. Only after the remote path is verified, document the exact deploy and remote
   migration commands in `README.md`.

There is no Supabase migration or data import step. Start production D1 fresh.

## Likely next product work

Favor small, browser-testable increments. Before assuming priorities, check with
the user; the current likely sequence is:

1. Continue UX refinement of the todo tree, details, status controls, and custom
   date picker while everything is local.
2. Add missing test coverage around any behavior being changed.
3. Provision and validate the remote Cloudflare resources using the rollout
   above.
4. Polish production error/recovery states and deployment documentation.

Do not introduce offline caches, real-time subscriptions, collaboration, or a
large state abstraction without a new product requirement. The existing
optimistic-query approach is enough for this application and is central to its
responsive feel.

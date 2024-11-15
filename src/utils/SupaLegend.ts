import { createClient } from "@supabase/supabase-js";
import { observable, ObservablePrimitive } from "@legendapp/state";
import {
  configureSyncedSupabase,
  syncedSupabase,
} from "@legendapp/state/sync-plugins/supabase";
import { ObservablePersistLocalStorage } from "@legendapp/state/persist-plugins/local-storage";
import { v4 as uuidv4 } from "uuid";
import { Database } from "./database.types";

export const supabase = createClient<Database>(
  import.meta.env.VITE_PUBLIC_SUPABASE_URL,
  import.meta.env.VITE_PUBLIC_SUPABASE_ANON_KEY
);

const generateId = () => uuidv4();

configureSyncedSupabase({
  generateId,
});

export const uid$: ObservablePrimitive<string> = observable("");

export const todos$ = observable(
  syncedSupabase({
    supabase,
    collection: "todos",
    select: (from) => {
      return from
        .select(
          `id,
           counter,
           text,
           created_at,
           updated_at,
           deleted,
           user_id,
           position,
           parent_todo,
           target_date,
           additional_text,
           status,
           modes_shown,
           mode`
        )
        .eq("user_id", uid$.get())
        .eq("deleted", false);
    },
    actions: ["read", "create", "update", "delete"],
    realtime: true,
    // Persist data and pending changes locally
    persist: {
      plugin: ObservablePersistLocalStorage,
      name: "todos",
      retrySync: true, // Persist pending changes and retry
    },
    retry: {
      infinite: true, // Retry changes with exponential backoff
    },
    changesSince: "last-sync",
    fieldCreatedAt: "created_at",
    fieldUpdatedAt: "updated_at",
    fieldDeleted: "deleted",
  })
);

export function addTodo(
  text: string,
  parent_todo: string | null,
  position: number
) {
  const id = generateId();
  // Add keyed by id to the todos$ observable to trigger a create in Supabase

  todos$[id].assign({
    id,
    text,
    user_id: uid$.get(),
    position,
    parent_todo: parent_todo,
    mode: "Working",
    modes_shown: ["Working"],
    status: "Unsorted",
  });

  return id;
}

type status =
  | "Unsorted"
  | "Future"
  | "NowIfTime"
  | "NowMustDo"
  | "Underway"
  | "Paused"
  | "ResolveDone"
  | "ResolveNo"
  | "ArchiveDone"
  | "ArchiveNo"
  | undefined;

export function addTodoByImport(
  id: string,
  text: string,
  parent_todo: string | null,
  position: number,
  status: status
) {
  // const id = generateId();
  // Add keyed by id to the todos$ observable to trigger a create in Supabase
  todos$[id].assign({
    id,
    text,
    user_id: uid$.get(),
    position,
    parent_todo: parent_todo,
    mode: "Working",
    modes_shown: ["Working"],
    status,
  });
}

export function deleteTodo(id: string) {
  todos$[id].delete();
}

// export function toggleDone(id: string) {
//   todos$[id].done.set((prev) => !prev);
// }

export function setTodoText(id: string, text: string) {
  todos$[id].text.set(text);
}

export function setTodoDate(id: string, date: string | null) {
  todos$[id].target_date.set(date);
}

export function setTodoAdditionalText(id: string, text: string) {
  todos$[id].additional_text.set(text);
}

// export function setTodoOutfit(
//   id: string,
//   outfit: "Todo" | "Project" | "Group"
// ) {
//   todos$[id].outfit.set(outfit);
// }

export function setTodoMode(
  id: string,
  mode: "Working" | "Archive" | "Stashed"
) {
  todos$[id].mode.set(mode);
}

export function setTodoModesShown(
  id: string,
  setter: (
    modes: ReadonlyArray<"Working" | "Archive" | "Stashed">
  ) => Array<"Working" | "Archive" | "Stashed">
) {
  todos$[id].modes_shown.set(setter);
}

// export function setTodoHidden(id: string, isHidden: boolean) {
//   todos$[id].hidden.set(isHidden);
// }

export function setTodoStatus(
  id: string,
  status:
    | "Unsorted"
    | "Future"
    | "NowIfTime"
    | "NowMustDo"
    | "Underway"
    | "Paused"
    | "ResolveDone"
    | "ResolveNo"
) {
  todos$[id].status.set(status);
}

export function setTodoPosition(
  id: string,
  newParent: string,
  newPosition: number
) {
  todos$[id].assign({
    parent_todo: Boolean(newParent) ? newParent : null,
    position: newPosition,
  });
}

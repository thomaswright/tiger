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

// this is mock placeholder because the server will complain if
// not properly formatted and i don't know the type of the
// return from from.select to put in an empty placeholder below
export const uid$: ObservablePrimitive<string> = observable(uuidv4());

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
           parent_todo,
           target_date,
           additional_text,
           order,
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
  parent_todo: string,
  setOrder: (prev: string[], id: string) => string[]
  // position: number
) {
  const id = generateId();
  todos$[parent_todo].order.set((prev) => setOrder(prev, id));

  todos$[id].assign({
    id,
    text,
    user_id: uid$.get(),
    // position,
    parent_todo: parent_todo,
    mode: "Working",
    modes_shown: ["Working"],
    status: "Unsorted",
  });

  return id;
}

export function deleteTodo(id: string, parent_todo: string) {
  todos$[id].delete();
  todos$[parent_todo].order.set((prev) => prev.filter((v) => v !== id));
}

export function setTodoText(id: string, text: string) {
  todos$[id].text.set(text);
}

export function setTodoDate(id: string, date: string | null) {
  todos$[id].target_date.set(date);
}

export function setTodoAdditionalText(id: string, text: string) {
  todos$[id].additional_text.set(text);
}

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

export function setTodoParent(id: string, newParent: string) {
  todos$[id].assign({
    parent_todo: newParent,
  });
}

export function setTodoOrder(
  id: string,
  setOrder: (prev: string[]) => string[]
) {
  todos$[id].order.set(setOrder);
}

// export function setTodoPosition(
//   id: string,
//   newParent: string
//   // newPosition: number
// ) {
//   let oldParent = todos$[id].parent_todo.peek();
//   if (oldParent !== null) {
//     todos$[oldParent].order.set((prev) => prev.filter((v) => v !== id));
//   }
//   todos$[newParent].order.set((prev) => [id, ...(prev ?? [])]);
//   todos$[id].assign({
//     parent_todo: newParent,
//   });
// }

// export function toggleDone(id: string) {
//   todos$[id].done.set((prev) => !prev);
// }

// export function setTodoOutfit(
//   id: string,
//   outfit: "Todo" | "Project" | "Group"
// ) {
//   todos$[id].outfit.set(outfit);
// }

// export function setTodoHidden(id: string, isHidden: boolean) {
//   todos$[id].hidden.set(isHidden);
// }

// type status =
//   | "Unsorted"
//   | "Future"
//   | "NowIfTime"
//   | "NowMustDo"
//   | "Underway"
//   | "Paused"
//   | "ResolveDone"
//   | "ResolveNo"
//   | "ArchiveDone"
//   | "ArchiveNo"
//   | undefined;

// export function addTodoByImport(
//   id: string,
//   text: string,
//   parent_todo: string | null,
//   // position: number,
//   status: status
// ) {
//   // const id = generateId();
//   // Add keyed by id to the todos$ observable to trigger a create in Supabase
//   todos$[id].assign({
//     id,
//     text,
//     user_id: uid$.get(),
//     // position,
//     parent_todo: parent_todo,
//     mode: "Working",
//     modes_shown: ["Working"],
//     status,
//   });
// }

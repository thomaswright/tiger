import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useLayoutEffect, useRef, useState } from "react";
import { TbArrowBackUp, TbPlus } from "react-icons/tb";
import {
  createTodo,
  deleteTodo,
  getLists,
  getMe,
  getTodos,
  moveTodo,
  restoreTodos,
  updateTodo,
} from "./api";
import logoUrl from "./assets/tiger.svg";
import type {
  CreateTodoInput,
  MoveTodoInput,
  Todo,
  TodosResponse,
  UpdateTodoInput,
} from "./shared/domain";
import TodoTree from "./TodoTree";
import { applyMove, getSiblings, getSubtree, type TodoSort } from "./tree";

const todoQueryKey = (listId: string) => ["todos", listId] as const;

interface UndoDeletion {
  deletionToken: string;
  todos: Todo[];
}

interface CreateTodoVariables {
  listId: string;
  input: CreateTodoInput;
  focusTitle?: boolean;
}

function App() {
  const queryClient = useQueryClient();
  const [todoSort, setTodoSort] = useState<TodoSort | null>(null);
  const focusTodoId = useRef<string | null>(null);
  const [undoDeletion, setUndoDeletion] = useState<UndoDeletion | null>(null);

  const meQuery = useQuery({ queryKey: ["me"], queryFn: getMe });
  const listsQuery = useQuery({ queryKey: ["lists"], queryFn: getLists });
  const activeList = listsQuery.data?.lists[0];
  const todosQuery = useQuery({
    queryKey: todoQueryKey(activeList?.id ?? "pending"),
    queryFn: () => getTodos(activeList!.id),
    enabled: Boolean(activeList),
  });

  const createMutation = useMutation({
    mutationFn: ({ listId, input }: CreateTodoVariables) =>
      createTodo(listId, input),
    onMutate: async ({ listId, input, focusTitle }) => {
      if (focusTitle) focusTodoId.current = input.id;
      const key = todoQueryKey(listId);
      await queryClient.cancelQueries({ queryKey: key });
      const previous = queryClient.getQueryData<TodosResponse>(key);
      const now = new Date().toISOString();
      const siblings = getSiblings(previous?.todos ?? [], input.parentId);
      const previousSibling = input.previousId
        ? siblings.find((todo) => todo.id === input.previousId)
        : null;
      const nextSibling = input.nextId
        ? siblings.find((todo) => todo.id === input.nextId)
        : null;
      const sortKey = previousSibling
        ? nextSibling
          ? (previousSibling.sortKey + nextSibling.sortKey) / 2
          : previousSibling.sortKey + 100
        : nextSibling
          ? nextSibling.sortKey - 100
          : 100;
      const optimisticTodo: Todo = {
        id: input.id,
        listId,
        parentId: input.parentId,
        title: input.title,
        notes: "",
        status: input.status,
        dueDate: null,
        sortKey,
        version: 1,
        createdAt: now,
        updatedAt: now,
      };

      queryClient.setQueryData<TodosResponse>(key, {
        todos: [...(previous?.todos ?? []), optimisticTodo],
      });
      return { key, previous };
    },
    onError: (_error, variables, context) => {
      if (context) queryClient.setQueryData(context.key, context.previous);
      if (focusTodoId.current === variables.input.id) {
        focusTodoId.current = null;
      }
    },
    onSuccess: (savedTodo, { listId, input }) => {
      queryClient.setQueryData<TodosResponse>(
        todoQueryKey(listId),
        (current) => ({
          todos: (current?.todos ?? []).map((todo) =>
            todo.id === input.id ? savedTodo : todo,
          ),
        }),
      );
    },
    onSettled: (_data, _error, { listId }) => {
      void queryClient.invalidateQueries({ queryKey: todoQueryKey(listId) });
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({
      todoId,
      input,
    }: {
      todoId: string;
      input: UpdateTodoInput;
    }) => updateTodo(todoId, input),
    onMutate: async ({ todoId, input }) => {
      if (!activeList) return undefined;
      const key = todoQueryKey(activeList.id);
      await queryClient.cancelQueries({ queryKey: key });
      const previous = queryClient.getQueryData<TodosResponse>(key);
      queryClient.setQueryData<TodosResponse>(key, {
        todos: (previous?.todos ?? []).map((todo) =>
          todo.id === todoId
            ? { ...todo, ...input, version: todo.version + 1 }
            : todo,
        ),
      });
      return { key, previous };
    },
    onError: (_error, _variables, context) => {
      if (context) queryClient.setQueryData(context.key, context.previous);
    },
    onSuccess: (savedTodo) => {
      if (!activeList) return;
      queryClient.setQueryData<TodosResponse>(
        todoQueryKey(activeList.id),
        (current) => ({
          todos: (current?.todos ?? []).map((todo) =>
            todo.id === savedTodo.id ? savedTodo : todo,
          ),
        }),
      );
    },
    onSettled: () => {
      if (activeList) {
        void queryClient.invalidateQueries({
          queryKey: todoQueryKey(activeList.id),
        });
      }
    },
  });

  const moveMutation = useMutation({
    mutationFn: ({ todoId, input }: { todoId: string; input: MoveTodoInput }) =>
      moveTodo(todoId, input),
    onMutate: async ({ todoId, input }) => {
      if (!activeList) return undefined;
      const key = todoQueryKey(activeList.id);
      await queryClient.cancelQueries({ queryKey: key });
      const previous = queryClient.getQueryData<TodosResponse>(key);
      queryClient.setQueryData<TodosResponse>(key, {
        todos: applyMove(previous?.todos ?? [], todoId, input),
      });
      return { key, previous };
    },
    onError: (_error, _variables, context) => {
      if (context) queryClient.setQueryData(context.key, context.previous);
    },
    onSuccess: (savedTodo) => {
      if (!activeList) return;
      queryClient.setQueryData<TodosResponse>(
        todoQueryKey(activeList.id),
        (current) => ({
          todos: (current?.todos ?? []).map((todo) =>
            todo.id === savedTodo.id
              ? {
                  ...savedTodo,
                  // The optimistic move normalizes every destination sibling's
                  // sort key. Keep this item on that same temporary scale until
                  // the invalidation below fetches all canonical D1 sort keys.
                  parentId: todo.parentId,
                  sortKey: todo.sortKey,
                }
              : todo,
          ),
        }),
      );
    },
    onSettled: () => {
      if (activeList) {
        void queryClient.invalidateQueries({
          queryKey: todoQueryKey(activeList.id),
        });
      }
    },
  });

  const deleteMutation = useMutation({
    mutationFn: ({
      todoId,
      deletionToken,
      version,
    }: {
      todoId: string;
      deletionToken: string;
      version: number;
      removedTodos: Todo[];
    }) => deleteTodo(todoId, { deletionToken, version }),
    onMutate: async ({ deletionToken, removedTodos }) => {
      if (!activeList) return undefined;
      const key = todoQueryKey(activeList.id);
      await queryClient.cancelQueries({ queryKey: key });
      const previous = queryClient.getQueryData<TodosResponse>(key);
      const removedIds = new Set(removedTodos.map((todo) => todo.id));
      queryClient.setQueryData<TodosResponse>(key, {
        todos: (previous?.todos ?? []).filter(
          (todo) => !removedIds.has(todo.id),
        ),
      });
      setUndoDeletion({ deletionToken, todos: removedTodos });
      return { key, previous };
    },
    onError: (_error, _variables, context) => {
      if (context) queryClient.setQueryData(context.key, context.previous);
      setUndoDeletion(null);
    },
    onSettled: () => {
      if (activeList)
        void queryClient.invalidateQueries({
          queryKey: todoQueryKey(activeList.id),
        });
    },
  });

  const restoreMutation = useMutation({
    mutationFn: ({ deletionToken }: UndoDeletion) =>
      restoreTodos(deletionToken),
    onMutate: async (deletion) => {
      if (!activeList) return undefined;
      const key = todoQueryKey(activeList.id);
      await queryClient.cancelQueries({ queryKey: key });
      const previous = queryClient.getQueryData<TodosResponse>(key);
      queryClient.setQueryData<TodosResponse>(key, {
        todos: [...(previous?.todos ?? []), ...deletion.todos],
      });
      setUndoDeletion(null);
      return { key, previous };
    },
    onError: (_error, deletion, context) => {
      if (context) queryClient.setQueryData(context.key, context.previous);
      setUndoDeletion(deletion);
    },
    onSuccess: ({ todos: restored }) => {
      if (!activeList) return;
      const restoredById = new Map(restored.map((todo) => [todo.id, todo]));
      queryClient.setQueryData<TodosResponse>(
        todoQueryKey(activeList.id),
        (current) => ({
          todos: (current?.todos ?? []).map(
            (todo) => restoredById.get(todo.id) ?? todo,
          ),
        }),
      );
    },
    onSettled: () => {
      if (activeList)
        void queryClient.invalidateQueries({
          queryKey: todoQueryKey(activeList.id),
        });
    },
  });

  useLayoutEffect(() => {
    const todoId = focusTodoId.current;
    if (!todoId || !todosQuery.data?.todos.some((todo) => todo.id === todoId)) {
      return;
    }
    const input = document.getElementById(`todo-title-${todoId}`);
    if (!(input instanceof HTMLInputElement)) return;
    input.focus();
    input.setSelectionRange(0, input.value.length);
    focusTodoId.current = null;
  }, [todosQuery.data]);

  const todos = todosQuery.data?.todos ?? [];

  const createFirstTodo = (parentId: string | null) => {
    if (!activeList) return;
    const siblings = getSiblings(todos, parentId);
    createMutation.mutate({
      listId: activeList.id,
      input: {
        id: crypto.randomUUID(),
        title: "",
        parentId,
        previousId: null,
        nextId: siblings[0]?.id ?? null,
        status: "Unsorted",
      },
      focusTitle: true,
    });
  };

  const startupError = meQuery.error ?? listsQuery.error ?? todosQuery.error;
  const mutationError =
    createMutation.error ??
    updateMutation.error ??
    moveMutation.error ??
    deleteMutation.error ??
    restoreMutation.error;

  return (
    <main className="mx-auto min-h-dvh max-w-3xl p-6 text-plain-black">
      <header className="flex items-center gap-2 border-b border-plain-300 pb-3">
        <img src={logoUrl} width="24" alt="" />
        <h1 className="text-2xl font-bold">Tiger Todo</h1>
        <span className="ml-auto text-xs text-plain-600">
          {meQuery.data?.user.email}
        </span>
      </header>

      {startupError ? (
        <p className="mt-6 rounded border border-red-300 bg-red-50 p-3 text-sm text-red-800">
          {startupError instanceof Error
            ? startupError.message
            : "Tiger could not start"}
        </p>
      ) : !activeList ? (
        <p className="mt-6 text-sm text-plain-600">Loading Tiger…</p>
      ) : (
        <section className="mt-6">
          <div className="flex items-center">
            <h2 className="text-sm font-semibold text-plain-700">
              {activeList.name}
            </h2>
            <div className="ml-auto flex items-center gap-2">
              {(updateMutation.isPending ||
                moveMutation.isPending ||
                deleteMutation.isPending ||
                restoreMutation.isPending) && (
                <span className="text-2xs text-plain-500">Saving…</span>
              )}
              <div
                className="flex rounded-md border border-plain-300 bg-plain-200 p-0.5"
                aria-label="Todo order"
                role="group"
              >
                {(
                  [
                    [null, "Default"],
                    ["dueDate", "Due date"],
                    ["status", "Status"],
                  ] as const
                ).map(([sort, label]) => (
                  <button
                    key={sort ?? "default"}
                    className={`rounded px-2 py-1 text-2xs font-medium ${
                      todoSort === sort
                        ? "bg-plain-white text-plain-900 shadow-sm"
                        : "text-plain-600 hover:text-plain-900"
                    }`}
                    type="button"
                    aria-pressed={todoSort === sort}
                    onClick={() => setTodoSort(sort)}
                  >
                    {label}
                  </button>
                ))}
              </div>
              <button
                className="flex h-6 w-6 items-center justify-center rounded text-plain-900 hover:bg-plain-200 disabled:opacity-20"
                type="button"
                disabled={
                  !undoDeletion ||
                  deleteMutation.isPending ||
                  restoreMutation.isPending
                }
                onClick={() => {
                  if (undoDeletion) restoreMutation.mutate(undoDeletion);
                }}
                title={undoDeletion ? "Undo deletion" : "Nothing to undo"}
                aria-label="Undo last deletion"
              >
                <TbArrowBackUp aria-hidden="true" className="h-4 w-4" />
              </button>
              <button
                className="flex h-6 w-6 items-center justify-center rounded text-base text-plain-900 hover:bg-plain-200"
                type="button"
                onClick={() => createFirstTodo(null)}
                title="Add todo first"
                aria-label="Add todo first"
              >
                <TbPlus aria-hidden="true" className="h-4 w-4" />
              </button>
            </div>
          </div>

          {mutationError && (
            <p className="mt-2 text-xs text-red-600">
              {mutationError.message}. The local change was rolled back.
            </p>
          )}

          <div className="mt-4">
            <TodoTree
              todos={todos}
              sort={todoSort}
              onAddChild={(todo) => createFirstTodo(todo.id)}
              onCreateBelow={(todo) => {
                const children = getSiblings(todos, todo.id);
                const siblings = getSiblings(todos, todo.parentId);
                const siblingIndex = siblings.findIndex(
                  (candidate) => candidate.id === todo.id,
                );
                const id = crypto.randomUUID();
                createMutation.mutate({
                  listId: activeList.id,
                  input: children.length
                    ? {
                        id,
                        title: "",
                        parentId: todo.id,
                        previousId: null,
                        nextId: children[0].id,
                        status: "Unsorted",
                      }
                    : {
                        id,
                        title: "",
                        parentId: todo.parentId,
                        previousId: todo.id,
                        nextId: siblings[siblingIndex + 1]?.id ?? null,
                        status: "Unsorted",
                      },
                  focusTitle: true,
                });
              }}
              onDelete={(todo) => {
                const removedTodos = getSubtree(todos, todo.id);
                deleteMutation.mutate({
                  todoId: todo.id,
                  deletionToken: crypto.randomUUID(),
                  version: todo.version,
                  removedTodos,
                });
              }}
              onMove={(todoId, input) => moveMutation.mutate({ todoId, input })}
              onUpdate={(todoId, update) => {
                const todo = todos.find((candidate) => candidate.id === todoId);
                if (todo) {
                  updateMutation.mutate({
                    todoId,
                    input: { ...update, version: todo.version },
                  });
                }
              }}
            />
          </div>

          {todos.length === 0 && (
            <p className="mt-6 text-center text-sm text-plain-500">
              Nothing here yet.
            </p>
          )}

        </section>
      )}
    </main>
  );
}

export default App;

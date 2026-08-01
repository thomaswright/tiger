import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { type FormEvent, useState } from "react";
import {
  createTodo,
  getLists,
  getMe,
  getTodos,
  moveTodo,
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
import { applyMove, getSiblings } from "./tree";

const todoQueryKey = (listId: string) => ["todos", listId] as const;

function App() {
  const queryClient = useQueryClient();
  const [title, setTitle] = useState("");
  const [newTodoParentId, setNewTodoParentId] = useState<string | null>(null);

  const meQuery = useQuery({ queryKey: ["me"], queryFn: getMe });
  const listsQuery = useQuery({ queryKey: ["lists"], queryFn: getLists });
  const activeList = listsQuery.data?.lists[0];
  const todosQuery = useQuery({
    queryKey: todoQueryKey(activeList?.id ?? "pending"),
    queryFn: () => getTodos(activeList!.id),
    enabled: Boolean(activeList),
  });

  const createMutation = useMutation({
    mutationFn: ({ listId, input }: { listId: string; input: CreateTodoInput }) =>
      createTodo(listId, input),
    onMutate: async ({ listId, input }) => {
      const key = todoQueryKey(listId);
      await queryClient.cancelQueries({ queryKey: key });
      const previous = queryClient.getQueryData<TodosResponse>(key);
      const now = new Date().toISOString();
      const siblings = getSiblings(previous?.todos ?? [], input.parentId);
      const optimisticTodo: Todo = {
        id: input.id,
        listId,
        parentId: input.parentId,
        title: input.title,
        notes: "",
        status: input.status,
        dueDate: null,
        sortKey: (siblings[siblings.length - 1]?.sortKey ?? 0) + 100,
        version: 1,
        createdAt: now,
        updatedAt: now,
      };

      queryClient.setQueryData<TodosResponse>(key, {
        todos: [...(previous?.todos ?? []), optimisticTodo],
      });
      return { key, previous };
    },
    onError: (_error, _variables, context) => {
      if (context) queryClient.setQueryData(context.key, context.previous);
    },
    onSuccess: (savedTodo, { listId, input }) => {
      queryClient.setQueryData<TodosResponse>(todoQueryKey(listId), (current) => ({
        todos: (current?.todos ?? []).map((todo) =>
          todo.id === input.id ? savedTodo : todo,
        ),
      }));
    },
    onSettled: (_data, _error, { listId }) => {
      void queryClient.invalidateQueries({ queryKey: todoQueryKey(listId) });
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ todoId, input }: { todoId: string; input: UpdateTodoInput }) =>
      updateTodo(todoId, input),
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

  const submitTodo = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const nextTitle = title.trim();
    if (!activeList || !nextTitle) return;

    setTitle("");
    createMutation.mutate({
      listId: activeList.id,
      input: {
        id: crypto.randomUUID(),
        title: nextTitle,
        parentId: newTodoParentId,
        status: "Unsorted",
      },
    });
    setNewTodoParentId(null);
  };

  const todos = todosQuery.data?.todos ?? [];
  const parentTodo = newTodoParentId
    ? todos.find((todo) => todo.id === newTodoParentId)
    : undefined;
  const startupError = meQuery.error ?? listsQuery.error ?? todosQuery.error;
  const mutationError =
    createMutation.error ?? updateMutation.error ?? moveMutation.error;

  return (
    <main className="mx-auto min-h-dvh max-w-3xl p-6 text-[var(--t10)]">
      <header className="flex items-center gap-2 border-b border-[var(--t3)] pb-3">
        <img src={logoUrl} width="24" alt="" />
        <h1 className="text-2xl font-bold">Tiger Todo</h1>
        <span className="ml-auto text-xs text-[var(--t6)]">
          {meQuery.data?.user.email}
        </span>
      </header>

      {startupError ? (
        <p className="mt-6 rounded border border-red-300 bg-red-50 p-3 text-sm text-red-800">
          {startupError instanceof Error ? startupError.message : "Tiger could not start"}
        </p>
      ) : !activeList ? (
        <p className="mt-6 text-sm text-[var(--t6)]">Loading Tiger…</p>
      ) : (
        <section className="mt-6">
          <div className="flex items-center">
            <h2 className="text-sm font-semibold text-[var(--t7)]">
              {activeList.name}
            </h2>
            {(updateMutation.isPending || moveMutation.isPending) && (
              <span className="ml-auto text-2xs text-[var(--t5)]">Saving…</span>
            )}
          </div>

          {parentTodo && (
            <div className="mt-3 flex items-center gap-2 text-xs text-[var(--t6)]">
              Adding under “{parentTodo.title}”
              <button type="button" onClick={() => setNewTodoParentId(null)}>
                Cancel
              </button>
            </div>
          )}
          <form className="mt-3 flex gap-2" onSubmit={submitTodo}>
            <input
              className="min-w-0 flex-1 rounded border border-[var(--t3)] bg-[var(--t0)] px-3 py-2 text-sm focus:border-[var(--t6)] focus:ring-0"
              value={title}
              onChange={(event) => setTitle(event.target.value)}
              placeholder={parentTodo ? "Add a child todo" : "Add a todo"}
              aria-label="Todo title"
            />
            <button
              className="rounded bg-[var(--t9)] px-4 py-2 text-sm text-[var(--t0)] disabled:opacity-40"
              disabled={!title.trim()}
              type="submit"
            >
              Add
            </button>
          </form>

          {mutationError && (
            <p className="mt-2 text-xs text-red-600">
              {mutationError.message}. The local change was rolled back.
            </p>
          )}

          <div className="mt-4">
            <TodoTree
              todos={todos}
              onAddChild={(todo) => setNewTodoParentId(todo.id)}
              onMove={(todoId, input) =>
                moveMutation.mutate({ todoId, input })
              }
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
            <p className="mt-6 text-center text-sm text-[var(--t5)]">
              Nothing here yet.
            </p>
          )}
        </section>
      )}
    </main>
  );
}

export default App;

import type { MoveTodoInput, Todo } from "./shared/domain";

export type MoveDirection = "up" | "down" | "indent" | "outdent";

export const ROOT_GROUP = "__tiger_root__";

export const groupForParent = (parentId: string | null) =>
  parentId ?? ROOT_GROUP;

export const parentForGroup = (group: string | number | undefined) =>
  group === ROOT_GROUP || group === undefined ? null : String(group);

export const getSiblings = (
  todos: Todo[],
  parentId: string | null,
  excludeId?: string,
) => {
  const siblings = todos.filter(
    (todo) => todo.parentId === parentId && todo.id !== excludeId,
  );
  return siblings.sort(
    (a, b) => a.sortKey - b.sortKey || a.id.localeCompare(b.id),
  );
};

export function planMoveTo(
  todos: Todo[],
  todoId: string,
  parentId: string | null,
  requestedIndex: number,
): MoveTodoInput | null {
  const todo = todos.find((candidate) => candidate.id === todoId);
  if (!todo) {
    return null;
  }

  const siblings = getSiblings(todos, parentId, todoId);
  const index = Math.max(0, Math.min(requestedIndex, siblings.length));
  const previousId = siblings[index - 1]?.id ?? null;
  const nextId = siblings[index]?.id ?? null;

  if (todo.parentId === parentId) {
    const currentSiblings = getSiblings(todos, todo.parentId);
    const currentIndex = currentSiblings.findIndex(
      (candidate) => candidate.id === todoId,
    );
    if (
      currentSiblings[currentIndex - 1]?.id === (previousId ?? undefined) &&
      currentSiblings[currentIndex + 1]?.id === (nextId ?? undefined)
    ) {
      return null;
    }
  }

  return {
    parentId,
    previousId,
    nextId,
    version: todo.version,
  };
}

export function planDirectionalMove(
  todos: Todo[],
  todoId: string,
  direction: MoveDirection,
): MoveTodoInput | null {
  const todo = todos.find((candidate) => candidate.id === todoId);
  if (!todo) {
    return null;
  }

  const siblings = getSiblings(todos, todo.parentId);
  const index = siblings.findIndex((candidate) => candidate.id === todoId);

  if (direction === "up") {
    return index > 0
      ? planMoveTo(todos, todoId, todo.parentId, index - 1)
      : null;
  }

  if (direction === "down") {
    return index >= 0 && index < siblings.length - 1
      ? planMoveTo(todos, todoId, todo.parentId, index + 1)
      : null;
  }

  if (direction === "indent") {
    const previousSibling = siblings[index - 1];
    if (!previousSibling) {
      return null;
    }
    return planMoveTo(
      todos,
      todoId,
      previousSibling.id,
      getSiblings(todos, previousSibling.id, todoId).length,
    );
  }

  if (!todo.parentId) {
    return null;
  }

  const parent = todos.find((candidate) => candidate.id === todo.parentId);
  if (!parent) {
    return null;
  }
  const parentSiblings = getSiblings(todos, parent.parentId, todoId);
  const parentIndex = parentSiblings.findIndex(
    (candidate) => candidate.id === parent.id,
  );
  return planMoveTo(todos, todoId, parent.parentId, parentIndex + 1);
}

export function applyMove(
  todos: Todo[],
  todoId: string,
  move: MoveTodoInput,
): Todo[] {
  const moved = todos.find((todo) => todo.id === todoId);
  if (!moved) {
    return todos;
  }

  const destination = getSiblings(todos, move.parentId, todoId);
  let insertionIndex = destination.length;
  if (move.nextId) {
    const nextIndex = destination.findIndex((todo) => todo.id === move.nextId);
    if (nextIndex >= 0) {
      insertionIndex = nextIndex;
    }
  } else if (move.previousId) {
    const previousIndex = destination.findIndex(
      (todo) => todo.id === move.previousId,
    );
    if (previousIndex >= 0) {
      insertionIndex = previousIndex + 1;
    }
  }

  const reordered = [...destination];
  reordered.splice(insertionIndex, 0, {
    ...moved,
    parentId: move.parentId,
    version: moved.version + 1,
  });
  const replacements = new Map(
    reordered.map((todo, index) => [
      todo.id,
      { ...todo, sortKey: (index + 1) * 100 },
    ]),
  );

  return todos.map((todo) => replacements.get(todo.id) ?? todo);
}

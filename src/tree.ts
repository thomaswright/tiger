import {
  TODO_STATUSES,
  type MoveTodoInput,
  type Todo,
} from "./shared/domain";

export type MoveDirection = "up" | "down" | "indent" | "outdent";
export type TodoSort = "dueDate" | "status";

export const ROOT_GROUP = "__tiger_root__";
export const TODO_INDENTATION_WIDTH = 20;

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

export const getSortedSiblings = (
  todos: Todo[],
  parentId: string | null,
  sort: TodoSort | null,
) => {
  const siblings = getSiblings(todos, parentId);
  if (sort === null) return siblings;

  return siblings.sort((a, b) => {
    if (sort === "status") {
      return TODO_STATUSES.indexOf(a.status) - TODO_STATUSES.indexOf(b.status);
    }
    if (a.dueDate === b.dueDate) return 0;
    if (a.dueDate === null) return 1;
    if (b.dueDate === null) return -1;
    return a.dueDate.localeCompare(b.dueDate);
  });
};

export const getSubtree = (todos: Todo[], todoId: string): Todo[] => {
  const ids = new Set([todoId]);
  let changed = true;
  while (changed) {
    changed = false;
    for (const todo of todos) {
      if (todo.parentId && ids.has(todo.parentId) && !ids.has(todo.id)) {
        ids.add(todo.id);
        changed = true;
      }
    }
  }
  return todos.filter((todo) => ids.has(todo.id));
};

export interface FlattenedTodo {
  todo: Todo;
  depth: number;
}

export const flattenTodos = (todos: Todo[]): FlattenedTodo[] => {
  const flattened: FlattenedTodo[] = [];
  const visited = new Set<string>();

  const visit = (parentId: string | null, depth: number) => {
    for (const todo of getSiblings(todos, parentId)) {
      if (visited.has(todo.id)) continue;
      visited.add(todo.id);
      flattened.push({ todo, depth });
      visit(todo.id, depth + 1);
    }
  };

  visit(null, 0);
  return flattened;
};

const clamp = (value: number, minimum: number, maximum: number) =>
  Math.max(minimum, Math.min(maximum, value));

export const destinationIndexFromTarget = (
  targetIndex: number,
  belowTarget: boolean,
  sameGroup: boolean,
  sourceIndex: number,
) => {
  let destinationIndex = targetIndex + (belowTarget ? 1 : 0);
  if (sameGroup && sourceIndex < destinationIndex) destinationIndex -= 1;
  return destinationIndex;
};

export function planProjectedMove(
  todos: Todo[],
  todoId: string,
  collisionParentId: string | null,
  requestedIndex: number,
  horizontalOffset: number,
  indentationWidth = TODO_INDENTATION_WIDTH,
): MoveTodoInput | null {
  const movingTodo = todos.find((todo) => todo.id === todoId);
  const originalDepth = flattenTodos(todos).find(
    ({ todo }) => todo.id === todoId,
  )?.depth;
  if (!movingTodo || originalDepth === undefined) return null;

  const removedIds = new Set(getSubtree(todos, todoId).map((todo) => todo.id));
  if (collisionParentId && removedIds.has(collisionParentId)) return null;

  const remaining = todos.filter((todo) => !removedIds.has(todo.id));
  const collisionSiblings = getSiblings(remaining, collisionParentId);
  const collisionIndex = clamp(requestedIndex, 0, collisionSiblings.length);
  const previousCollisionSibling = collisionSiblings[collisionIndex - 1];
  const nextCollisionSibling = collisionSiblings[collisionIndex];
  const flattened = flattenTodos(remaining);

  let insertionIndex = 0;
  if (nextCollisionSibling) {
    insertionIndex = flattened.findIndex(
      ({ todo }) => todo.id === nextCollisionSibling.id,
    );
  } else if (previousCollisionSibling) {
    const previousIndex = flattened.findIndex(
      ({ todo }) => todo.id === previousCollisionSibling.id,
    );
    const previousDepth = flattened[previousIndex]?.depth ?? 0;
    insertionIndex = previousIndex + 1;
    while (
      insertionIndex < flattened.length &&
      flattened[insertionIndex].depth > previousDepth
    ) {
      insertionIndex += 1;
    }
  } else if (collisionParentId) {
    const parentIndex = flattened.findIndex(
      ({ todo }) => todo.id === collisionParentId,
    );
    if (parentIndex < 0) return null;
    insertionIndex = parentIndex + 1;
  }

  const previousItem = flattened[insertionIndex - 1];
  const nextItem = flattened[insertionIndex];
  const requestedDepth =
    originalDepth + Math.round(horizontalOffset / indentationWidth);
  const maximumDepth = previousItem ? previousItem.depth + 1 : 0;
  const minimumDepth = Math.min(nextItem?.depth ?? 0, maximumDepth);
  const projectedDepth = clamp(requestedDepth, minimumDepth, maximumDepth);

  let parentId: string | null = null;
  if (projectedDepth > 0 && previousItem) {
    if (previousItem.depth === projectedDepth - 1) {
      parentId = previousItem.todo.id;
    } else if (previousItem.depth === projectedDepth) {
      parentId = previousItem.todo.parentId;
    } else {
      for (let index = insertionIndex - 1; index >= 0; index -= 1) {
        if (flattened[index].depth === projectedDepth) {
          parentId = flattened[index].todo.parentId;
          break;
        }
      }
    }
  }

  const flattenedIndex = new Map(
    flattened.map(({ todo }, index) => [todo.id, index]),
  );
  const destinationIndex = getSiblings(remaining, parentId).filter(
    (todo) => (flattenedIndex.get(todo.id) ?? Number.POSITIVE_INFINITY) < insertionIndex,
  ).length;

  return planMoveTo(todos, todoId, parentId, destinationIndex);
}

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

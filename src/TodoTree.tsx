import { DragDropProvider } from "@dnd-kit/react";
import { isSortable, useSortable } from "@dnd-kit/react/sortable";
import { useEffect, useRef, useState } from "react";
import {
  TODO_STATUSES,
  type MoveTodoInput,
  type Todo,
  type TodoStatus,
  type UpdateTodoInput,
} from "./shared/domain";
import {
  getSiblings,
  groupForParent,
  parentForGroup,
  planDirectionalMove,
  planMoveTo,
  type MoveDirection,
} from "./tree";

interface TodoTreeProps {
  todos: Todo[];
  onAddChild: (todo: Todo) => void;
  onMove: (todoId: string, move: MoveTodoInput) => void;
  onUpdate: (
    todoId: string,
    update: Omit<UpdateTodoInput, "version">,
  ) => void;
}

interface TodoNodeProps extends TodoTreeProps {
  todo: Todo;
  index: number;
  depth: number;
  ancestors: ReadonlySet<string>;
}

function TodoNode({
  todo,
  todos,
  index,
  depth,
  ancestors,
  onAddChild,
  onMove,
  onUpdate,
}: TodoNodeProps) {
  const [draft, setDraft] = useState(todo.title);
  const inputRef = useRef<HTMLInputElement>(null);
  const { ref, handleRef, isDragging } = useSortable({
    id: todo.id,
    index,
    group: groupForParent(todo.parentId),
  });

  useEffect(() => {
    if (document.activeElement !== inputRef.current) {
      setDraft(todo.title);
    }
  }, [todo.title]);

  const commitTitle = () => {
    const title = draft.trim();
    if (!title) {
      setDraft(todo.title);
      return;
    }
    if (title !== todo.title) {
      onUpdate(todo.id, { title });
    }
  };

  const move = (direction: MoveDirection) => {
    const planned = planDirectionalMove(todos, todo.id, direction);
    if (planned) {
      onMove(todo.id, planned);
    }
  };

  const canMove = (direction: MoveDirection) =>
    planDirectionalMove(todos, todo.id, direction) !== null;

  const nextAncestors = new Set(ancestors).add(todo.id);

  return (
    <li ref={ref} className={isDragging ? "opacity-40" : undefined}>
      <div
        className="group flex min-h-10 items-center gap-1 border-b border-[var(--t2)] py-1"
        style={{ paddingLeft: `${depth * 20}px` }}
      >
        <button
          ref={handleRef}
          className="flex h-7 w-5 cursor-grab items-center justify-center text-[var(--t5)] active:cursor-grabbing"
          style={{ touchAction: "none" }}
          aria-label={`Drag ${todo.title}`}
          title="Drag to reorder"
          type="button"
        >
          ⠿
        </button>
        <input
          ref={inputRef}
          className="min-w-0 flex-1 border-0 bg-transparent px-1 py-1 text-sm focus:ring-0"
          value={draft}
          onBlur={commitTitle}
          onChange={(event) => setDraft(event.target.value)}
          onKeyDown={(event) => {
            if (event.key === "Enter") {
              event.currentTarget.blur();
            }
            if (event.key === "Escape") {
              setDraft(todo.title);
              event.currentTarget.blur();
            }
          }}
          aria-label="Todo title"
        />
        <select
          className="h-7 w-28 rounded border-[var(--t3)] bg-[var(--t0)] py-0 pl-2 pr-6 text-2xs focus:ring-0"
          value={todo.status}
          onChange={(event) =>
            onUpdate(todo.id, { status: event.target.value as TodoStatus })
          }
          aria-label={`Status for ${todo.title}`}
        >
          {TODO_STATUSES.map((status) => (
            <option key={status} value={status}>
              {status}
            </option>
          ))}
        </select>
        <div className="flex items-center opacity-30 transition-opacity group-hover:opacity-100 group-focus-within:opacity-100">
          {(["outdent", "indent", "up", "down"] as const).map(
            (direction) => (
              <button
                key={direction}
                className="h-7 w-6 rounded text-xs hover:bg-[var(--t2)] disabled:opacity-20"
                disabled={!canMove(direction)}
                onClick={() => move(direction)}
                title={direction}
                aria-label={`${direction} ${todo.title}`}
                type="button"
              >
                {{ outdent: "←", indent: "→", up: "↑", down: "↓" }[
                  direction
                ]}
              </button>
            ),
          )}
          <button
            className="h-7 w-6 rounded text-sm hover:bg-[var(--t2)]"
            onClick={() => onAddChild(todo)}
            title="Add child"
            aria-label={`Add child under ${todo.title}`}
            type="button"
          >
            +
          </button>
        </div>
      </div>
      <TodoBranch
        ancestors={nextAncestors}
        depth={depth + 1}
        parentId={todo.id}
        todos={todos}
        onAddChild={onAddChild}
        onMove={onMove}
        onUpdate={onUpdate}
      />
    </li>
  );
}

interface TodoBranchProps extends TodoTreeProps {
  parentId: string | null;
  depth: number;
  ancestors: ReadonlySet<string>;
}

function TodoBranch({
  parentId,
  depth,
  ancestors,
  todos,
  onAddChild,
  onMove,
  onUpdate,
}: TodoBranchProps) {
  const siblings = getSiblings(todos, parentId).filter(
    (todo) => !ancestors.has(todo.id),
  );

  if (siblings.length === 0) {
    return null;
  }

  return (
    <ul>
      {siblings.map((todo, index) => (
        <TodoNode
          key={todo.id}
          ancestors={ancestors}
          depth={depth}
          index={index}
          todo={todo}
          todos={todos}
          onAddChild={onAddChild}
          onMove={onMove}
          onUpdate={onUpdate}
        />
      ))}
    </ul>
  );
}

export default function TodoTree(props: TodoTreeProps) {
  return (
    <DragDropProvider
      onDragEnd={(event) => {
        if (event.canceled) {
          return;
        }

        const source = event.operation.source;
        if (!isSortable(source)) {
          return;
        }

        const todoId = String(source.id);
        const move = planMoveTo(
          props.todos,
          todoId,
          parentForGroup(source.group),
          source.index,
        );
        if (move) {
          props.onMove(todoId, move);
        }
      }}
    >
      <TodoBranch
        {...props}
        ancestors={new Set()}
        depth={0}
        parentId={null}
      />
    </DragDropProvider>
  );
}

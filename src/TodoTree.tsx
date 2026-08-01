import { combine } from "@atlaskit/pragmatic-drag-and-drop/combine";
import {
  draggable,
  dropTargetForElements,
  monitorForElements,
} from "@atlaskit/pragmatic-drag-and-drop/element/adapter";
import type {
  DragLocation,
  DropTargetRecord,
} from "@atlaskit/pragmatic-drag-and-drop/types";
import {
  attachClosestEdge,
  extractClosestEdge,
} from "@atlaskit/pragmatic-drag-and-drop-hitbox/closest-edge";
import {
  useCallback,
  useEffect,
  useLayoutEffect,
  useRef,
  useState,
} from "react";
import {
  TODO_STATUSES,
  type MoveTodoInput,
  type Todo,
  type TodoStatus,
  type UpdateTodoInput,
} from "./shared/domain";
import {
  applyMove,
  getSiblings,
  planDirectionalMove,
  planProjectedMove,
  TODO_INDENTATION_WIDTH,
  type MoveDirection,
} from "./tree";

const TODO_DRAG_TYPE = "tiger-todo";

const isTodoDragData = (
  data: Record<string | symbol, unknown>,
): data is Record<string | symbol, unknown> & { todoId: string } =>
  data.type === TODO_DRAG_TYPE && typeof data.todoId === "string";

const getTodoTarget = (record: DropTargetRecord | undefined) => {
  if (!record || !isTodoDragData(record.data)) return null;
  const edge = extractClosestEdge(record.data);
  if (edge !== "top" && edge !== "bottom") return null;
  return { todoId: record.data.todoId, edge };
};

interface TodoTreeProps {
  todos: Todo[];
  onAddChild: (todo: Todo) => void;
  onDelete: (todo: Todo) => void;
  onMove: (todoId: string, move: MoveTodoInput) => void;
  onUpdate: (todoId: string, update: Omit<UpdateTodoInput, "version">) => void;
}

type RegisterRow = (todoId: string, element: HTMLDivElement | null) => void;

interface TreeRenderProps extends TodoTreeProps {
  activeTodoId: string | null;
  registerRow: RegisterRow;
}

interface TodoNodeProps extends TreeRenderProps {
  todo: Todo;
  depth: number;
  ancestors: ReadonlySet<string>;
}

function TodoNode({
  todo,
  todos,
  depth,
  ancestors,
  onAddChild,
  onDelete,
  onMove,
  onUpdate,
  activeTodoId,
  registerRow,
}: TodoNodeProps) {
  const [draft, setDraft] = useState(todo.title);
  const [notesDraft, setNotesDraft] = useState(todo.notes);
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);
  const notesRef = useRef<HTMLTextAreaElement>(null);
  const rowRef = useRef<HTMLDivElement | null>(null);
  const handleRef = useRef<HTMLButtonElement | null>(null);
  const ancestorsRef = useRef(ancestors);

  useLayoutEffect(() => {
    ancestorsRef.current = ancestors;
  }, [ancestors]);

  const setRowRef = useCallback(
    (element: HTMLDivElement | null) => {
      rowRef.current = element;
      registerRow(todo.id, element);
    },
    [registerRow, todo.id],
  );

  useEffect(() => {
    const element = rowRef.current;
    const dragHandle = handleRef.current;
    if (!element || !dragHandle) return;

    return combine(
      draggable({
        element,
        dragHandle,
        getInitialData: () => ({ type: TODO_DRAG_TYPE, todoId: todo.id }),
      }),
      dropTargetForElements({
        element,
        canDrop: ({ source }) =>
          isTodoDragData(source.data) &&
          source.data.todoId !== todo.id &&
          !ancestorsRef.current.has(source.data.todoId),
        getData: ({ input, element: targetElement }) =>
          attachClosestEdge(
            { type: TODO_DRAG_TYPE, todoId: todo.id },
            { element: targetElement, input, allowedEdges: ["top", "bottom"] },
          ),
        getIsSticky: () => true,
      }),
    );
  }, [todo.id]);

  useEffect(() => {
    if (document.activeElement !== inputRef.current) setDraft(todo.title);
  }, [todo.title]);
  useEffect(() => {
    if (document.activeElement !== notesRef.current) setNotesDraft(todo.notes);
  }, [todo.notes]);

  const commitTitle = () => {
    const title = draft.trim();
    if (!title) setDraft(todo.title);
    else if (title !== todo.title) onUpdate(todo.id, { title });
  };
  const move = (direction: MoveDirection) => {
    const planned = planDirectionalMove(todos, todo.id, direction);
    if (planned) onMove(todo.id, planned);
  };
  const canMove = (direction: MoveDirection) =>
    planDirectionalMove(todos, todo.id, direction) !== null;
  const children = getSiblings(todos, todo.id);
  const nextAncestors = new Set(ancestors).add(todo.id);

  return (
    <li className={activeTodoId === todo.id ? "opacity-40" : undefined}>
      <div
        ref={setRowRef}
        className="group flex min-h-10 items-center gap-1 border-b border-[var(--t2)] py-1"
        style={{ paddingLeft: `${depth * TODO_INDENTATION_WIDTH}px` }}
      >
        <button
          ref={handleRef}
          className="flex h-7 w-5 cursor-grab items-center justify-center text-[var(--t5)] active:cursor-grabbing"
          style={{ touchAction: "none" }}
          aria-label={`Drag ${todo.title}`}
          title="Drag vertically to reorder; move left or right to change nesting"
          type="button"
        >
          ⠿
        </button>
        <button
          className="flex h-7 w-5 items-center justify-center text-xs text-[var(--t6)] disabled:invisible"
          disabled={children.length === 0}
          onClick={() => setCollapsed((value) => !value)}
          aria-expanded={children.length > 0 ? !collapsed : undefined}
          aria-label={`${collapsed ? "Expand" : "Collapse"} ${todo.title}`}
          title={collapsed ? "Expand children" : "Collapse children"}
          type="button"
        >
          {collapsed ? "▸" : "▾"}
        </button>
        <input
          ref={inputRef}
          className="min-w-0 flex-1 border-0 bg-transparent px-1 py-1 text-sm focus:ring-0"
          value={draft}
          onBlur={commitTitle}
          onChange={(event) => setDraft(event.target.value)}
          onKeyDown={(event) => {
            if (event.key === "Enter") event.currentTarget.blur();
            if (event.key === "Escape") {
              setDraft(todo.title);
              event.currentTarget.blur();
            }
          }}
          aria-label="Todo title"
        />
        {todo.dueDate && (
          <span className="hidden text-2xs text-[var(--t6)] sm:inline">{todo.dueDate}</span>
        )}
        <select
          className="h-7 w-28 rounded border-[var(--t3)] bg-[var(--t0)] py-0 pl-2 pr-6 text-2xs focus:ring-0"
          value={todo.status}
          onChange={(event) => onUpdate(todo.id, { status: event.target.value as TodoStatus })}
          aria-label={`Status for ${todo.title}`}
        >
          {TODO_STATUSES.map((status) => <option key={status}>{status}</option>)}
        </select>
        <div className="flex items-center opacity-30 transition-opacity group-hover:opacity-100 group-focus-within:opacity-100">
          {(["outdent", "indent", "up", "down"] as const).map((direction) => (
            <button
              key={direction}
              className="h-7 w-6 rounded text-xs hover:bg-[var(--t2)] disabled:opacity-20"
              disabled={!canMove(direction)}
              onClick={() => move(direction)}
              title={direction}
              aria-label={`${direction} ${todo.title}`}
              type="button"
            >
              {{ outdent: "←", indent: "→", up: "↑", down: "↓" }[direction]}
            </button>
          ))}
          <button
            className="h-7 w-6 rounded text-sm hover:bg-[var(--t2)]"
            onClick={() => {
              setCollapsed(false);
              onAddChild(todo);
            }}
            title="Add child"
            aria-label={`Add child under ${todo.title}`}
            type="button"
          >+</button>
          <button
            className={`h-7 w-6 rounded text-sm hover:bg-[var(--t2)] ${detailsOpen ? "bg-[var(--t2)]" : ""}`}
            onClick={() => setDetailsOpen((value) => !value)}
            title="Details"
            aria-label={`Details for ${todo.title}`}
            aria-expanded={detailsOpen}
            type="button"
          >…</button>
        </div>
      </div>
      {detailsOpen && (
        <div
          className="grid gap-2 border-b border-[var(--t2)] bg-[var(--t1)] p-2 sm:grid-cols-[9rem_1fr_auto]"
          style={{
            marginLeft: `${depth * TODO_INDENTATION_WIDTH + 26}px`,
          }}
        >
          <label className="text-2xs text-[var(--t6)]">
            Due date
            <input
              className="mt-1 block h-8 w-full rounded border-[var(--t3)] bg-[var(--t0)] px-2 text-xs focus:ring-0"
              type="date"
              value={todo.dueDate ?? ""}
              onChange={(event) => onUpdate(todo.id, { dueDate: event.target.value || null })}
            />
          </label>
          <label className="text-2xs text-[var(--t6)]">
            Notes
            <textarea
              ref={notesRef}
              className="mt-1 block min-h-8 w-full resize-y rounded border-[var(--t3)] bg-[var(--t0)] px-2 py-1 text-xs focus:ring-0"
              rows={1}
              value={notesDraft}
              onChange={(event) => setNotesDraft(event.target.value)}
              onBlur={() => {
                if (notesDraft !== todo.notes) onUpdate(todo.id, { notes: notesDraft });
              }}
            />
          </label>
          <button
            className="self-end rounded px-2 py-1.5 text-xs text-red-700 hover:bg-red-50"
            onClick={() => onDelete(todo)}
            type="button"
          >Delete</button>
        </div>
      )}
      {!collapsed && (
        <TodoBranch
          ancestors={nextAncestors}
          depth={depth + 1}
          parentId={todo.id}
          todos={todos}
          onAddChild={onAddChild}
          onDelete={onDelete}
          onMove={onMove}
          onUpdate={onUpdate}
          activeTodoId={activeTodoId}
          registerRow={registerRow}
        />
      )}
    </li>
  );
}

interface TodoBranchProps extends TreeRenderProps {
  parentId: string | null;
  depth: number;
  ancestors: ReadonlySet<string>;
}

function TodoBranch({ parentId, depth, ancestors, todos, ...actions }: TodoBranchProps) {
  const siblings = getSiblings(todos, parentId).filter((todo) => !ancestors.has(todo.id));
  if (siblings.length === 0) return null;
  return (
    <ul>
      {siblings.map((todo) => (
        <TodoNode
          key={todo.id}
          {...actions}
          ancestors={ancestors}
          depth={depth}
          todo={todo}
          todos={todos}
        />
      ))}
    </ul>
  );
}

export default function TodoTree(props: TodoTreeProps) {
  const [dragActive, setDragActive] = useState(false);
  const [activeTodoId, setActiveTodoId] = useState<string | null>(null);
  const propsRef = useRef(props);
  const rowElements = useRef(new Map<string, HTMLDivElement>());
  const pendingLayout = useRef<Map<string, DOMRect> | null>(null);
  const dragSnapshot = useRef<Todo[] | null>(null);
  const dragMove = useRef<{ todoId: string; move: MoveTodoInput } | null>(null);
  const initialPointerX = useRef(0);
  const lastTarget = useRef<ReturnType<typeof getTodoTarget>>(null);
  const [visualTree, setVisualTree] = useState(() => ({
    sourceTodos: props.todos,
    todos: props.todos,
  }));

  const registerRow = useCallback<RegisterRow>((todoId, element) => {
    if (element) rowElements.current.set(todoId, element);
    else rowElements.current.delete(todoId);
  }, []);

  useLayoutEffect(() => {
    const previousLayout = pendingLayout.current;
    pendingLayout.current = null;
    if (
      !previousLayout ||
      window.matchMedia("(prefers-reduced-motion: reduce)").matches
    ) {
      return;
    }

    for (const [todoId, element] of rowElements.current) {
      if (todoId === activeTodoId) continue;
      const previous = previousLayout.get(todoId);
      if (!previous) continue;
      const current = element.getBoundingClientRect();
      const x = previous.left - current.left;
      const y = previous.top - current.top;
      if (Math.abs(x) < 1 && Math.abs(y) < 1) continue;

      element.getAnimations().forEach((animation) => animation.cancel());
      element.animate(
        [
          { transform: `translate(${x}px, ${y}px)` },
          { transform: "translate(0, 0)" },
        ],
        { duration: 160, easing: "cubic-bezier(0.25, 1, 0.5, 1)" },
      );
    }
  }, [activeTodoId, visualTree.todos]);

  // Keep the projected and dropped order local so query reconciliation never
  // paints the previous order between the gesture and the optimistic mutation.
  let visibleTodos = visualTree.todos;
  if (!dragActive && visualTree.sourceTodos !== props.todos) {
    visibleTodos = props.todos;
    setVisualTree({ sourceTodos: props.todos, todos: props.todos });
  }
  const visibleTodosRef = useRef(visibleTodos);

  useLayoutEffect(() => {
    propsRef.current = props;
    visibleTodosRef.current = visibleTodos;
  }, [props, visibleTodos]);

  const captureLayout = useCallback(() => {
    pendingLayout.current = new Map(
      Array.from(rowElements.current, ([id, element]) => [
        id,
        element.getBoundingClientRect(),
      ]),
    );
  }, []);

  const moveVisually = (todoId: string, move: MoveTodoInput) => {
    captureLayout();
    setVisualTree({
      sourceTodos: props.todos,
      todos: applyMove(visibleTodos, todoId, move),
    });
    props.onMove(todoId, move);
  };

  const projectDrag = useCallback(
    (todoId: string, location: DragLocation) => {
      const currentTarget = getTodoTarget(location.dropTargets[0]);
      if (currentTarget) lastTarget.current = currentTarget;
      const target = currentTarget ?? lastTarget.current;
      if (!target) return null;

      const todos = dragSnapshot.current ?? visibleTodosRef.current;
      const movingTodo = todos.find((todo) => todo.id === todoId);
      const targetTodo = todos.find((todo) => todo.id === target.todoId);
      if (!movingTodo || !targetTodo) return null;

      const targetSiblings = getSiblings(todos, targetTodo.parentId);
      const targetIndex = targetSiblings.findIndex(
        (todo) => todo.id === targetTodo.id,
      );
      const sourceSiblings = getSiblings(todos, movingTodo.parentId);
      const sourceIndex = sourceSiblings.findIndex(
        (todo) => todo.id === movingTodo.id,
      );
      let destinationIndex = targetIndex + (target.edge === "bottom" ? 1 : 0);
      if (
        movingTodo.parentId === targetTodo.parentId &&
        sourceIndex < destinationIndex
      ) {
        destinationIndex -= 1;
      }

      return planProjectedMove(
        dragSnapshot.current ?? todos,
        todoId,
        targetTodo.parentId,
        destinationIndex,
        location.input.clientX - initialPointerX.current,
      );
    },
    [],
  );

  const previewDrag = useCallback(
    (todoId: string, location: DragLocation) => {
      const move = projectDrag(todoId, location);
      if (!move) {
        if (dragMove.current && dragSnapshot.current) {
          captureLayout();
          setVisualTree({
            sourceTodos: propsRef.current.todos,
            todos: dragSnapshot.current,
          });
        }
        dragMove.current = null;
        return;
      }

      const previous = dragMove.current;
      if (
        previous?.todoId === todoId &&
        previous.move.parentId === move.parentId &&
        previous.move.previousId === move.previousId &&
        previous.move.nextId === move.nextId
      ) {
        return;
      }

      dragMove.current = { todoId, move };
      captureLayout();
      setVisualTree({
        sourceTodos: propsRef.current.todos,
        todos: applyMove(dragSnapshot.current ?? visibleTodosRef.current, todoId, move),
      });
    },
    [captureLayout, projectDrag],
  );

  useEffect(
    () =>
      monitorForElements({
        canMonitor: ({ source }) => isTodoDragData(source.data),
        onDragStart: ({ source, location }) => {
          if (!isTodoDragData(source.data)) return;
          dragSnapshot.current = visibleTodosRef.current;
          dragMove.current = null;
          lastTarget.current = null;
          initialPointerX.current = location.initial.input.clientX;
          setActiveTodoId(source.data.todoId);
          setDragActive(true);
        },
        onDropTargetChange: ({ source, location }) => {
          if (isTodoDragData(source.data)) {
            previewDrag(source.data.todoId, location.current);
          }
        },
        onDrag: ({ source, location }) => {
          if (isTodoDragData(source.data)) {
            previewDrag(source.data.todoId, location.current);
          }
        },
        onDrop: ({ source, location }) => {
          if (!isTodoDragData(source.data)) return;
          const todoId = source.data.todoId;
          const hasDropTarget = location.current.dropTargets.length > 0;
          if (hasDropTarget) previewDrag(todoId, location.current);
          const committed = hasDropTarget ? dragMove.current : null;
          const snapshot = dragSnapshot.current ?? propsRef.current.todos;

          setActiveTodoId(null);
          setDragActive(false);
          dragSnapshot.current = null;
          dragMove.current = null;
          lastTarget.current = null;

          if (committed) {
            propsRef.current.onMove(committed.todoId, committed.move);
          } else {
            captureLayout();
            setVisualTree({
              sourceTodos: propsRef.current.todos,
              todos: snapshot,
            });
          }
        },
      }),
    [captureLayout, previewDrag],
  );

  return (
    <>
      <TodoBranch
        {...props}
        activeTodoId={activeTodoId}
        ancestors={new Set()}
        depth={0}
        parentId={null}
        registerRow={registerRow}
        todos={visibleTodos}
        onMove={moveVisually}
      />
    </>
  );
}

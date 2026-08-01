import { DragDropProvider } from "@dnd-kit/react";
import { Feedback } from "@dnd-kit/dom";
import {
  isSortable,
  OptimisticSortingPlugin,
} from "@dnd-kit/dom/sortable";
import {
  type UseSortableInput,
  useSortable,
} from "@dnd-kit/react/sortable";
import { type ComponentProps, useEffect, useRef, useState } from "react";
import {
  TODO_STATUSES,
  type MoveTodoInput,
  type Todo,
  type TodoStatus,
  type UpdateTodoInput,
} from "./shared/domain";
import {
  applyMove,
  destinationIndexFromTarget,
  getSiblings,
  groupForParent,
  parentForGroup,
  planDirectionalMove,
  planProjectedMove,
  TODO_INDENTATION_WIDTH,
  type MoveDirection,
} from "./tree";

type DragDropPlugins = NonNullable<
  ComponentProps<typeof DragDropProvider>["plugins"]
>;

const configureDragFeedback: DragDropPlugins = (defaults) => [
  ...defaults,
  Feedback.configure({ dropAnimation: null }),
];

type SortablePluginCustomizer = Exclude<
  NonNullable<UseSortableInput["plugins"]>,
  unknown[]
>;

const withoutOptimisticDomSorting: SortablePluginCustomizer = (defaults) =>
  defaults.filter((entry) => {
    const plugin = typeof entry === "function" ? entry : entry.plugin;
    return plugin !== OptimisticSortingPlugin;
  });

interface TodoTreeProps {
  todos: Todo[];
  onAddChild: (todo: Todo) => void;
  onDelete: (todo: Todo) => void;
  onMove: (todoId: string, move: MoveTodoInput) => void;
  onUpdate: (todoId: string, update: Omit<UpdateTodoInput, "version">) => void;
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
  onDelete,
  onMove,
  onUpdate,
}: TodoNodeProps) {
  const [draft, setDraft] = useState(todo.title);
  const [notesDraft, setNotesDraft] = useState(todo.notes);
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);
  const notesRef = useRef<HTMLTextAreaElement>(null);
  const { ref, handleRef, isDragging } = useSortable({
    id: todo.id,
    index,
    group: groupForParent(todo.parentId),
    plugins: withoutOptimisticDomSorting,
  });

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
    <li ref={ref} className={isDragging ? "opacity-40" : undefined}>
      <div
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
        />
      )}
    </li>
  );
}

interface TodoBranchProps extends TodoTreeProps {
  parentId: string | null;
  depth: number;
  ancestors: ReadonlySet<string>;
}

function TodoBranch({ parentId, depth, ancestors, todos, ...actions }: TodoBranchProps) {
  const siblings = getSiblings(todos, parentId).filter((todo) => !ancestors.has(todo.id));
  if (siblings.length === 0) return null;
  return (
    <ul>
      {siblings.map((todo, index) => (
        <TodoNode
          key={todo.id}
          {...actions}
          ancestors={ancestors}
          depth={depth}
          index={index}
          todo={todo}
          todos={todos}
        />
      ))}
    </ul>
  );
}

export default function TodoTree(props: TodoTreeProps) {
  const [dragActive, setDragActive] = useState(false);
  const [visualTree, setVisualTree] = useState(() => ({
    sourceTodos: props.todos,
    todos: props.todos,
  }));

  // DnD releases its temporary layout before React Query notifies subscribers.
  // Keep the dropped order locally so the old order is never painted in between.
  let visibleTodos = visualTree.todos;
  if (!dragActive && visualTree.sourceTodos !== props.todos) {
    visibleTodos = props.todos;
    setVisualTree({ sourceTodos: props.todos, todos: props.todos });
  }

  const moveVisually = (todoId: string, move: MoveTodoInput) => {
    setVisualTree({
      sourceTodos: props.todos,
      todos: applyMove(visibleTodos, todoId, move),
    });
    props.onMove(todoId, move);
  };

  return (
    <DragDropProvider
      plugins={configureDragFeedback}
      onDragStart={() => {
        setDragActive(true);
      }}
      onDragEnd={(event) => {
        setDragActive(false);
        if (event.canceled) {
          setVisualTree({ sourceTodos: props.todos, todos: props.todos });
          return;
        }
        const source = event.operation.source;
        const target = event.operation.target;
        if (!isSortable(source) || !isSortable(target)) return;
        const todoId = String(source.id);
        if (target.id === source.id) return;

        const dragCenter =
          event.operation.shape?.current.center ??
          event.operation.position.current;
        const belowTarget = target.shape
          ? dragCenter.y > target.shape.center.y
          : false;
        const destinationIndex = destinationIndexFromTarget(
          target.index,
          belowTarget,
          source.initialGroup === target.group,
          source.initialIndex,
        );

        const move = planProjectedMove(
          visibleTodos,
          todoId,
          parentForGroup(target.group),
          destinationIndex,
          event.operation.position.current.x -
            event.operation.position.initial.x,
        );
        if (move) moveVisually(todoId, move);
      }}
    >
      <TodoBranch
        {...props}
        ancestors={new Set()}
        depth={0}
        parentId={null}
        todos={visibleTodos}
        onMove={moveVisually}
      />
    </DragDropProvider>
  );
}

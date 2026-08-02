import * as DropdownMenu from "@radix-ui/react-dropdown-menu";
import {
  TODO_STATUSES,
  type TodoStatus,
} from "./shared/domain";

interface StatusSelectProps {
  value: TodoStatus;
  onChange: (value: TodoStatus) => void;
  todoTitle: string;
}

const STATUS_LABELS: Record<TodoStatus, string> = {
  Unsorted: "Unsorted",
  Future: "Future",
  NowIfTime: "Now If Time",
  NowMustDo: "Now Must Do",
  Underway: "Underway",
  Paused: "Paused",
  ResolveDone: "Resolve Done",
  ResolveNo: "Resolve No",
};

const STATUS_COLORS: Record<TodoStatus, string> = {
  Unsorted: "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-200",
  Future: "bg-violet-100 text-violet-700 dark:bg-violet-950 dark:text-violet-200",
  NowIfTime: "bg-cyan-100 text-cyan-700 dark:bg-cyan-950 dark:text-cyan-200",
  NowMustDo: "bg-orange-100 text-orange-700 dark:bg-orange-950 dark:text-orange-200",
  Underway: "bg-blue-100 text-blue-700 dark:bg-blue-950 dark:text-blue-200",
  Paused: "bg-yellow-100 text-yellow-700 dark:bg-yellow-950 dark:text-yellow-200",
  ResolveDone: "bg-green-100 text-green-700 dark:bg-green-950 dark:text-green-200",
  ResolveNo: "bg-rose-100 text-rose-700 dark:bg-rose-950 dark:text-rose-200",
};

export default function StatusSelect({
  value,
  onChange,
  todoTitle,
}: StatusSelectProps) {
  return (
    <DropdownMenu.Root modal={false}>
      <DropdownMenu.Trigger asChild>
        <button
          className={`flex h-7 min-w-28 items-center justify-between gap-2 rounded px-2 text-2xs font-medium outline-none transition-shadow hover:ring-1 hover:ring-current focus-visible:ring-2 focus-visible:ring-blue-500 ${STATUS_COLORS[value]}`}
          aria-label={`Status for ${todoTitle}: ${STATUS_LABELS[value]}`}
          type="button"
        >
          <span>{STATUS_LABELS[value]}</span>
          <span aria-hidden="true" className="text-[0.55rem] opacity-60">▼</span>
        </button>
      </DropdownMenu.Trigger>

      <DropdownMenu.Portal>
        <DropdownMenu.Content
          className="z-50 grid w-64 grid-cols-2 gap-1 rounded-lg border border-[var(--t3)] bg-[var(--t0)] p-1 shadow-lg outline-none"
          side="bottom"
          align="end"
          sideOffset={5}
          collisionPadding={8}
          aria-label={`Choose status for ${todoTitle}`}
        >
          <DropdownMenu.RadioGroup
            value={value}
            onValueChange={(status) => onChange(status as TodoStatus)}
            className="contents"
          >
            {TODO_STATUSES.map((status) => (
              <DropdownMenu.RadioItem
                key={status}
                value={status}
                className={`relative flex h-8 cursor-default select-none items-center rounded px-2 pr-7 text-2xs font-medium outline-none transition-shadow data-[highlighted]:ring-2 data-[highlighted]:ring-blue-500 ${STATUS_COLORS[status]}`}
              >
                {STATUS_LABELS[status]}
                <DropdownMenu.ItemIndicator className="absolute right-2" aria-hidden="true">
                  ✓
                </DropdownMenu.ItemIndicator>
              </DropdownMenu.RadioItem>
            ))}
          </DropdownMenu.RadioGroup>
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
}

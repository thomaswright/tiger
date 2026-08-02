import * as DropdownMenu from "@radix-ui/react-dropdown-menu";
import { useState } from "react";
import Calendar from "./Calendar";
import { formatDateValue, parseDateValue } from "./date";
import { TbCalendar } from "react-icons/tb";

interface DateSelectProps {
  value: string | null;
  onChange: (value: string | null) => void;
  className?: string;
}

const shortDateFormatter = new Intl.DateTimeFormat(undefined, {
  month: "short",
  day: "numeric",
});
const longDateFormatter = new Intl.DateTimeFormat(undefined, {
  month: "long",
  day: "numeric",
  year: "numeric",
});

export default function DateSelect({
  value,
  onChange,
  className = "",
}: DateSelectProps) {
  const [open, setOpen] = useState(false);
  const selectedDate = parseDateValue(value);

  return (
    <DropdownMenu.Root open={open} onOpenChange={setOpen} modal={false}>
      <DropdownMenu.Trigger asChild>
        <button
          className={`flex h-7 min-w-14 items-center justify-center rounded px-2 text-2xs font-medium text-[var(--t8)] hover:bg-[var(--t2)] ${className}`}
          aria-label={
            selectedDate
              ? `Due ${longDateFormatter.format(selectedDate)}`
              : "Set due date"
          }
          type="button"
        >
          {selectedDate ? (
            shortDateFormatter.format(selectedDate)
          ) : (
            <TbCalendar aria-hidden="true" className="h-4 w-4" />
          )}
        </button>
      </DropdownMenu.Trigger>

      <DropdownMenu.Portal>
        <DropdownMenu.Content
          className="z-50 rounded-lg bg-[var(--t0)] outline-none"
          side="bottom"
          align="end"
          sideOffset={5}
          collisionPadding={8}
        >
          <Calendar
            value={selectedDate}
            onChange={(date) => {
              onChange(date ? formatDateValue(date) : null);
              setOpen(false);
            }}
          />
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
}

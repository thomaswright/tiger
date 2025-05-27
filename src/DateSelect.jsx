import React, { useRef } from "react";
import * as DropdownMenu from "@radix-ui/react-dropdown-menu";
import Calendar from "./Calendar.res.mjs";
import { format } from "date-fns";
const DateSelect = ({ value, onClick, className }) => {
  let [isOpen, setIsOpen] = React.useState(false);
  return (
    <DropdownMenu.Root
      modal={false}
      open={isOpen}
      onOpenChange={(v) => setIsOpen(v)}
    >
      <DropdownMenu.Trigger asChild>
        <button
          className={[
            Boolean(value)
              ? "justify-start h-4 "
              : "justify-center bg-[var(--t2)] h-5",
            isOpen
              ? "text-[var(--t9)] "
              : Boolean(value)
              ? "text-[var(--t9)] "
              : "text-[var(--t9)] ",
            "w-10 rounded text-2xs font-medium flex flex-row flex-none items-center ",
            className,
          ].join(" ")}
        >
          {Boolean(value) ? format(value, "MMM d") : "Date"}
        </button>
      </DropdownMenu.Trigger>

      <DropdownMenu.Portal>
        <DropdownMenu.Content
          onEscapeKeyDown={(_) => focusTodo()}
          className="DropdownMenuContent"
          sideOffset={5}
          side="bottom"
        >
          <Calendar
            value={value}
            onClick={(v) => {
              setIsOpen(false);
              onClick(v);
            }}
          />
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
};

export default DateSelect;

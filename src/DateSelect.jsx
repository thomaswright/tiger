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
            Boolean(value) ? "text-[var(--t6)] " : "text-[var(--t3)] ",
            "w-10 h-5 text-xs rounded-lg font-medium",
            className,
          ].join(" ")}
        >
          {Boolean(value) ? format(value, "M/d") : "-/-"}
        </button>
      </DropdownMenu.Trigger>

      <DropdownMenu.Portal>
        <DropdownMenu.Content
          onEscapeKeyDown={(_) => focusTodo()}
          className="DropdownMenuContent"
          sideOffset={5}
          side="right"
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

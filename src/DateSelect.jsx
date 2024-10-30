import React, { useRef } from "react";
import * as DropdownMenu from "@radix-ui/react-dropdown-menu";
import Calendar from "./Calendar.res.mjs";

const DateSelect = ({ value, onClick }) => {
  let [isOpen, setIsOpen] = React.useState(false);
  return (
    <DropdownMenu.Root
      modal={false}
      open={isOpen}
      onOpenChange={(v) => setIsOpen(v)}
    >
      <DropdownMenu.Trigger asChild>
        <button>{"Date"}</button>
      </DropdownMenu.Trigger>

      <DropdownMenu.Portal>
        <DropdownMenu.Content
          onEscapeKeyDown={(_) => focusTodo()}
          className="DropdownMenuContent"
          sideOffset={5}
        >
          <Calendar value={value} onClick={onClick} />
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
};

export default DateSelect;

import React, { useRef } from "react";
import * as DropdownMenu from "@radix-ui/react-dropdown-menu";
import "./dropdown.css";
import {
  statusStringShort,
  statusString,
  isArchiveStatus,
} from "./Types.res.mjs";

const Dropdown = ({ status, setStatus, removeTodo }) => {
  let [hoverStatus, setHoverStatus] = React.useState(status);
  const item = (s) => {
    return (
      <DropdownMenu.Item
        key={s}
        className={[
          isArchiveStatus(s) ? "bg-[var(--foreground-200)]" : "",
          status === s ? "DropdownMenuItemSelected" : "DropdownMenuItem",
        ].join(" ")}
        onSelect={(_) =>
          s === "" ? {} : s === "Trash" ? removeTodo() : setStatus(s)
        }
        onFocus={(_) => setHoverStatus(s)}
        onMouseEnter={(_) => setHoverStatus(s)}
        onMouseLeave={(_) =>
          setHoverStatus((current) => (current === s ? status : s))
        }
      >
        {statusStringShort(s)}
      </DropdownMenu.Item>
    );
  };

  return (
    <DropdownMenu.Root modal={false}>
      <DropdownMenu.Trigger asChild>
        <button className="IconButton" aria-label="Customise options">
          {statusStringShort(status)}
        </button>
      </DropdownMenu.Trigger>

      <DropdownMenu.Portal>
        <DropdownMenu.Content className="DropdownMenuContent" sideOffset={5}>
          <div>
            <div className="h-6 font-bold flex flex-row items-center justify-center">
              <div className=" w-6 flex flex-row items-center justify-center">
                {statusStringShort(hoverStatus)}
              </div>
              <div>{statusString(hoverStatus)}</div>
            </div>
            <div className="grid grid-cols-4">
              {item("TodoUrgent")}
              {item("TodoHigh")}
              {item("TodoMedium")}
              {item("TodoLow")}
              {item("LaterUnsorted")}
              {item("LaterWill")}
              {item("LaterMaybe")}
              {item("LaterUnlikely")}
              {item("ResolveDone")}
              {item("ResolveReject")}
              {item("ResolveNoNeed")}
              {item("")}
              {item("ArchiveDone")}
              {item("ArchiveReject")}
              {item("ArchiveNoNeed")}
              {item("Trash")}
            </div>
          </div>

          <DropdownMenu.Arrow className="DropdownMenuArrow" />
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
};

export default Dropdown;

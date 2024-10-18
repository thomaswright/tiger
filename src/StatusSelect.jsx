import React, { useRef } from "react";
import * as DropdownMenu from "@radix-ui/react-dropdown-menu";
import "./dropdown.css";
import {
  statusStringShort,
  statusString,
  isArchiveStatus,
  statusColor,
  statusIcon,
} from "./Types.res.mjs";

const Dropdown = ({ status, setStatus, removeTodo }) => {
  let [hoverStatus, setHoverStatus] = React.useState(status);
  const item = (s) => {
    return (
      <DropdownMenu.Item
        key={s}
        style={{
          // borderColor: statusColor(s),
          // backgroundColor:
          //   status === s
          //     ? statusColor(s)
          //     : `oklch(from ${statusColor(s)} 0.95 calc(c / 3) h)`,
          // color: status === s ? "var(--t0)" : statusColor(s),
          color: "var(--t0)",
          backgroundColor:
            status === s
              ? statusColor(s)
              : `oklch(from ${statusColor(s)} 0.85 calc(c / 1.5) h)`,
        }}
        className={[
          status === s ? "" : "",
          ` rounded font-bold flex flex-row items-center justify-center 
          relative h-6 w-6 select-none `,
          isArchiveStatus(s) ? "bg-[var(--t2)]" : "",
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
        <button
          style={{
            // backgroundColor: statusColor(status),

            color: statusColor(status),
            backgroundColor: `oklch(from ${statusColor(
              status
            )} 0.95 calc(c / 3) h)`,
          }}
          className=" flex flex-row items-center text-sm justify-center w-5 h-5 font-bold rounded text-[var(--t0)]"
          aria-label="Customise options"
        >
          {statusStringShort(status)}
        </button>
      </DropdownMenu.Trigger>

      <DropdownMenu.Portal>
        <DropdownMenu.Content className="DropdownMenuContent" sideOffset={5}>
          <div>
            <div className="h-6 font-bold flex flex-row items-center justify-center">
              {/* <div className=" w-6 flex flex-row items-center justify-center">
                {statusStringShort(hoverStatus)}
              </div> */}
              <div>{statusString(hoverStatus)}</div>
            </div>
            <div className="flex flex-col gap-2 items-center pb-2 pt-1">
              <div className="flex flex-row gap-1">
                {item("TodoUrgent")}
                {item("TodoHigh")}
                {item("TodoMedium")}
                {item("TodoLow")}
              </div>
              <div className="flex flex-row gap-1">
                {item("LaterUnsorted")}
                {item("LaterWill")}
                {item("LaterMaybe")}
                {item("LaterUnlikely")}
              </div>

              <div className="flex flex-row gap-1">
                {item("ResolveDone")}
                {item("ResolveReject")}
                {item("ResolveNoNeed")}
                {item("")}
              </div>

              <div className="flex flex-row gap-1">
                {item("ArchiveDone")}
                {item("ArchiveReject")}
                {item("ArchiveNoNeed")}
                {item("Trash")}
              </div>
            </div>
          </div>

          <DropdownMenu.Arrow className="DropdownMenuArrow" />
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
};

export default Dropdown;

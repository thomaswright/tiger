import React, { useRef } from "react";
import * as DropdownMenu from "@radix-ui/react-dropdown-menu";
import "./dropdown.css";
import {
  statusStringShort,
  statusString,
  statusColor,
  statusColorText,
  // statusIcon,
} from "./Types.res.mjs";

const Dropdown = ({
  status,
  setStatus,
  removeTodo,
  focusTodo,
  isOpen,
  onOpenChange,
  containerRef,
}) => {
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
          // color: "var(--t0)",
          // backgroundColor:
          //   status === s
          //     ? statusColor(s)
          //     : `oklch(from ${statusColor(s)} 0.85 calc(c / 1.5) h)`,
          color: statusColorText(s),
          backgroundColor: statusColor(s),
        }}
        className={[
          status === s
            ? "outline outline-1 outline-inherit focus:outline-2 "
            : "focus:outline-2 focus:outline-inherit",
          ` rounded font-bold flex flex-row items-center justify-center 
          relative h-5 w-20 select-none `,
          // isArchiveStatus(s) ? "bg-[var(--t2)]" : "",
        ].join(" ")}
        onSelect={(_) => {
          if (s !== "") {
            if (s === "Trash") {
              removeTodo();
            } else {
              setStatus(s);
              focusTodo();
            }
          }
        }}
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
    <DropdownMenu.Root modal={false} open={isOpen} onOpenChange={onOpenChange}>
      <DropdownMenu.Trigger asChild>
        <button
          style={{
            // backgroundColor: statusColor(status),
            // color: "var(--t10)",
            backgroundColor: statusColor(status),
            color: statusColorText(status),
          }}
          className=" flex flex-row items-center text-sm justify-center w-20 h-5 font-bold rounded text-[var(--t0)]"
          aria-label="Customise options"
        >
          {statusStringShort(status)}
        </button>
      </DropdownMenu.Trigger>

      <DropdownMenu.Portal>
        <DropdownMenu.Content className="DropdownMenuContent" sideOffset={5}>
          <div className="p-1.5 pb-1">
            <div className="grid grid-cols-3 gap-1 ">
              {item("FutureSoon")}
              {item("FutureWillDo")}
              {item("FutureConsider")}

              {item("NowUrgent")}
              {item("NowWillDo")}
              {item("NowIfTime")}

              {item("Underway")}
              {item("UnderwayHalfDone")}
              {item("UnderwayWrapUp")}

              {item("ResolveDone")}
              {item("ResolveNo")}
              {item("ResolveScrap")}

              {item("Unsorted")}
            </div>
            <div className="h-5 font-bold flex flex-row items-center justify-center">
              {/* <div className=" w-6 flex flex-row items-center justify-center">
                {statusStringShort(hoverStatus)}
              </div> */}
              <div>{statusString(hoverStatus)}</div>
            </div>
          </div>

          {/* <DropdownMenu.Arrow className="DropdownMenuArrow" /> */}
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
};

export default Dropdown;

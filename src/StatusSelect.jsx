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

import {
  TbPin as Pin,
  TbArchive as Archive,
  // statusIcon,
} from "react-icons/tb";

let buttonBase =
  "relative flex flex-row items-center justify-center text-2xs font-bold  tracking-wide w-16 h-5  rounded ";

const Dropdown = ({
  status,
  setStatus,
  removeTodo,
  focusTodo,
  isOpen,
  onOpenChange,
  isPinned,
  isArchived,
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
          buttonBase,
          "select-none",
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
        {Boolean(status) ? (
          <button
            style={{
              // backgroundColor: statusColor(status),
              // color: "var(--t10)",
              borderColor: `oklch(from ${statusColor(
                status
              )} calc(l - 0.05) c h)`,
              backgroundColor: statusColor(status),
              color: statusColorText(status),
            }}
            onFocus={(e) => {
              if (!isOpen) {
                focusTodo();
              }
            }}
            className={buttonBase}
            aria-label="Customise options"
          >
            {statusStringShort(status)}
            {isPinned && (
              <div
                style={{
                  backgroundColor: statusColor(status),
                  color: statusColorText(status),
                  borderColor: statusColorText(status),
                }}
                className=" text-xs absolute right-0.5  w-3.5 h-3.5 items-center justify-center flex flex-row "
              >
                <Pin />
              </div>
            )}
            {isArchived && (
              <div
                style={{
                  backgroundColor: statusColor(status),
                  color: statusColorText(status),
                  borderColor: statusColorText(status),
                }}
                className="text-xs absolute right-0.5  w-3.5 h-3.5 items-center justify-center flex flex-row "
              >
                <Archive />
              </div>
            )}
          </button>
        ) : (
          <button
            style={{
              backgroundColor: "var(--t2)",
              color: "var(--t8)",
            }}
            className={buttonBase}
            aria-label="Customise options"
          >
            {"Mixed"}
          </button>
        )}
      </DropdownMenu.Trigger>

      <DropdownMenu.Portal>
        <DropdownMenu.Content
          onEscapeKeyDown={(_) => focusTodo()}
          className="DropdownMenuContent"
          sideOffset={5}
        >
          <div className="p-1.5 pb-1">
            <div className="grid grid-cols-2 gap-1 ">
              {item("Unsorted")}

              {/* {item("FutureSoon")} */}
              {item("FutureWillDo")}
              {/* {item("FutureConsider")} */}

              {item("NowWillDo")}
              {item("NowUrgent")}
              {/* {item("NowIfTime")} */}

              {item("Underway")}
              {/* {item("UnderwayWrapUp")} */}
              {item("Suspended")}

              {item("ResolveDone")}
              {item("ResolveNo")}
              {/* {item("ResolveScrap")} */}
            </div>
            <div className="h-5 font-bold flex flex-row items-center justify-center">
              {/* <div className=" w-6 flex flex-row items-center justify-center">
                {statusStringShort(hoverStatus)}
              </div> */}
              <div>
                {Boolean(hoverStatus) ? statusString(hoverStatus) : "Mixed"}
              </div>
            </div>
          </div>

          {/* <DropdownMenu.Arrow className="DropdownMenuArrow" /> */}
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
};

export default Dropdown;

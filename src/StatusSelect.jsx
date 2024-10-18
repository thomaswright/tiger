import React, { useRef } from "react";
import * as DropdownMenu from "@radix-ui/react-dropdown-menu";
import "./dropdown.css";
import {
  statusStringShort,
  statusString,
  statusColor,
  // statusIcon,
} from "./Types.res.mjs";

const Dropdown = ({ status, setStatus, removeTodo, focusTodo }) => {
  let [hoverStatus, setHoverStatus] = React.useState(status);
  const item = (s) => {
    console.log(s, statusColor(s));
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
          color: statusColor(s),
          backgroundColor: `oklch(from ${statusColor(s)} 0.95 calc(c / 3) h)`,
        }}
        className={[
          status === s ? "outline outline-2 outline-blue-600" : "",
          ` rounded font-bold flex flex-row items-center justify-center 
          relative h-5 w-10 select-none `,
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
          className=" flex flex-row items-center text-sm justify-center w-10 h-5 font-bold rounded text-[var(--t0)]"
          aria-label="Customise options"
        >
          {statusStringShort(status)}
        </button>
      </DropdownMenu.Trigger>

      <DropdownMenu.Portal>
        <DropdownMenu.Content className="DropdownMenuContent" sideOffset={5}>
          <div>
            <div className="flex flex-col gap-1 items-center pt-2 pb-1">
              <div className="flex flex-row gap-1">
                {item("Urgent")}
                {item("High")}
                {item("Medium")}
                {item("Low")}
              </div>
              <div className="flex flex-row gap-1">
                {item("Unsorted")}
                {item("Will")}
                {item("Maybe")}
                {item("Unlikely")}
              </div>

              <div className="flex flex-row gap-1">
                {item("Done")}
                {item("Rejected")}
                {item("Closed")}
                {item("")}
              </div>
            </div>
            <div className="h-6 font-bold flex flex-row items-center justify-center">
              {/* <div className=" w-6 flex flex-row items-center justify-center">
                {statusStringShort(hoverStatus)}
              </div> */}
              <div>{statusString(hoverStatus)}</div>
            </div>
          </div>

          <DropdownMenu.Arrow className="DropdownMenuArrow" />
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
};

export default Dropdown;

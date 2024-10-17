import React, { useRef } from "react";
import * as DropdownMenu from "@radix-ui/react-dropdown-menu";
import "./dropdown.css";
import { statusStringShort, statusString } from "./Types.res.mjs";

const Dropdown = ({ status, setStatus, removeTodo }) => {
  let [hoverStatus, setHoverStatus] = React.useState(status);
  const item = (s) => {
    return (
      <DropdownMenu.Item
        key={s}
        className={[
          status === s ? "DropdownMenuItemSelected" : "DropdownMenuItem",
        ].join(" ")}
        onSelect={(_) => (s === "Trash" ? removeTodo() : setStatus(s))}
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
    <DropdownMenu.Root modal={false} open={true}>
      <DropdownMenu.Trigger asChild>
        <button className="IconButton" aria-label="Customise options">
          {statusStringShort(status)}
        </button>
      </DropdownMenu.Trigger>

      <DropdownMenu.Portal>
        <DropdownMenu.Content className="DropdownMenuContent" sideOffset={5}>
          <div className="flex flex-col justify-between gap-1 py-1">
            <div className="h-5 font-bold flex flex-row items-center ">
              <div className=" w-6 flex flex-row items-center justify-center">
                {statusStringShort(hoverStatus)}
              </div>
              <div>{statusString(hoverStatus)}</div>
            </div>
            <div className="flex flex-row gap-1 flex-1 px-1 justify-start">
              <div
                className="flex-none font-bold w-12 leading-none text-xs
               flex flex-row items-center justify-start "
              >
                {"Todo"}
              </div>
              <div className="flex flex-row flex-1 divide-x border rounded overflow-hidden w-fit">
                {item("TodoUrgent")}
                {item("TodoHigh")}
                {item("TodoMedium")}
                {item("TodoLow")}
              </div>
            </div>
            <div className="flex flex-row gap-1 flex-1 px-1 justify-start">
              <div
                className="flex-none font-bold w-12 leading-none text-xs 
              flex flex-row items-center justify-start "
              >
                {"Later"}
              </div>
              <div className="flex flex-row flex-1 divide-x border rounded overflow-hidden w-fit">
                {item("LaterUnsorted")}
                {item("LaterWill")}
                {item("LaterMaybe")}
                {item("LaterUnlikely")}
              </div>
            </div>
            <div className="flex flex-row gap-1 flex-1 px-1 justify-start ">
              <div
                className="flex-none font-bold w-12 leading-none text-xs 
              flex flex-row items-center justify-start "
              >
                {"Resolve"}
              </div>
              <div className="flex flex-row  divide-x border rounded overflow-hidden w-fit">
                {item("ResolveDone")}
                {item("ResolveReject")}
                {item("ResolveNoNeed")}
              </div>
            </div>
            <div className=" flex flex-row gap-1 flex-1 px-1 justify-start ">
              <div
                className="flex-none font-bold w-12 leading-none text-xs 
              flex flex-row items-center justify-start "
              >
                {"Archive"}
              </div>
              <div className="flex flex-row  divide-x border rounded overflow-hidden w-fit">
                {item("ArchiveDone")}
                {item("ArchiveReject")}
                {item("ArchiveNoNeed")}
              </div>

              <div className="bg-white rounded border flex-1 flex justify-center items-center">
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

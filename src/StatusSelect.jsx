import React, { useRef } from "react";
import * as DropdownMenu from "@radix-ui/react-dropdown-menu";
// import {
//   TbChevronDown,
//   TbEye,
//   TbEyeClosed,
//   TbLock,
//   TbLockOpen2,
//   TbSun,
//   TbMoon,
// } from "react-icons/tb";
import "./dropdown.css";
import { statusStringShort } from "./Types.res.mjs";
const Dropdown = ({ status, setStatus }) => {
  const item = (s, t) => {
    return (
      <DropdownMenu.Item
        key={s}
        className={[
          status === s ? "DropdownMenuItemSelected" : "DropdownMenuItem",
        ].join(" ")}
        onSelect={(_) => setStatus(s)}
      >
        <span className="font-bold w-4">{statusStringShort(s)}</span>
        {t}
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
          <div className="flex flex-row justify-between gap-1 py-1">
            <div className="flex flex-row gap-1 flex-1 px-1">
              <div
                className="flex-none px-1 font-bold w-2 leading-none text-2xs
               flex flex-row items-center justify-center -rotate-90"
              >
                {"Todo"}
              </div>
              <div className="flex flex-col flex-1 divide-y border rounded overflow-hidden">
                {item("TodoUrgent", "Urgent")}
                {item("TodoHigh", "High")}
                {item("TodoMedium", "Medium")}
                {item("TodoLow", "Low")}
              </div>
            </div>
            <div className="flex flex-row gap-1 flex-1 px-1">
              <div
                className="flex-none px-1 font-bold w-2 leading-none text-2xs 
              flex flex-row items-center justify-center -rotate-90"
              >
                {"Later"}
              </div>
              <div className="flex flex-col flex-1 divide-y border rounded overflow-hidden">
                {item("LaterWill", "Will")}
                {item("LaterMaybe", "Maybe")}
                {item("LaterUnlikely", "Unlikely")}
                {item("LaterUnsorted", "Unsorted")}
              </div>
            </div>
          </div>
          <div className="flex flex-row justify-between gap-1 py-1">
            <div className="flex flex-row gap-1 flex-1 px-1 ">
              <div
                className="flex-none px-1 font-bold w-2 leading-none text-2xs 
              flex flex-row items-center justify-center -rotate-90"
              >
                {"Resolve"}
              </div>
              <div className="flex flex-col flex-1 divide-y border rounded overflow-hidden">
                {item("ResolveDone", "Done")}
                {item("ResolveWont", "Wont")}
                {item("ResolveNoNeed", "NoNeed")}
              </div>
            </div>
            <div className=" flex flex-row gap-1 flex-1 px-1 ">
              <div
                className="flex-none px-1 font-bold w-2 leading-none text-2xs 
              flex flex-row items-center justify-center -rotate-90"
              >
                {"Archive"}
              </div>
              <div className="flex flex-col flex-1 divide-y border rounded overflow-hidden">
                {item("ArchiveDone", "Done")}
                {item("ArchiveWont", "Wont")}
                {item("ArchiveNoNeed", "NoNeed")}
              </div>
            </div>
          </div>
          <div className="flex flex-row justify-between gap-1  pl-4 pr-1">
            <div className="bg-white rounded  px-1 border flex-1">
              {"Trash"}
            </div>
          </div>

          <DropdownMenu.Arrow className="DropdownMenuArrow" />
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
};

export default Dropdown;

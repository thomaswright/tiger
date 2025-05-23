import React, { useRef } from "react";
import * as DropdownMenu from "@radix-ui/react-dropdown-menu";
import "./dropdown.css";
import {
  statusString,
  statusColor,
  statusColorText,
  statusIcon,
} from "./Types.res.mjs";

import {
  TbArchive as Archive,
  TbBookmark as Bookmark,
  TbInbox as Inbox,

  // statusIcon,
} from "react-icons/tb";

let buttonBaseSmall =
  "flex-none relative flex flex-row items-center justify-center text-2xs font-medium  tracking-tighter w-4 h-4  rounded-sm ";

let buttonBaseLarge =
  "flex-none relative flex flex-row items-center justify-center text-2xs font-bold  tracking-tighter w-20 h-6 gap-1 rounded ";

const Dropdown = ({
  status,
  setStatus,
  removeTodo,
  focusTodo,
  isOpen,
  onOpenChange,
  mode,
  setMode,
}) => {
  const item = (s) => {
    return (
      <DropdownMenu.Item
        key={s}
        style={{
          color: statusColorText(s),
          backgroundColor: statusColor(s),
        }}
        className={[
          status === s
            ? "outline outline-1 outline-inherit focus:outline-2 "
            : "focus:outline-2 focus:outline-inherit",
          buttonBaseLarge,
          "select-none",
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
      >
        {statusIcon(s)}

        {statusString(s)}
        {(s == "ArchiveDone" || s == "ArchiveNo") && (
          <div
            style={{
              backgroundColor: statusColor(s),
              color: statusColorText(s),
              borderColor: statusColorText(s),
            }}
            className="text-xs absolute right-0.5  w-3.5 h-3.5 items-center justify-center flex flex-row "
          >
            <Archive />
          </div>
        )}
      </DropdownMenu.Item>
    );
  };

  return (
    <DropdownMenu.Root modal={false} open={isOpen} onOpenChange={onOpenChange}>
      <DropdownMenu.Trigger asChild>
        {Boolean(status) ? (
          <button
            style={{
              backgroundColor: statusColor(status),
              color: statusColorText(status),
            }}
            onFocus={(e) => {
              if (!isOpen) {
                focusTodo();
              }
            }}
            className={buttonBaseSmall}
            aria-label="Customise options"
          >
            {statusIcon(status)}
          </button>
        ) : (
          <button
            style={{
              backgroundColor: "var(--t2)",
              color: "var(--t8)",
            }}
            className={buttonBaseLarge}
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
          <div className="p-2">
            <div className="grid grid-cols-2 gap-2 ">
              {item("Unsorted")}
              {item("Future")}
              {item("NowIfTime")}
              {item("NowMustDo")}
              {item("Underway")}
              {item("Paused")}
              {item("ResolveDone")}
              {item("ResolveNo")}
            </div>

            <div className="flex flex-row rounded justify-center pt-2 gap-2">
              <button
                onClick={(_) => {
                  setMode("Working");
                  focusTodo();
                }}
                className={[
                  mode == "Working" ? " text-[var(--t9)]" : "text-[var(--t3)]",
                  "w-6 h-6 flex flex-row items-center justify-center rounded",
                ].join(" ")}
              >
                <Inbox className="w-5 h-5" />
              </button>
              <button
                onClick={(_) => {
                  setMode("Stashed");
                  focusTodo();
                }}
                className={[
                  mode == "Stashed" ? "text-[var(--t9)]" : "text-[var(--t3)]",
                  "w-6 h-6 flex flex-row items-center justify-center rounded ",
                ].join(" ")}
              >
                <Bookmark className="w-5 h-5" />
              </button>
              <button
                onClick={(_) => {
                  setMode("Archive");
                  focusTodo();
                }}
                className={[
                  mode == "Archive" ? " text-[var(--t9)]" : "text-[var(--t3)]",
                  "w-6 h-6 flex flex-row items-center justify-center rounded",
                ].join(" ")}
              >
                <Archive className="w-5 h-5" />
              </button>
            </div>
          </div>
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
};

export default Dropdown;

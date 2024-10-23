// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Types from "./Types.res.mjs";
import * as React from "react";
import * as Common from "./Common.res.mjs";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as Tb from "react-icons/tb";
import * as JsxRuntime from "react/jsx-runtime";
import ReactTextareaAutosize from "react-textarea-autosize";

function DisplayTodo(props) {
  var deleteTodo = props.deleteTodo;
  var setTodos = props.setTodos;
  var updateTodo = props.updateTodo;
  var setFocusIdNext = props.setFocusIdNext;
  var todo = props.todo;
  var project = props.project;
  var match = React.useState(function () {
        return false;
      });
  var setStatusSelectIsOpen = match[1];
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsx("div", {
                      children: JsxRuntime.jsx(ReactTextareaAutosize, {
                            className: [" flex-1 bg-inherit text-[--t10] w-full outline-none \n          focus:ring-0\n          font-medium \n           border-none p-0 my-1 mx-2"].join(" "),
                            id: "id-display-title",
                            style: {
                              resize: "none"
                            },
                            placeholder: "Todo",
                            value: todo.text,
                            onKeyDown: (function (e) {
                                if (e.key === "Escape") {
                                  return setFocusIdNext(function (param) {
                                              return Types.getTodoId(todo.id);
                                            });
                                }
                                
                              }),
                            onChange: (function (e) {
                                updateTodo(project.id, todo.id, (function (t) {
                                        return {
                                                id: t.id,
                                                text: e.target.value,
                                                project: t.project,
                                                status: t.status,
                                                box: t.box,
                                                parentTodo: t.parentTodo,
                                                depth: t.depth,
                                                childNumber: t.childNumber,
                                                hasArchivedChildren: t.hasArchivedChildren,
                                                hasChildren: t.hasChildren
                                              };
                                      }));
                              })
                          })
                    }),
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsx(Common.StatusSelect.make, {
                              status: todo.status,
                              setStatus: (function (newStatus) {
                                  updateTodo(project.id, todo.id, (function (t) {
                                          return {
                                                  id: t.id,
                                                  text: t.text,
                                                  project: t.project,
                                                  status: newStatus,
                                                  box: t.box === "Archive" && !Types.statusIsResolved(newStatus) ? "Working" : t.box,
                                                  parentTodo: t.parentTodo,
                                                  depth: t.depth,
                                                  childNumber: t.childNumber,
                                                  hasArchivedChildren: t.hasArchivedChildren,
                                                  hasChildren: t.hasChildren
                                                };
                                        }));
                                }),
                              focusTodo: (function () {
                                  
                                }),
                              isOpen: match[0],
                              isPinned: todo.box === "Pinned",
                              isArchived: todo.box === "Archive",
                              onOpenChange: (function (v) {
                                  setStatusSelectIsOpen(function (param) {
                                        return v;
                                      });
                                })
                            }),
                        JsxRuntime.jsx("div", {
                              className: "flex-1"
                            }),
                        Types.statusIsResolved(todo.status) ? JsxRuntime.jsx("button", {
                                children: JsxRuntime.jsx(Tb.TbArchive, {}),
                                className: [
                                    " px-1 h-6 flex flex-row items-center justify-center rounded border-[var(--t3)] gap-1\n          hover:text-blue-600\n          ",
                                    todo.box === "Archive" ? "text-blue-600" : "text-[var(--t4)]"
                                  ].join(" "),
                                onClick: (function (param) {
                                    setTodos(project.id, (function (v) {
                                            return v.map(function (t) {
                                                        if (t.id === todo.id) {
                                                          return {
                                                                  id: t.id,
                                                                  text: t.text,
                                                                  project: t.project,
                                                                  status: Types.statusIsResolved(t.status) ? t.status : "ResolveScrap",
                                                                  box: t.box !== "Archive" ? "Archive" : "Working",
                                                                  parentTodo: t.parentTodo,
                                                                  depth: t.depth,
                                                                  childNumber: t.childNumber,
                                                                  hasArchivedChildren: t.hasArchivedChildren,
                                                                  hasChildren: t.hasChildren
                                                                };
                                                        } else {
                                                          return t;
                                                        }
                                                      });
                                          }));
                                  })
                              }) : null,
                        Types.statusIsResolved(todo.status) ? JsxRuntime.jsx("button", {
                                children: JsxRuntime.jsx(Tb.TbPin, {}),
                                className: [
                                    " px-1 h-6 flex flex-row items-center justify-center rounded border-[var(--t3)]\n          hover:text-blue-600\n          ",
                                    todo.box === "Pinned" ? "text-blue-600" : "text-[var(--t4)]"
                                  ].join(" "),
                                onClick: (function (param) {
                                    setTodos(project.id, (function (v) {
                                            return v.map(function (t) {
                                                        if (t.id === todo.id) {
                                                          return {
                                                                  id: t.id,
                                                                  text: t.text,
                                                                  project: t.project,
                                                                  status: t.status,
                                                                  box: t.box !== "Pinned" ? "Pinned" : "Working",
                                                                  parentTodo: t.parentTodo,
                                                                  depth: t.depth,
                                                                  childNumber: t.childNumber,
                                                                  hasArchivedChildren: t.hasArchivedChildren,
                                                                  hasChildren: t.hasChildren
                                                                };
                                                        } else {
                                                          return t;
                                                        }
                                                      });
                                          }));
                                  })
                              }) : null,
                        JsxRuntime.jsx("button", {
                              children: JsxRuntime.jsx(Tb.TbTrash, {}),
                              className: ["\n          text-[var(--t4)] px-1 h-6 flex flex-row items-center justify-center rounded border-[var(--t3)]\n          hover:text-blue-600\n        "].join(" "),
                              onClick: (function (param) {
                                  Core__Option.mapOr(Caml_option.nullable_to_opt(document.getElementById(Types.getTodoId(todo.id))), undefined, (function (todoEl) {
                                          Common.focusPreviousClass(Types.listItemClass, todoEl);
                                        }));
                                  deleteTodo(project.id, todo);
                                })
                            })
                      ],
                      className: "flex flex-row border-y items-center gap-3 p-1 px-2"
                    })
              ]
            });
}

var make = DisplayTodo;

export {
  make ,
}
/* react Not a pure module */

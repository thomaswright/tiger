// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Types from "./Types.res.mjs";
import * as React from "react";
import * as Common from "./Common.res.mjs";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as JsxRuntime from "react/jsx-runtime";
import StatusSelectJsx from "./StatusSelect.jsx";

var make = StatusSelectJsx;

var StatusSelect = {
  make: make
};

var todoClass = "class-list-todo";

var todoInputClass = "class-list-todo-input";

function Project$Todo(props) {
  var setSelectElement = props.setSelectElement;
  var updateTodo = props.updateTodo;
  var todo = props.todo;
  var inputRef = React.useRef(null);
  var containerRef = React.useRef(null);
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsx(make, {
                      status: todo.status,
                      setStatus: (function (newStatus) {
                          updateTodo(todo.id, (function (todo) {
                                  return {
                                          id: todo.id,
                                          text: todo.text,
                                          project: todo.project,
                                          isDone: todo.isDone,
                                          status: newStatus
                                        };
                                }));
                        })
                    }),
                JsxRuntime.jsx("input", {
                      ref: Caml_option.some(inputRef),
                      className: [
                          todoInputClass,
                          " flex-1 bg-inherit text-[--foreground] w-full outline-none \n          leading-none padding-none border-none h-5 -my-1 focus:text-blue-500"
                        ].join(" "),
                      placeholder: "",
                      type: "text",
                      value: todo.text,
                      onKeyDown: (function (e) {
                          if (e.key === "Escape") {
                            e.preventDefault();
                            Core__Option.mapOr(Caml_option.nullable_to_opt(containerRef.current), undefined, (function (dom) {
                                    dom.focus();
                                  }));
                          }
                          Core__Option.mapOr(Caml_option.nullable_to_opt(inputRef.current), undefined, (function (dom) {
                                  var cursorPosition = Core__Option.getOr(Caml_option.nullable_to_opt(dom.selectionStart), 0);
                                  var inputValueLength = dom.value.length;
                                  if (e.key === "ArrowUp") {
                                    e.stopPropagation();
                                    if (cursorPosition === 0) {
                                      e.preventDefault();
                                      Common.focusPreviousClass(todoInputClass, dom);
                                    }
                                    
                                  }
                                  if (e.key === "ArrowDown") {
                                    e.stopPropagation();
                                    if (cursorPosition === inputValueLength) {
                                      e.preventDefault();
                                      return Common.focusNextClass(todoInputClass, dom);
                                    } else {
                                      return ;
                                    }
                                  }
                                  
                                }));
                        }),
                      onFocus: (function (param) {
                          setSelectElement(function (param) {
                                return {
                                        TAG: "Todo",
                                        _0: todo.id
                                      };
                              });
                        }),
                      onChange: (function (e) {
                          updateTodo(todo.id, (function (t) {
                                  return {
                                          id: t.id,
                                          text: e.target.value,
                                          project: t.project,
                                          isDone: t.isDone,
                                          status: t.status
                                        };
                                }));
                        })
                    })
              ],
              ref: Caml_option.some(containerRef),
              className: [
                  todoClass,
                  "flex flex-row justify-start items-center gap-2 px-2",
                  props.isSelected ? "bg-slate-100 outline outline-1 -outline-offset-1" : ""
                ].join(" "),
              tabIndex: 0,
              onKeyDown: (function (e) {
                  Core__Option.mapOr(Caml_option.nullable_to_opt(containerRef.current), undefined, (function (dom) {
                          if (e.key === "ArrowUp") {
                            e.preventDefault();
                            Common.focusPreviousClass(todoClass, dom);
                          }
                          if (e.key === "ArrowDown") {
                            e.preventDefault();
                            return Common.focusNextClass(todoClass, dom);
                          }
                          
                        }));
                }),
              onFocus: (function (param) {
                  setSelectElement(function (param) {
                        return {
                                TAG: "Todo",
                                _0: todo.id
                              };
                      });
                })
            });
}

var Todo = {
  todoClass: todoClass,
  todoInputClass: todoInputClass,
  make: Project$Todo
};

function Project(props) {
  var setSelectElement = props.setSelectElement;
  var selectElement = props.selectElement;
  var updateTodo = props.updateTodo;
  var updateProject = props.updateProject;
  var setShowArchive = props.setShowArchive;
  var showArchive = props.showArchive;
  var project = props.project;
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsx("div", {
                              children: project.name
                            }),
                        JsxRuntime.jsx("button", {
                              children: project.isActive ? "Active" : "Not Active",
                              className: "rounded bg-slate-200 w-20 text-xs h-fit",
                              onClick: (function (param) {
                                  updateProject(project.id, (function (p) {
                                          return {
                                                  id: p.id,
                                                  name: p.name,
                                                  isActive: !p.isActive
                                                };
                                        }));
                                })
                            }),
                        JsxRuntime.jsx("button", {
                              children: showArchive ? "^" : "v",
                              className: "text-xs rounded h-3 w-10",
                              onClick: (function (param) {
                                  setShowArchive(function (v) {
                                        if (v.includes(project.id)) {
                                          return v.filter(function (el) {
                                                      return el !== project.id;
                                                    });
                                        } else {
                                          return v.concat([project.id]);
                                        }
                                      });
                                })
                            })
                      ],
                      className: "flex flex-row justify-between items-center bg-slate-300"
                    }),
                JsxRuntime.jsx("div", {
                      children: JsxRuntime.jsx("div", {
                            children: props.todos.filter(function (todo) {
                                      if (showArchive) {
                                        return true;
                                      } else {
                                        return !Types.isArchiveStatus(todo.status);
                                      }
                                    }).toSorted(function (a, b) {
                                    return Types.statusToFloat(a.status) - Types.statusToFloat(b.status);
                                  }).map(function (todo) {
                                  return JsxRuntime.jsx(Project$Todo, {
                                              todo: todo,
                                              updateTodo: updateTodo,
                                              isSelected: Caml_obj.equal(selectElement, {
                                                    TAG: "Todo",
                                                    _0: todo.id
                                                  }),
                                              setSelectElement: setSelectElement
                                            });
                                }),
                            className: "flex flex-col divide-y "
                          })
                    })
              ],
              className: "border-y"
            });
}

var make$1 = Project;

export {
  StatusSelect ,
  Todo ,
  make$1 as make,
}
/* make Not a pure module */

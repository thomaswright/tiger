// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Types from "./Types.res.mjs";
import * as React from "react";
import * as Common from "./Common.res.mjs";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Array from "@rescript/core/src/Core__Array.res.mjs";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as Belt_MapString from "rescript/lib/es6/belt_MapString.js";
import * as Belt_SetString from "rescript/lib/es6/belt_SetString.js";
import * as Tb from "react-icons/tb";
import * as JsxRuntime from "react/jsx-runtime";
import ReactTextareaAutosize from "react-textarea-autosize";

function Todo(props) {
  var clearProjectLastRelative = props.clearProjectLastRelative;
  var itemToMoveHandleMouseEnter = props.itemToMoveHandleMouseEnter;
  var itemToMoveHandleMouseDown = props.itemToMoveHandleMouseDown;
  var deleteTodo = props.deleteTodo;
  var setChecked = props.setChecked;
  var isChecked = props.isChecked;
  var getTodos = props.getTodos;
  var newTodoAfter = props.newTodoAfter;
  var setFocusIdNext = props.setFocusIdNext;
  var setTodos = props.setTodos;
  var setDisplayElement = props.setDisplayElement;
  var isDisplayElement = props.isDisplayElement;
  var setSelectedElement = props.setSelectedElement;
  var isSelected = props.isSelected;
  var updateTodo = props.updateTodo;
  var todo = props.todo;
  var project = props.project;
  var match = React.useState(function () {
        return false;
      });
  var setStatusSelectIsOpen = match[1];
  var inputRef = React.useRef(null);
  var containerRef = React.useRef(null);
  var match$1 = React.useState(function () {
        return false;
      });
  var setStagedForDelete = match$1[1];
  var stagedForDelete = match$1[0];
  var focusContainer = function () {
    Common.mapNullable(containerRef.current, (function (dom) {
            dom.focus();
          }));
  };
  var indentation = function (e) {
    if (e.key === "Tab") {
      e.preventDefault();
    }
    if ((e.key === "Tab" && !e.shiftKey || e.key === "]" && e.metaKey) && Core__Option.mapOr(todo.childNumber, false, (function (childNumber) {
              return childNumber !== 0;
            }))) {
      e.preventDefault();
      var todos = getTodos();
      var newParent = todos.find(function (t) {
            if (Caml_obj.equal(t.parentTodo, todo.parentTodo)) {
              return Caml_obj.equal(t.childNumber, Core__Option.map(todo.childNumber, (function (c) {
                                return c - 1 | 0;
                              })));
            } else {
              return false;
            }
          });
      setTodos(project.id, (function (todos) {
              return todos.map(function (t) {
                          if (t.id === todo.id) {
                            return {
                                    id: t.id,
                                    text: t.text,
                                    additionalText: t.additionalText,
                                    project: t.project,
                                    status: t.status,
                                    parentTodo: Core__Option.map(newParent, (function (t) {
                                            return t.id;
                                          })),
                                    depth: t.depth,
                                    childNumber: t.childNumber,
                                    hasArchivedChildren: t.hasArchivedChildren,
                                    hasChildren: t.hasChildren,
                                    ancArchived: t.ancArchived,
                                    targetDate: t.targetDate
                                  };
                          } else if (Caml_obj.equal(t.parentTodo, todo.id)) {
                            return {
                                    id: t.id,
                                    text: t.text,
                                    additionalText: t.additionalText,
                                    project: t.project,
                                    status: t.status,
                                    parentTodo: Core__Option.map(newParent, (function (t) {
                                            return t.id;
                                          })),
                                    depth: t.depth,
                                    childNumber: t.childNumber,
                                    hasArchivedChildren: t.hasArchivedChildren,
                                    hasChildren: t.hasChildren,
                                    ancArchived: t.ancArchived,
                                    targetDate: t.targetDate
                                  };
                          } else {
                            return t;
                          }
                        });
            }));
    }
    if (!((e.key === "Tab" && e.shiftKey || e.key === "[" && e.metaKey) && todo.parentTodo !== undefined)) {
      return ;
    }
    e.preventDefault();
    var todos$1 = getTodos();
    var todoIndex = todos$1.findIndex(function (t) {
          return t.id === todo.id;
        });
    var todosGoingBack = todos$1.slice(0, todoIndex).toReversed();
    var todosGoingForward = todos$1.slice(todoIndex + 1 | 0);
    Core__Option.mapOr(todo.depth, undefined, (function (todoDepth) {
            var newChildren = {
              contents: []
            };
            var $$break = false;
            var i = 0;
            while(!$$break && i < todosGoingForward.length) {
              var t = todosGoingForward[i];
              if (Core__Option.mapOr(t.depth, false, (function (d) {
                        return d < todoDepth;
                      }))) {
                $$break = true;
              } else {
                if (Core__Option.mapOr(t.depth, false, (function (d) {
                          return d === todoDepth;
                        }))) {
                  newChildren.contents = newChildren.contents.concat([t.id]);
                }
                i = i + 1 | 0;
              }
            };
            var newParent = Core__Option.map(todosGoingBack.find(function (t) {
                      return Caml_obj.equal(t.depth, todoDepth - 2 | 0);
                    }), (function (t) {
                    return t.id;
                  }));
            setTodos(project.id, (function (todos) {
                    return todos.map(function (t) {
                                if (t.id === todo.id) {
                                  return {
                                          id: t.id,
                                          text: t.text,
                                          additionalText: t.additionalText,
                                          project: t.project,
                                          status: t.status,
                                          parentTodo: newParent,
                                          depth: t.depth,
                                          childNumber: t.childNumber,
                                          hasArchivedChildren: t.hasArchivedChildren,
                                          hasChildren: t.hasChildren,
                                          ancArchived: t.ancArchived,
                                          targetDate: t.targetDate
                                        };
                                } else if (newChildren.contents.includes(t.id)) {
                                  return {
                                          id: t.id,
                                          text: t.text,
                                          additionalText: t.additionalText,
                                          project: t.project,
                                          status: t.status,
                                          parentTodo: todo.id,
                                          depth: t.depth,
                                          childNumber: t.childNumber,
                                          hasArchivedChildren: t.hasArchivedChildren,
                                          hasChildren: t.hasChildren,
                                          ancArchived: t.ancArchived,
                                          targetDate: t.targetDate
                                        };
                                } else {
                                  return t;
                                }
                              });
                  }));
          }));
  };
  var onKeyDownContainer = function (e) {
    if (isSelected && Caml_obj.equal(Caml_option.nullable_to_opt(containerRef.current), Caml_option.nullable_to_opt(document.activeElement))) {
      return Common.mapNullable(containerRef.current, (function (dom) {
                    indentation(e);
                    if (e.key === "s") {
                      e.preventDefault();
                      setStatusSelectIsOpen(function (param) {
                            return true;
                          });
                    }
                    if (e.key === "ArrowUp") {
                      e.preventDefault();
                      Common.focusPreviousClass(Types.listItemClass, dom);
                    }
                    if (e.key === "ArrowDown") {
                      e.preventDefault();
                      Common.focusNextClass(Types.listItemClass, dom);
                    }
                    if (e.key === "Backspace" && e.metaKey) {
                      deleteTodo(project.id, todo);
                      Common.mapNullable(containerRef.current, (function (containerEl) {
                              Common.focusPreviousClass(Types.listItemClass, containerEl);
                            }));
                    }
                    if (e.key === "Backspace" && !e.metaKey) {
                      if (stagedForDelete) {
                        deleteTodo(project.id, todo);
                        Common.mapNullable(containerRef.current, (function (containerEl) {
                                Common.focusPreviousClass(Types.listItemClass, containerEl);
                              }));
                      } else {
                        setStagedForDelete(function (param) {
                              return true;
                            });
                      }
                    }
                    if (e.key === "Enter" && e.metaKey) {
                      newTodoAfter(todo.id, todo.hasChildren ? todo.id : todo.parentTodo);
                    }
                    if (e.key === "Enter") {
                      e.preventDefault();
                      Common.mapNullable(inputRef.current, (function (inputEl) {
                              inputEl.focus();
                              inputEl.selectionStart = Caml_option.nullable_to_opt(inputEl.selectionEnd);
                            }));
                    }
                    if (e.key === "Escape") {
                      if (stagedForDelete) {
                        return setStagedForDelete(function (param) {
                                    return false;
                                  });
                      } else {
                        setSelectedElement(function (param) {
                              
                            });
                        setDisplayElement(function (param) {
                              
                            });
                        dom.blur();
                        return ;
                      }
                    }
                    
                  }));
    }
    
  };
  var onKeyDownInput = function (e) {
    setStagedForDelete(function (param) {
          return false;
        });
    if (isSelected) {
      if (e.key === "Escape") {
        e.stopPropagation();
        focusContainer();
      }
      return Common.mapNullable(inputRef.current, (function (dom) {
                    indentation(e);
                    var cursorPosition = Core__Option.getOr(Caml_option.nullable_to_opt(dom.selectionStart), 0);
                    var inputValueLength = dom.value.length;
                    if (e.key === "ArrowUp") {
                      e.stopPropagation();
                      if (cursorPosition === 0) {
                        e.preventDefault();
                        focusContainer();
                      }
                      
                    }
                    if (e.key === "ArrowDown") {
                      e.stopPropagation();
                      if (cursorPosition === inputValueLength) {
                        e.preventDefault();
                        focusContainer();
                      }
                      
                    }
                    if (e.key === "Backspace" && inputValueLength === 0) {
                      if (stagedForDelete) {
                        deleteTodo(project.id, todo);
                        Common.mapNullable(containerRef.current, (function (containerEl) {
                                Common.focusPreviousClass(Types.listItemClass, containerEl);
                              }));
                      } else {
                        setStagedForDelete(function (param) {
                              return true;
                            });
                      }
                    }
                    if (e.key === "Enter" && cursorPosition === inputValueLength) {
                      e.preventDefault();
                      e.stopPropagation();
                      return newTodoAfter(todo.id, todo.hasChildren ? todo.id : todo.parentTodo);
                    }
                    
                  }));
    }
    
  };
  return JsxRuntime.jsxs("li", {
              children: [
                Core__Array.make(Core__Option.getOr(todo.depth, 0), false).map(function (param, i) {
                      return JsxRuntime.jsx("div", {
                                  className: "self-stretch w-2 border-l ml-2 border-[var(--t3)] "
                                }, i.toString());
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
                                                  additionalText: t.additionalText,
                                                  project: t.project,
                                                  status: newStatus,
                                                  parentTodo: t.parentTodo,
                                                  depth: t.depth,
                                                  childNumber: t.childNumber,
                                                  hasArchivedChildren: t.hasArchivedChildren,
                                                  hasChildren: t.hasChildren,
                                                  ancArchived: t.ancArchived,
                                                  targetDate: t.targetDate
                                                };
                                        }));
                                }),
                              focusTodo: (function () {
                                  setFocusIdNext(function (param) {
                                        return Types.getTodoId(todo.id);
                                      });
                                }),
                              isOpen: match[0],
                              onOpenChange: (function (v) {
                                  if (v) {
                                    return setStatusSelectIsOpen(function (param) {
                                                return v;
                                              });
                                  } else {
                                    return setStatusSelectIsOpen(function (param) {
                                                return v;
                                              });
                                  }
                                })
                            }),
                        JsxRuntime.jsxs("div", {
                              children: [
                                props.hideArchived && Core__Option.mapOr(Belt_MapString.get(project.hiddenTodos, todo.id), false, (function (hiddenTodos) {
                                        return hiddenTodos.length > 0;
                                      })) ? JsxRuntime.jsx("div", {
                                        children: JsxRuntime.jsx(Tb.TbArchive, {}),
                                        className: "absolute  text-[var(--darkPurple)] bg-[var(--lightPurple)] \n              text-xs h-3 w-3 -left-3 -top-0 flex flex-row items-center justify-center rounded-full"
                                      }) : null,
                                isSelected || isDisplayElement ? null : JsxRuntime.jsx("div", {
                                        className: "h-px w-full absolute bg-[var(--t2)] -bottom-0"
                                      }),
                                JsxRuntime.jsx(ReactTextareaAutosize, {
                                      ref: Caml_option.some(inputRef),
                                      className: [
                                          Types.todoInputClass,
                                          "mx-1 my-1 block text-sm font-medium  w-full h-5 border-0 pl-0 py-0 focus:ring-0 focus:z-10 text-[var(--t10)]",
                                          stagedForDelete ? "bg-red-200 dark:bg-red-950" : (
                                              isChecked ? "bg-sky-50 dark:bg-sky-950" : (
                                                  isDisplayElement && !isSelected ? "bg-sky-200 dark:bg-sky-900" : "bg-[var(--t0)]"
                                                )
                                            )
                                        ].join(" "),
                                      id: Types.getTodoInputId(todo.id),
                                      style: {
                                        resize: "none"
                                      },
                                      placeholder: "",
                                      value: todo.text,
                                      onKeyDown: onKeyDownInput,
                                      onFocus: (function (param) {
                                          setSelectedElement(function (param) {
                                                return {
                                                        TAG: "Todo",
                                                        _0: todo.id
                                                      };
                                              });
                                          setDisplayElement(function (param) {
                                                return {
                                                        TAG: "Todo",
                                                        _0: todo.id
                                                      };
                                              });
                                        }),
                                      onBlur: (function (param) {
                                          setSelectedElement(function (param) {
                                                
                                              });
                                        }),
                                      onChange: (function (e) {
                                          updateTodo(project.id, todo.id, (function (t) {
                                                  return {
                                                          id: t.id,
                                                          text: e.target.value,
                                                          additionalText: t.additionalText,
                                                          project: t.project,
                                                          status: t.status,
                                                          parentTodo: t.parentTodo,
                                                          depth: t.depth,
                                                          childNumber: t.childNumber,
                                                          hasArchivedChildren: t.hasArchivedChildren,
                                                          hasChildren: t.hasChildren,
                                                          ancArchived: t.ancArchived,
                                                          targetDate: t.targetDate
                                                        };
                                                }));
                                        })
                                    }),
                                JsxRuntime.jsx(Common.DateSelect.make, {
                                      value: Core__Option.map(todo.targetDate, (function (prim) {
                                              return new Date(prim);
                                            })),
                                      onClick: (function (newDate) {
                                          updateTodo(project.id, todo.id, (function (t) {
                                                  return {
                                                          id: t.id,
                                                          text: t.text,
                                                          additionalText: t.additionalText,
                                                          project: t.project,
                                                          status: t.status,
                                                          parentTodo: t.parentTodo,
                                                          depth: t.depth,
                                                          childNumber: t.childNumber,
                                                          hasArchivedChildren: t.hasArchivedChildren,
                                                          hasChildren: t.hasChildren,
                                                          ancArchived: t.ancArchived,
                                                          targetDate: Core__Option.map(newDate, (function (prim) {
                                                                  return prim.toString();
                                                                }))
                                                        };
                                                }));
                                        }),
                                      className: "mr-1 ml-1"
                                    }),
                                JsxRuntime.jsxs("div", {
                                      children: [
                                        JsxRuntime.jsx("div", {
                                              children: JsxRuntime.jsx(Tb.TbDragDrop, {}),
                                              className: " w-4 h-4 text-[var(--t4)] hidden group-hover:block bg-[var(--t0)] rounded-sm 0 ",
                                              onMouseDown: (function (e) {
                                                  itemToMoveHandleMouseDown(todo.id, e);
                                                })
                                            }),
                                        JsxRuntime.jsx("input", {
                                              className: ["border-[var(--t4)] bg-[var(--t0)] rounded text-blue-400 dark:text-blue-800 w-4 h-4 focus:ring-offset-0 focus:ring-blue-500"].join(" "),
                                              checked: isChecked,
                                              type: "checkbox",
                                              onChange: (function (param) {
                                                  setChecked(function (v) {
                                                        if (Belt_SetString.has(v, todo.id)) {
                                                          return Belt_SetString.remove(v, todo.id);
                                                        } else {
                                                          return Belt_SetString.add(v, todo.id);
                                                        }
                                                      });
                                                })
                                            })
                                      ],
                                      className: [
                                          "cursor-default absolute right-10 flex-row items-center gap-3 pr-2 h-full",
                                          isChecked ? "flex" : " hidden group-hover:flex"
                                        ].join(" ")
                                    })
                              ],
                              className: ["relative flex-1 ml-1 flex flex-row h-full justify-start items-center "].join(" ")
                            })
                      ],
                      className: [
                          "group flex flex-row justify-start items-center h-full flex-1 pl-1 rounded-sm",
                          stagedForDelete ? "outline-red-700 dark:outline-red-500" : "focus-within:outline-purple-500 outline-blue-500 ",
                          stagedForDelete ? "bg-red-200 dark:bg-red-950" : (
                              isChecked ? "bg-sky-50 dark:bg-sky-950" : (
                                  isDisplayElement && !isSelected ? "bg-sky-200 dark:bg-sky-900" : ""
                                )
                            ),
                          isSelected ? "outline outline-2 -outline-offset-2 " : ""
                        ].join(" ")
                    })
              ],
              ref: Caml_option.some(containerRef),
              className: [
                  Types.listItemClass,
                  "group flex flex-row justify-start items-center outline-none  pl-1"
                ].join(" "),
              id: Types.getTodoId(todo.id),
              tabIndex: 0,
              onKeyDown: onKeyDownContainer,
              onFocus: (function (param) {
                  setSelectedElement(function (param) {
                        return {
                                TAG: "Todo",
                                _0: todo.id
                              };
                      });
                  setDisplayElement(function (param) {
                        return {
                                TAG: "Todo",
                                _0: todo.id
                              };
                      });
                }),
              onBlur: (function (param) {
                  setSelectedElement(function (param) {
                        
                      });
                  setStagedForDelete(function (param) {
                        return false;
                      });
                }),
              onMouseEnter: (function (e) {
                  clearProjectLastRelative();
                  itemToMoveHandleMouseEnter(false, todo.id, e);
                })
            });
}

var make = Todo;

export {
  make ,
}
/* react Not a pure module */

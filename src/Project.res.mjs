// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Uuid from "uuid";
import * as Types from "./Types.res.mjs";
import * as React from "react";
import * as Common from "./Common.res.mjs";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Array from "@rescript/core/src/Core__Array.res.mjs";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as Tb from "react-icons/tb";
import * as JsxRuntime from "react/jsx-runtime";

function Project$Todo(props) {
  var getTodos = props.getTodos;
  var newTodoAfter = props.newTodoAfter;
  var setFocusIdNext = props.setFocusIdNext;
  var setTodos = props.setTodos;
  var setDisplayElement = props.setDisplayElement;
  var setSelectElement = props.setSelectElement;
  var isSelected = props.isSelected;
  var updateTodo = props.updateTodo;
  var todo = props.todo;
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
  var onKeyDownContainer = function (e) {
    if (isSelected && Caml_obj.equal(Caml_option.nullable_to_opt(containerRef.current), Caml_option.nullable_to_opt(document.activeElement))) {
      return Common.mapNullable(containerRef.current, (function (dom) {
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
                      setTodos(function (todos) {
                            return todos.filter(function (t) {
                                        return t.id !== todo.id;
                                      });
                          });
                      Common.mapNullable(containerRef.current, (function (containerEl) {
                              Common.focusPreviousClass(Types.listItemClass, containerEl);
                            }));
                    }
                    if (e.key === "Enter" && e.metaKey) {
                      Core__Option.mapOr(Core__Array.findIndexOpt(getTodos(), (function (v) {
                                  return v.id === todo.id;
                                })), undefined, (function (todoIndex) {
                              newTodoAfter(todoIndex);
                            }));
                    }
                    if (e.key === "Enter") {
                      e.preventDefault();
                      Common.mapNullable(inputRef.current, (function (inputEl) {
                              inputEl.focus();
                              inputEl.selectionStart = Caml_option.nullable_to_opt(inputEl.selectionEnd);
                            }));
                    }
                    if (e.key === "Escape") {
                      setSelectElement(function (param) {
                            
                          });
                      setDisplayElement(function (param) {
                            
                          });
                      dom.blur();
                      return ;
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
        Common.mapNullable(containerRef.current, (function (dom) {
                dom.focus();
              }));
      }
      return Common.mapNullable(inputRef.current, (function (dom) {
                    var cursorPosition = Core__Option.getOr(Caml_option.nullable_to_opt(dom.selectionStart), 0);
                    var inputValueLength = dom.value.length;
                    if (e.key === "ArrowUp") {
                      e.stopPropagation();
                      if (cursorPosition === 0) {
                        e.preventDefault();
                        Common.mapNullable(containerRef.current, (function (dom) {
                                dom.focus();
                              }));
                      }
                      
                    }
                    if (e.key === "ArrowDown") {
                      e.stopPropagation();
                      if (cursorPosition === inputValueLength) {
                        e.preventDefault();
                        Common.mapNullable(containerRef.current, (function (dom) {
                                dom.focus();
                              }));
                      }
                      
                    }
                    if (e.key === "Backspace" && inputValueLength === 0) {
                      if (stagedForDelete) {
                        setTodos(function (todos) {
                              return todos.filter(function (t) {
                                          return t.id !== todo.id;
                                        });
                            });
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
                      e.stopPropagation();
                      return Core__Option.mapOr(Core__Array.findIndexOpt(getTodos(), (function (v) {
                                        return v.id === todo.id;
                                      })), undefined, (function (todoIndex) {
                                    newTodoAfter(todoIndex);
                                  }));
                    }
                    
                  }));
    }
    
  };
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsx(Common.StatusSelect.make, {
                      status: todo.status,
                      setStatus: (function (newStatus) {
                          updateTodo(todo.id, (function (t) {
                                  return {
                                          id: t.id,
                                          text: t.text,
                                          project: t.project,
                                          isDone: t.isDone,
                                          status: newStatus,
                                          box: t.box === "Archive" && !Types.statusIsResolved(newStatus) ? "Working" : t.box
                                        };
                                }));
                        }),
                      focusTodo: (function () {
                          setFocusIdNext(function (param) {
                                return Types.getTodoId(todo.id);
                              });
                        }),
                      isOpen: match[0],
                      isPinned: todo.box === "Pinned",
                      isArchived: todo.box === "Archive",
                      onOpenChange: (function (v) {
                          if (v) {
                            return setStatusSelectIsOpen(function (param) {
                                        return v;
                                      });
                          } else {
                            Common.mapNullable(containerRef.current, (function (dom) {
                                    dom.focus();
                                  }));
                            return setStatusSelectIsOpen(function (param) {
                                        return v;
                                      });
                          }
                        })
                    }),
                JsxRuntime.jsx("input", {
                      ref: Caml_option.some(inputRef),
                      className: [
                          Types.todoInputClass,
                          "mx-1 flex-1 bg-inherit text-[--t10] w-full outline-none  text-xs font-medium\n          leading-none padding-none border-none h-5 -my-1 focus:text-blue-600"
                        ].join(" "),
                      id: Types.getTodoInputId(todo.id),
                      placeholder: "",
                      type: "text",
                      value: todo.text,
                      onKeyDown: onKeyDownInput,
                      onFocus: (function (param) {
                          setSelectElement(function (param) {
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
                          setSelectElement(function (param) {
                                
                              });
                        }),
                      onChange: (function (e) {
                          updateTodo(todo.id, (function (t) {
                                  return {
                                          id: t.id,
                                          text: e.target.value,
                                          project: t.project,
                                          isDone: t.isDone,
                                          status: t.status,
                                          box: t.box
                                        };
                                }));
                        })
                    }),
                JsxRuntime.jsx("button", {
                      children: JsxRuntime.jsx(Tb.TbPlus, {}),
                      className: [
                          "text-xs  mr-1",
                          isSelected ? "" : "hidden"
                        ].join(" "),
                      onClick: (function (param) {
                          
                        })
                    })
              ],
              ref: Caml_option.some(containerRef),
              className: [
                  Types.listItemClass,
                  "group flex flex-row justify-start items-center  pl-2 h-6",
                  stagedForDelete ? "bg-red-200 outline outline-1 -outline-offset-1" : (
                      isSelected ? "bg-var(--t1) outline outline-1 -outline-offset-1" : ""
                    )
                ].join(" "),
              id: Types.getTodoId(todo.id),
              tabIndex: 0,
              onKeyDown: onKeyDownContainer,
              onFocus: (function (param) {
                  setSelectElement(function (param) {
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
                  setSelectElement(function (param) {
                        
                      });
                  setStagedForDelete(function (param) {
                        return false;
                      });
                })
            });
}

var Todo = {
  make: Project$Todo
};

function Project(props) {
  var getTodos = props.getTodos;
  var setTodos = props.setTodos;
  var setFocusIdNext = props.setFocusIdNext;
  var setDisplayElement = props.setDisplayElement;
  var displayElement = props.displayElement;
  var setSelectElement = props.setSelectElement;
  var selectElement = props.selectElement;
  var updateTodo = props.updateTodo;
  var setShowArchive = props.setShowArchive;
  var showArchive = props.showArchive;
  var project = props.project;
  var projectRef = React.useRef(null);
  var isSelected = Caml_obj.equal(selectElement, {
        TAG: "Project",
        _0: project.id
      });
  var newTodoAfter = function (i) {
    var newId = Uuid.v4();
    setTodos(function (v) {
          return v.toSpliced(i + 1 | 0, 0, {
                      id: newId,
                      text: "",
                      project: project.id,
                      isDone: false,
                      status: "Unsorted",
                      box: "Working"
                    });
        });
    setFocusIdNext(function (param) {
          return Types.getTodoInputId(newId);
        });
  };
  var onKeyDownProject = function (e) {
    if (isSelected) {
      if (e.key === "Enter") {
        newTodoAfter(-1);
      }
      return Common.mapNullable(projectRef.current, (function (dom) {
                    if (e.key === "ArrowUp") {
                      e.preventDefault();
                      Common.focusPreviousClass(Types.listItemClass, dom);
                    }
                    if (e.key === "ArrowDown") {
                      e.preventDefault();
                      return Common.focusNextClass(Types.listItemClass, dom);
                    }
                    
                  }));
    }
    
  };
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsx("div", {
                              children: project.name,
                              className: " flex-none px-2 text-sm"
                            }),
                        JsxRuntime.jsx("div", {
                              className: "flex-1"
                            }),
                        JsxRuntime.jsx("button", {
                              children: JsxRuntime.jsx(Tb.TbPlus, {}),
                              className: "text-xs rounded h-6 w-6 flex-none mr-2",
                              onClick: (function (param) {
                                  newTodoAfter(-1);
                                })
                            }),
                        JsxRuntime.jsx("button", {
                              children: showArchive ? JsxRuntime.jsx(Tb.TbArchive, {}) : JsxRuntime.jsx(Tb.TbArchiveOff, {}),
                              className: "text-xs rounded h-6 w-6 flex-none",
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
                      ref: Caml_option.some(projectRef),
                      className: [
                          Types.listItemClass,
                          "h-7 flex flex-row justify-between items-center bg-[var(--t2)] px-1 gap-1",
                          isSelected ? "outline outline-1 -outline-offset-1 " : ""
                        ].join(" "),
                      id: Types.getProjectId(project.id),
                      tabIndex: 0,
                      onKeyDown: onKeyDownProject,
                      onFocus: (function (param) {
                          setSelectElement(function (param) {
                                return {
                                        TAG: "Project",
                                        _0: project.id
                                      };
                              });
                          setDisplayElement(function (param) {
                                return {
                                        TAG: "Project",
                                        _0: project.id
                                      };
                              });
                        }),
                      onBlur: (function (param) {
                          setSelectElement(function (param) {
                                
                              });
                        })
                    }),
                JsxRuntime.jsx("div", {
                      children: JsxRuntime.jsx("div", {
                            children: props.todos.filter(function (todo) {
                                    if (showArchive) {
                                      return true;
                                    } else {
                                      return todo.box !== "Archive";
                                    }
                                  }).map(function (todo) {
                                  return JsxRuntime.jsx(Project$Todo, {
                                              todo: todo,
                                              updateTodo: updateTodo,
                                              isSelected: Caml_obj.equal(selectElement, {
                                                    TAG: "Todo",
                                                    _0: todo.id
                                                  }),
                                              setSelectElement: setSelectElement,
                                              displayElement: displayElement,
                                              setDisplayElement: setDisplayElement,
                                              setTodos: setTodos,
                                              setFocusIdNext: setFocusIdNext,
                                              newTodoAfter: newTodoAfter,
                                              getTodos: getTodos
                                            }, Types.getTodoId(todo.id));
                                }),
                            className: "flex flex-col divide-y "
                          })
                    })
              ],
              className: ""
            });
}

var make = Project;

export {
  Todo ,
  make ,
}
/* uuid Not a pure module */

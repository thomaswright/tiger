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
import StatusSelectJsx from "./StatusSelect.jsx";

var make = StatusSelectJsx;

var StatusSelect = {
  make: make
};

function mapNullable(n, f) {
  Core__Option.mapOr((n == null) ? undefined : Caml_option.some(n), undefined, f);
}

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
  var inputRef = React.useRef(null);
  var containerRef = React.useRef(null);
  var match = React.useState(function () {
        return false;
      });
  var setStagedForDelete = match[1];
  var stagedForDelete = match[0];
  var onKeyDownContainer = function (e) {
    if (isSelected && Caml_obj.equal(Caml_option.nullable_to_opt(containerRef.current), Caml_option.nullable_to_opt(document.activeElement))) {
      return mapNullable(containerRef.current, (function (dom) {
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
                      mapNullable(containerRef.current, (function (containerEl) {
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
                      console.log("on enter");
                      e.preventDefault();
                      mapNullable(inputRef.current, (function (inputEl) {
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
        Core__Option.mapOr(Caml_option.nullable_to_opt(containerRef.current), undefined, (function (dom) {
                dom.focus();
              }));
      }
      return mapNullable(inputRef.current, (function (dom) {
                    var cursorPosition = Core__Option.getOr(Caml_option.nullable_to_opt(dom.selectionStart), 0);
                    var inputValueLength = dom.value.length;
                    if (e.key === "ArrowUp") {
                      e.stopPropagation();
                      if (cursorPosition === 0) {
                        e.preventDefault();
                        mapNullable(containerRef.current, (function (dom) {
                                dom.focus();
                              }));
                      }
                      
                    }
                    if (e.key === "ArrowDown") {
                      e.stopPropagation();
                      if (cursorPosition === inputValueLength) {
                        e.preventDefault();
                        mapNullable(containerRef.current, (function (dom) {
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
                        mapNullable(containerRef.current, (function (containerEl) {
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
                        }),
                      focusTodo: (function () {
                          setFocusIdNext(function (param) {
                                return Types.getTodoId(todo.id);
                              });
                        })
                    }),
                JsxRuntime.jsx("input", {
                      ref: Caml_option.some(inputRef),
                      className: [
                          Types.todoInputClass,
                          " flex-1 bg-inherit text-[--t10] w-full outline-none  text-sm font-medium\n          leading-none padding-none border-none h-5 -my-1 focus:text-blue-600"
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
                                          status: t.status
                                        };
                                }));
                        })
                    })
              ],
              ref: Caml_option.some(containerRef),
              className: [
                  Types.listItemClass,
                  " flex flex-row justify-start items-center gap-2 px-2 h-6",
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
                      status: "LaterUnsorted"
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
      return mapNullable(projectRef.current, (function (dom) {
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
                              className: " flex-none px-2"
                            }),
                        JsxRuntime.jsx("div", {
                              className: "flex-1"
                            }),
                        JsxRuntime.jsx("button", {
                              children: showArchive ? JsxRuntime.jsx(Tb.TbEye, {}) : JsxRuntime.jsx(Tb.TbEyeClosed, {}),
                              className: "text-xs rounded h-3 w-4 flex-none",
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
                          "h-6 flex flex-row justify-between items-center bg-[var(--t2)] ",
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
                                      return !Types.isArchiveStatus(todo.status);
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

var make$1 = Project;

export {
  StatusSelect ,
  mapNullable ,
  Todo ,
  make$1 as make,
}
/* make Not a pure module */

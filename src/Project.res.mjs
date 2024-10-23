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
import ReactTextareaAutosize from "react-textarea-autosize";

function Project$Todo(props) {
  var deleteTodo = props.deleteTodo;
  var setChecked = props.setChecked;
  var isChecked = props.isChecked;
  var getTodos = props.getTodos;
  var newTodoAfter = props.newTodoAfter;
  var setFocusIdNext = props.setFocusIdNext;
  var setTodos = props.setTodos;
  var setDisplayElement = props.setDisplayElement;
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
  var indentation = function (e) {
    if (e.key === "]" && e.metaKey && Core__Option.mapOr(todo.childNumber, false, (function (childNumber) {
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
                                    project: t.project,
                                    status: t.status,
                                    box: t.box,
                                    parentTodo: Core__Option.map(newParent, (function (t) {
                                            return t.id;
                                          })),
                                    depth: t.depth,
                                    childNumber: t.childNumber,
                                    hasArchivedChildren: t.hasArchivedChildren
                                  };
                          } else if (Caml_obj.equal(t.parentTodo, todo.id)) {
                            return {
                                    id: t.id,
                                    text: t.text,
                                    project: t.project,
                                    status: t.status,
                                    box: t.box,
                                    parentTodo: Core__Option.map(newParent, (function (t) {
                                            return t.id;
                                          })),
                                    depth: t.depth,
                                    childNumber: t.childNumber,
                                    hasArchivedChildren: t.hasArchivedChildren
                                  };
                          } else {
                            return t;
                          }
                        });
            }));
    }
    if (!(e.key === "[" && e.metaKey && todo.parentTodo !== undefined)) {
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
                                          project: t.project,
                                          status: t.status,
                                          box: t.box,
                                          parentTodo: newParent,
                                          depth: t.depth,
                                          childNumber: t.childNumber,
                                          hasArchivedChildren: t.hasArchivedChildren
                                        };
                                } else if (newChildren.contents.includes(t.id)) {
                                  return {
                                          id: t.id,
                                          text: t.text,
                                          project: t.project,
                                          status: t.status,
                                          box: t.box,
                                          parentTodo: todo.id,
                                          depth: t.depth,
                                          childNumber: t.childNumber,
                                          hasArchivedChildren: t.hasArchivedChildren
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
                      setTodos(project.id, (function (todos) {
                              return todos.filter(function (t) {
                                          return t.id !== todo.id;
                                        });
                            }));
                      Common.mapNullable(containerRef.current, (function (containerEl) {
                              Common.focusPreviousClass(Types.listItemClass, containerEl);
                            }));
                    }
                    if (e.key === "Enter" && e.metaKey) {
                      newTodoAfter(todo.id, todo.parentTodo);
                    }
                    if (e.key === "Enter") {
                      e.preventDefault();
                      Common.mapNullable(inputRef.current, (function (inputEl) {
                              inputEl.focus();
                              inputEl.selectionStart = Caml_option.nullable_to_opt(inputEl.selectionEnd);
                            }));
                    }
                    if (e.key === "Escape") {
                      setSelectedElement(function (param) {
                            
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
                    indentation(e);
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
                      return newTodoAfter(todo.id, todo.parentTodo);
                    }
                    
                  }));
    }
    
  };
  return JsxRuntime.jsxs("div", {
              children: [
                Core__Array.make(Core__Option.getOr(todo.depth, 0), false).map(function (param, i) {
                      return JsxRuntime.jsx("div", {
                                  className: "h-full w-3 border-l ml-1"
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
                                                  project: t.project,
                                                  status: newStatus,
                                                  box: t.box === "Archive" && !Types.statusIsResolved(newStatus) ? "Working" : t.box,
                                                  parentTodo: t.parentTodo,
                                                  depth: t.depth,
                                                  childNumber: t.childNumber,
                                                  hasArchivedChildren: t.hasArchivedChildren
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
                                    return setStatusSelectIsOpen(function (param) {
                                                return v;
                                              });
                                  }
                                })
                            }),
                        JsxRuntime.jsxs("div", {
                              children: [
                                isSelected ? null : JsxRuntime.jsx("div", {
                                        className: "h-px w-full absolute bg-[var(--t2)] -bottom-0"
                                      }),
                                JsxRuntime.jsx(ReactTextareaAutosize, {
                                      ref: Caml_option.some(inputRef),
                                      className: [
                                          Types.todoInputClass,
                                          "mx-1 my-1.5 block text-xs font-medium  w-full h-5 border-0 px-0 py-0 focus:ring-0 \n                bg-transparent text-[var(--t8)]"
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
                                                          project: t.project,
                                                          status: t.status,
                                                          box: t.box,
                                                          parentTodo: t.parentTodo,
                                                          depth: t.depth,
                                                          childNumber: t.childNumber,
                                                          hasArchivedChildren: t.hasArchivedChildren
                                                        };
                                                }));
                                        })
                                    }),
                                JsxRuntime.jsx("button", {
                                      children: JsxRuntime.jsx(Tb.TbPlus, {}),
                                      className: ["absolute hidden group-hover:block right-6 bg-[var(--t1)] rounded p-0.5  text-xs  "].join(" "),
                                      onClick: (function (param) {
                                          newTodoAfter(todo.id, todo.id);
                                        })
                                    }),
                                JsxRuntime.jsx("input", {
                                      className: [
                                          "absolute right-0 border-[var(--t3)]\n             rounded mx-1 text-blue-400 h-3.5 w-3.5 focus:ring-offset-0 focus:ring-blue-500",
                                          isChecked ? "" : " hidden group-hover:block"
                                        ].join(" "),
                                      checked: isChecked,
                                      type: "checkbox",
                                      onChange: (function (param) {
                                          setChecked(function (v) {
                                                return Common.arrayToggle(v, todo.id);
                                              });
                                        })
                                    })
                              ],
                              className: ["relative flex-1 ml-1 flex flex-row h-full justify-start items-center "].join(" ")
                            })
                      ],
                      className: [
                          "group flex flex-row justify-start items-center h-full flex-1 pl-0.5 rounded-sm",
                          stagedForDelete ? "outline-red-700" : "focus-within:outline-purple-500 group-focus:outline-blue-500",
                          stagedForDelete ? "bg-red-200 " : (
                              isChecked ? "bg-sky-50" : ""
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
              style: {},
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
                })
            });
}

var Todo = {
  make: Project$Todo
};

function Project(props) {
  var deleteTodo = props.deleteTodo;
  var setChecked = props.setChecked;
  var checked = props.checked;
  var getTodos = props.getTodos;
  var setTodos = props.setTodos;
  var setFocusIdNext = props.setFocusIdNext;
  var setDisplayElement = props.setDisplayElement;
  var displayElement = props.displayElement;
  var setSelectedElement = props.setSelectedElement;
  var selectedElement = props.selectedElement;
  var updateTodo = props.updateTodo;
  var updateProject = props.updateProject;
  var setShowArchive = props.setShowArchive;
  var showArchive = props.showArchive;
  var project = props.project;
  var projectRef = React.useRef(null);
  var inputRef = React.useRef(null);
  var isSelected = Caml_obj.equal(selectedElement, {
        TAG: "Project",
        _0: project.id
      });
  var newTodoAfter = function (after, parentTodo) {
    var newId = Uuid.v4();
    var newTodo_project = project.id;
    var newTodo = {
      id: newId,
      text: "",
      project: newTodo_project,
      status: "Unsorted",
      box: "Working",
      parentTodo: parentTodo,
      depth: undefined,
      childNumber: undefined,
      hasArchivedChildren: false
    };
    setTodos(project.id, (function (todos) {
            if (after === undefined) {
              return [newTodo].concat(todos);
            } else {
              return Core__Array.reduce(todos, [], (function (a, c) {
                            if (Caml_obj.equal(c.id, after)) {
                              return a.concat([c]).concat([newTodo]);
                            } else {
                              return a.concat([c]);
                            }
                          }));
            }
          }));
    setFocusIdNext(function (param) {
          return Types.getTodoInputId(newId);
        });
  };
  var onKeyDownProject = function (e) {
    if (isSelected) {
      return Common.mapNullable(projectRef.current, (function (dom) {
                    if (e.key === "ArrowUp") {
                      e.preventDefault();
                      Common.focusPreviousClass(Types.listItemClass, dom);
                    }
                    if (e.key === "ArrowDown") {
                      e.preventDefault();
                      Common.focusNextClass(Types.listItemClass, dom);
                    }
                    if (e.key === "Backspace" && e.metaKey) {
                      Common.mapNullable(projectRef.current, (function (containerEl) {
                              Common.focusPreviousClass(Types.listItemClass, containerEl);
                            }));
                    }
                    if (e.key === "Enter" && e.metaKey) {
                      newTodoAfter(undefined, undefined);
                    }
                    if (e.key === "Enter") {
                      e.preventDefault();
                      Common.mapNullable(inputRef.current, (function (inputEl) {
                              inputEl.focus();
                              inputEl.selectionStart = Caml_option.nullable_to_opt(inputEl.selectionEnd);
                            }));
                    }
                    if (e.key === "Escape") {
                      setSelectedElement(function (param) {
                            
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
    if (isSelected) {
      if (e.key === "Escape") {
        e.stopPropagation();
        Common.mapNullable(projectRef.current, (function (dom) {
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
                        Common.mapNullable(projectRef.current, (function (dom) {
                                dom.focus();
                              }));
                      }
                      
                    }
                    if (e.key === "ArrowDown") {
                      e.stopPropagation();
                      if (cursorPosition === inputValueLength) {
                        e.preventDefault();
                        Common.mapNullable(projectRef.current, (function (dom) {
                                dom.focus();
                              }));
                      }
                      
                    }
                    if (e.key === "Enter" && cursorPosition === inputValueLength) {
                      e.stopPropagation();
                      e.preventDefault();
                      return newTodoAfter(undefined, undefined);
                    }
                    
                  }));
    }
    
  };
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsx(ReactTextareaAutosize, {
                              ref: Caml_option.some(inputRef),
                              className: [
                                  Types.todoInputClass,
                                  "ml-3 my-1 block text-base font-black tracking-tight  w-full border-0 px-0 py-0 focus:ring-0 \n               leading-none bg-transparent"
                                ].join(" "),
                              id: Types.getProjectInputId(project.id),
                              style: {
                                resize: "none"
                              },
                              placeholder: "",
                              value: project.name,
                              onKeyDown: onKeyDownInput,
                              onFocus: (function (param) {
                                  setSelectedElement(function (param) {
                                        return {
                                                TAG: "Todo",
                                                _0: project.id
                                              };
                                      });
                                  setDisplayElement(function (param) {
                                        return {
                                                TAG: "Todo",
                                                _0: project.id
                                              };
                                      });
                                }),
                              onBlur: (function (param) {
                                  setSelectedElement(function (param) {
                                        
                                      });
                                }),
                              onChange: (function (e) {
                                  updateProject(project.id, (function (t) {
                                          return {
                                                  id: t.id,
                                                  name: e.target.value,
                                                  isActive: t.isActive,
                                                  todos: t.todos
                                                };
                                        }));
                                })
                            }),
                        JsxRuntime.jsx("div", {
                              className: "flex-1"
                            }),
                        JsxRuntime.jsx("button", {
                              children: JsxRuntime.jsx(Tb.TbPlus, {}),
                              className: "hidden group-hover:block bg-[var(--t1)] p-0.5 text-xs rounded  flex-none mr-2",
                              onClick: (function (param) {
                                  newTodoAfter(undefined, undefined);
                                })
                            }),
                        JsxRuntime.jsx("button", {
                              children: showArchive ? JsxRuntime.jsx(Tb.TbEye, {}) : JsxRuntime.jsx(Tb.TbEyeClosed, {}),
                              className: "text-2xs rounded h-6 w-6 flex-none font-mono strike",
                              onClick: (function (param) {
                                  setShowArchive(function (v) {
                                        return Common.arrayToggle(v, project.id);
                                      });
                                })
                            })
                      ],
                      ref: Caml_option.some(projectRef),
                      className: [
                          Types.listItemClass,
                          "group  flex flex-row justify-between items-center bg-[var(--t0)] px-1 text-[var(--t9)]\n        gap-1 border-b-[var(--t6)] border-t-[var(--t0)]",
                          isSelected ? "outline outline-2 -outline-offset-2 outline-purple-500 focus:outline-blue-500" : ""
                        ].join(" "),
                      id: Types.getProjectId(project.id),
                      tabIndex: 0,
                      onKeyDown: onKeyDownProject,
                      onFocus: (function (param) {
                          setSelectedElement(function (param) {
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
                          setSelectedElement(function (param) {
                                
                              });
                        })
                    }),
                JsxRuntime.jsx("div", {
                      children: JsxRuntime.jsx("div", {
                            children: props.todos.map(function (todo) {
                                  return JsxRuntime.jsx(Project$Todo, {
                                              project: project,
                                              todo: todo,
                                              updateTodo: updateTodo,
                                              isSelected: Caml_obj.equal(selectedElement, {
                                                    TAG: "Todo",
                                                    _0: todo.id
                                                  }),
                                              setSelectedElement: setSelectedElement,
                                              displayElement: displayElement,
                                              setDisplayElement: setDisplayElement,
                                              setTodos: setTodos,
                                              setFocusIdNext: setFocusIdNext,
                                              newTodoAfter: newTodoAfter,
                                              getTodos: getTodos,
                                              isChecked: checked.includes(todo.id),
                                              setChecked: setChecked,
                                              deleteTodo: deleteTodo,
                                              showArchive: showArchive
                                            }, Types.getTodoId(todo.id));
                                }),
                            className: "flex flex-col pb-4"
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

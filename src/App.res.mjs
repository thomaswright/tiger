// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Uuid from "uuid";
import * as Types from "./Types.res.mjs";
import * as React from "react";
import * as Common from "./Common.res.mjs";
import * as Project from "./Project.res.mjs";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Array from "@rescript/core/src/Core__Array.res.mjs";
import * as DisplayTodo from "./DisplayTodo.res.mjs";
import * as SwitchJsx from "./Switch.jsx";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as Belt_MapString from "rescript/lib/es6/belt_MapString.js";
import * as Belt_SetString from "rescript/lib/es6/belt_SetString.js";
import * as DisplayProject from "./DisplayProject.res.mjs";
import * as Tb from "react-icons/tb";
import * as Caml_splice_call from "rescript/lib/es6/caml_splice_call.js";
import * as JsxRuntime from "react/jsx-runtime";
import TigerSvg from "./assets/tiger.svg";
import * as React$1 from "@formkit/auto-animate/react";

var defaultTodos = [
  {
    id: "1",
    text: "Do Something",
    project: "1",
    status: "Unsorted",
    box: "Working",
    parentTodo: undefined,
    depth: undefined,
    childNumber: undefined,
    hasArchivedChildren: false,
    hasChildren: false
  },
  {
    id: "2",
    text: "Do Something Else",
    project: "1",
    status: "ResolveScrap",
    box: "Archive",
    parentTodo: undefined,
    depth: undefined,
    childNumber: undefined,
    hasArchivedChildren: false,
    hasChildren: false
  }
];

var defaultProjects = [{
    id: "1",
    name: "Project Omega",
    isActive: true,
    todos: defaultTodos
  }];

var logoUrl = TigerSvg;

function buildTodoTree(input) {
  var rootMapId = "_";
  var parentMap = Core__Array.reduce(input, undefined, (function (a, c) {
          var mapId = Core__Option.getOr(c.parentTodo, rootMapId);
          return Belt_MapString.update(a, mapId, (function (v) {
                        return Core__Option.mapOr(v, [c], (function (v) {
                                      return v.concat([c]);
                                    }));
                      }));
        }));
  var mutParentMap = {
    contents: parentMap
  };
  var parentAggs = Belt_MapString.map(parentMap, (function (children) {
          return children.some(function (v) {
                      return v.box === "Archive";
                    });
        }));
  var build = function (arr, mapId, depth) {
    var children = Belt_MapString.get(mutParentMap.contents, mapId);
    mutParentMap.contents = Belt_MapString.remove(mutParentMap.contents, mapId);
    return Core__Array.reduceWithIndex(Core__Option.getOr(children, []), arr, (function (a, todo, i) {
                  return build(a.concat([{
                                    id: todo.id,
                                    text: todo.text,
                                    project: todo.project,
                                    status: todo.status,
                                    box: todo.box,
                                    parentTodo: todo.parentTodo,
                                    depth: depth,
                                    childNumber: i,
                                    hasArchivedChildren: Belt_MapString.getWithDefault(parentAggs, todo.id, false),
                                    hasChildren: Belt_MapString.getWithDefault(parentMap, todo.id, []).length > 0
                                  }]), todo.id, depth + 1 | 0);
                }));
  };
  return build([], rootMapId, 0);
}

function App$CheckedSummary(props) {
  var setProjects = props.setProjects;
  var setChecked = props.setChecked;
  var checked = props.checked;
  var match = React.useState(function () {
        return false;
      });
  var setStatusSelectIsOpen = match[1];
  var allTodos = Caml_splice_call.spliceObjApply([], "concat", [props.projects.map(function (p) {
              return p.todos;
            })]);
  var tmp;
  if (checked.length < 2) {
    tmp = null;
  } else {
    var checkedTodos = allTodos.filter(function (t) {
          return checked.includes(t.id);
        });
    tmp = JsxRuntime.jsxs(React.Fragment, {
          children: [
            JsxRuntime.jsx(Common.StatusSelect.make, {
                  status: Core__Option.flatMap(checkedTodos[0], (function (first) {
                          if (checkedTodos.every(function (t) {
                                  return t.status === first.status;
                                })) {
                            return first.status;
                          }
                          
                        })),
                  setStatus: (function (newStatus) {
                      setProjects(function (projects) {
                            return projects.map(function (project) {
                                        return {
                                                id: project.id,
                                                name: project.name,
                                                isActive: project.isActive,
                                                todos: project.todos.map(function (t) {
                                                      if (checked.includes(t.id)) {
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
                                                      } else {
                                                        return t;
                                                      }
                                                    })
                                              };
                                      });
                          });
                    }),
                  focusTodo: (function () {
                      
                    }),
                  isOpen: match[0],
                  isPinned: false,
                  isArchived: false,
                  onOpenChange: (function (v) {
                      setStatusSelectIsOpen(function (param) {
                            return v;
                          });
                    })
                }),
            checked.length.toString() + " Checked",
            JsxRuntime.jsx("div", {
                  className: "flex-1"
                }),
            JsxRuntime.jsx("button", {
                  children: "Clear",
                  className: "px-2",
                  onClick: (function (param) {
                      setChecked(function (param) {
                            return [];
                          });
                    })
                })
          ]
        });
  }
  return JsxRuntime.jsx("div", {
              children: tmp,
              className: "h-8 text-sm px-2 flex flex-row gap-2 items-center border-b"
            });
}

function App(props) {
  var match = Common.useLocalStorage("projects", defaultProjects);
  var setProjects = match[1];
  var projects = match[0];
  var match$1 = Common.useLocalStorage("showArchive", []);
  var setShowArchive = match$1[1];
  var showArchive = match$1[0];
  var match$2 = Common.useLocalStorage("checked", []);
  var setChecked = match$2[1];
  var checked = match$2[0];
  var match$3 = Common.useLocalStorage("projectsTab", "All");
  var projectsTab = match$3[0];
  var match$4 = React.useState(function () {
        
      });
  var setSelectedElement = match$4[1];
  var selectedElement = match$4[0];
  var match$5 = React.useState(function () {
        
      });
  var setDisplayElement = match$5[1];
  var displayElement = match$5[0];
  var match$6 = React.useState(function () {
        
      });
  var setFocusClassNext = match$6[1];
  var focusClassNext = match$6[0];
  var match$7 = React.useState(function () {
        
      });
  var setFocusIdNext = match$7[1];
  var focusIdNext = match$7[0];
  var match$8 = React.useState(function () {
        
      });
  var setItemsToMove = match$8[1];
  var itemsToMove = match$8[0];
  var match$9 = React$1.useAutoAnimate();
  var aaEnable = match$9[1];
  var clickDelayTimeout = React.useRef(undefined);
  var match$10 = React.useState(function () {
        
      });
  var setLastRelative = match$10[1];
  var lastRelative = match$10[0];
  var itemToMoveHandleMouseDown = function (itemId, param) {
    var timeoutId = setTimeout((function () {
            setItemsToMove(function (s) {
                  return Belt_SetString.add(s, itemId);
                });
            aaEnable(true);
          }), 200);
    clickDelayTimeout.current = Caml_option.some(timeoutId);
  };
  var itemToMoveHandleMouseEnter = function (itemId, param) {
    var isInMoveGroup = Belt_SetString.has(itemsToMove, itemId);
    if (isInMoveGroup) {
      return setLastRelative(function (param) {
                  
                });
    } else if (Core__Option.mapOr(lastRelative, true, (function (lastRelativeId) {
              return itemId !== lastRelativeId;
            }))) {
      return setProjects(function (projects) {
                  var todosToMove = Core__Array.reduce(projects, [], (function (pa, pc) {
                          return Core__Array.reduce(pc.todos, pa, (function (ta, tc) {
                                        if (Belt_SetString.has(itemsToMove, tc.id)) {
                                          return ta.concat([tc]);
                                        } else {
                                          return ta;
                                        }
                                      }));
                        }));
                  return projects.map(function (p) {
                              return {
                                      id: p.id,
                                      name: p.name,
                                      isActive: p.isActive,
                                      todos: Belt_Array.concatMany(p.todos.filter(function (t) {
                                                  return !Belt_SetString.has(itemsToMove, t.id);
                                                }).map(function (t) {
                                                if (t.id === itemId) {
                                                  return todosToMove.concat([t]);
                                                } else {
                                                  return [t];
                                                }
                                              }))
                                    };
                            });
                });
    } else {
      return ;
    }
  };
  var handleMouseUp = React.useCallback((function (param) {
          Core__Option.mapOr(clickDelayTimeout.current, undefined, (function (a) {
                  clearTimeout(a);
                }));
          setItemsToMove(function (param) {
                
              });
          aaEnable(false);
          setLastRelative(function (param) {
                
              });
        }), []);
  React.useEffect((function () {
          aaEnable(false);
        }), []);
  React.useEffect((function () {
          document.addEventListener("mouseup", handleMouseUp);
          return (function () {
                    document.removeEventListener("mouseup", handleMouseUp);
                  });
        }), []);
  var updateProject = React.useCallback((function (id, f) {
          setProjects(function (v) {
                return v.map(function (project) {
                            if (project.id === id) {
                              return f(project);
                            } else {
                              return project;
                            }
                          });
              });
        }), []);
  var updateTodo = React.useCallback((function (projectId, todoId, f) {
          updateProject(projectId, (function (project) {
                  return {
                          id: project.id,
                          name: project.name,
                          isActive: project.isActive,
                          todos: project.todos.map(function (todo) {
                                if (todo.id === todoId) {
                                  return f(todo);
                                } else {
                                  return todo;
                                }
                              })
                        };
                }));
        }), []);
  var setTodos = React.useCallback((function (projectId, f) {
          updateProject(projectId, (function (project) {
                  return {
                          id: project.id,
                          name: project.name,
                          isActive: project.isActive,
                          todos: f(project.todos)
                        };
                }));
        }), []);
  var deleteTodo = function (projectId, todo) {
    setTodos(projectId, (function (todos) {
            return todos.filter(function (t) {
                          return t.id !== todo.id;
                        }).map(function (t) {
                        if (Caml_obj.equal(t.parentTodo, todo.id)) {
                          return {
                                  id: t.id,
                                  text: t.text,
                                  project: t.project,
                                  status: t.status,
                                  box: t.box,
                                  parentTodo: todo.parentTodo,
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
  };
  React.useEffect(function () {
        Core__Option.mapOr(Core__Option.flatMap(focusClassNext, (function (x) {
                    return Array.prototype.slice.call(document.getElementsByClassName(x))[0];
                  })), undefined, (function (element) {
                element.focus();
                setFocusClassNext(function (param) {
                      
                    });
              }));
        Core__Option.mapOr(Core__Option.flatMap(focusIdNext, (function (x) {
                    return Caml_option.nullable_to_opt(document.getElementById(x));
                  })), undefined, (function (element) {
                element.focus();
                setFocusIdNext(function (param) {
                      
                    });
              }));
      });
  var tmp;
  if (displayElement !== undefined) {
    if (displayElement.TAG === "Todo") {
      var todoId = displayElement._0;
      tmp = Core__Option.mapOr(Core__Array.reduce(projects, undefined, (function (a, c) {
                  if (Core__Option.isSome(a)) {
                    return a;
                  } else {
                    return Core__Option.map(c.todos.find(function (t) {
                                    return t.id === todoId;
                                  }), (function (v) {
                                  return [
                                          c,
                                          v
                                        ];
                                }));
                  }
                })), null, (function (param) {
              return JsxRuntime.jsx(DisplayTodo.make, {
                          project: param[0],
                          todo: param[1],
                          setFocusIdNext: setFocusIdNext,
                          updateTodo: updateTodo,
                          setTodos: setTodos,
                          deleteTodo: deleteTodo
                        });
            }));
    } else {
      var projectId = displayElement._0;
      tmp = Core__Option.mapOr(projects.find(function (p) {
                return p.id === projectId;
              }), null, (function (project) {
              return JsxRuntime.jsx(DisplayProject.make, {
                          project: project,
                          updateProject: updateProject,
                          setProjects: setProjects,
                          setTodos: setTodos
                        });
            }));
    }
  } else {
    tmp = null;
  }
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsxs("div", {
                              children: [
                                JsxRuntime.jsx("img", {
                                      className: "py-0.5 ",
                                      src: logoUrl,
                                      width: "24"
                                    }),
                                JsxRuntime.jsxs("button", {
                                      children: [
                                        JsxRuntime.jsx(Tb.TbPlus, {}),
                                        "Project"
                                      ],
                                      className: ["bg-[var(--t2)] px-2 rounded text-xs flex flex-row items-center gap-1 h-5 "].join(" "),
                                      onClick: (function (param) {
                                          var newProjectId = Uuid.v4();
                                          setProjects(function (v) {
                                                return [{
                                                            id: newProjectId,
                                                            name: "",
                                                            isActive: true,
                                                            todos: []
                                                          }].concat(v);
                                              });
                                          setSelectedElement(function (param) {
                                                return {
                                                        TAG: "Project",
                                                        _0: newProjectId
                                                      };
                                              });
                                          setDisplayElement(function (param) {
                                                return {
                                                        TAG: "Project",
                                                        _0: newProjectId
                                                      };
                                              });
                                          setFocusIdNext(function (param) {
                                                return Types.getProjectInputId(newProjectId);
                                              });
                                        })
                                    })
                              ],
                              className: "flex flex-row gap-2 justify-between items-center w-full h-10 border-b px-2"
                            }),
                        JsxRuntime.jsx("div", {
                              children: projects.filter(function (project) {
                                      if (projectsTab === "Active") {
                                        return project.isActive;
                                      } else {
                                        return true;
                                      }
                                    }).map(function (project) {
                                    var showArchive$1 = showArchive.includes(project.id);
                                    var projectTodos = buildTodoTree(project.todos.filter(function (todo) {
                                              if (showArchive$1) {
                                                return true;
                                              } else {
                                                return todo.box !== "Archive";
                                              }
                                            }));
                                    return JsxRuntime.jsx(Project.make, {
                                                project: project,
                                                todos: projectTodos,
                                                showArchive: showArchive$1,
                                                setShowArchive: setShowArchive,
                                                updateProject: updateProject,
                                                updateTodo: updateTodo,
                                                selectedElement: selectedElement,
                                                setSelectedElement: setSelectedElement,
                                                displayElement: displayElement,
                                                setDisplayElement: setDisplayElement,
                                                setFocusIdNext: setFocusIdNext,
                                                setTodos: setTodos,
                                                getTodos: (function () {
                                                    return projectTodos;
                                                  }),
                                                checked: checked,
                                                setChecked: setChecked,
                                                deleteTodo: deleteTodo,
                                                itemToMoveHandleMouseDown: itemToMoveHandleMouseDown,
                                                itemToMoveHandleMouseEnter: itemToMoveHandleMouseEnter
                                              }, Types.getProjectId(project.id));
                                  }),
                              ref: Caml_option.some(match$9[0]),
                              className: "pb-20"
                            })
                      ],
                      className: "flex-1 overflow-y-scroll"
                    }),
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsx(App$CheckedSummary, {
                              checked: checked,
                              projects: projects,
                              setChecked: setChecked,
                              setProjects: setProjects
                            }),
                        tmp
                      ],
                      className: " border-l flex-1"
                    })
              ],
              className: "flex flex-row h-dvh text-[var(--t9)]"
            });
}

var make = App;

export {
  make ,
}
/* logoUrl Not a pure module */

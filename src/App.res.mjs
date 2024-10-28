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

var defaultTodos = [
  {
    id: "1",
    text: "Do Something",
    project: "1",
    status: "Unsorted",
    parentTodo: undefined,
    depth: undefined,
    childNumber: undefined,
    hasArchivedChildren: false,
    hasChildren: false,
    ancArchived: false
  },
  {
    id: "2",
    text: "Do Something Else",
    project: "1",
    status: "ResolveNo",
    parentTodo: undefined,
    depth: undefined,
    childNumber: undefined,
    hasArchivedChildren: false,
    hasChildren: false,
    ancArchived: false
  }
];

var defaultProjects = [{
    id: "1",
    name: "Project Omega",
    isActive: true,
    todos: defaultTodos,
    hideArchived: false,
    hideAll: false,
    hiddenTodos: undefined
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
                      if (v.status === "ArchiveNo") {
                        return true;
                      } else {
                        return v.status === "ArchiveDone";
                      }
                    });
        }));
  var build = function (arr, mapId, ancArchived, depth) {
    var children = Belt_MapString.get(mutParentMap.contents, mapId);
    mutParentMap.contents = Belt_MapString.remove(mutParentMap.contents, mapId);
    return Core__Array.reduceWithIndex(Core__Option.getOr(children, []), arr, (function (a, todo, i) {
                  return build(a.concat([{
                                    id: todo.id,
                                    text: todo.text,
                                    project: todo.project,
                                    status: todo.status,
                                    parentTodo: todo.parentTodo,
                                    depth: depth,
                                    childNumber: i,
                                    hasArchivedChildren: Belt_MapString.getWithDefault(parentAggs, todo.id, false),
                                    hasChildren: Belt_MapString.getWithDefault(parentMap, todo.id, []).length > 0,
                                    ancArchived: ancArchived
                                  }]), todo.id, ancArchived || todo.status === "ArchiveNo" || todo.status === "ArchiveDone", depth + 1 | 0);
                }));
  };
  return build([], rootMapId, false, 0);
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
  if (Belt_SetString.size(checked) < 2) {
    tmp = null;
  } else {
    var checkedTodos = allTodos.filter(function (t) {
          return Belt_SetString.has(checked, t.id);
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
                                                      if (Belt_SetString.has(checked, t.id)) {
                                                        return {
                                                                id: t.id,
                                                                text: t.text,
                                                                project: t.project,
                                                                status: newStatus,
                                                                parentTodo: t.parentTodo,
                                                                depth: t.depth,
                                                                childNumber: t.childNumber,
                                                                hasArchivedChildren: t.hasArchivedChildren,
                                                                hasChildren: t.hasChildren,
                                                                ancArchived: t.ancArchived
                                                              };
                                                      } else {
                                                        return t;
                                                      }
                                                    }),
                                                hideArchived: project.hideArchived,
                                                hideAll: project.hideAll,
                                                hiddenTodos: project.hiddenTodos
                                              };
                                      });
                          });
                    }),
                  focusTodo: (function () {
                      
                    }),
                  isOpen: match[0],
                  onOpenChange: (function (v) {
                      setStatusSelectIsOpen(function (param) {
                            return v;
                          });
                    })
                }),
            Belt_SetString.size(checked).toString() + " Checked",
            JsxRuntime.jsx("div", {
                  className: "flex-1"
                }),
            JsxRuntime.jsx("button", {
                  children: "Clear",
                  className: "px-2",
                  onClick: (function (param) {
                      setChecked(function (param) {
                            
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
  var match = Common.useLocalStorage("projects", defaultProjects.map(function (p) {
            return {
                    id: p.id,
                    name: p.name,
                    isActive: p.isActive,
                    todos: buildTodoTree(p.todos),
                    hideArchived: p.hideArchived,
                    hideAll: p.hideAll,
                    hiddenTodos: p.hiddenTodos
                  };
          }));
  var setProjectsPreCompute = match[1];
  var projects = match[0];
  var setProjects = function (f) {
    setProjectsPreCompute(function (projects) {
          return f(projects).map(function (p) {
                      return {
                              id: p.id,
                              name: p.name,
                              isActive: p.isActive,
                              todos: buildTodoTree(p.todos),
                              hideArchived: p.hideArchived,
                              hideAll: p.hideAll,
                              hiddenTodos: p.hiddenTodos
                            };
                    });
        });
  };
  var match$1 = Common.useLocalStorage("checked", undefined);
  var setChecked = match$1[1];
  var checked = match$1[0];
  var match$2 = Common.useLocalStorage("projectsTab", "All");
  var projectsTab = match$2[0];
  var match$3 = React.useState(function () {
        
      });
  var setSelectedElement = match$3[1];
  var selectedElement = match$3[0];
  var match$4 = React.useState(function () {
        
      });
  var setDisplayElement = match$4[1];
  var displayElement = match$4[0];
  var match$5 = React.useState(function () {
        
      });
  var setFocusClassNext = match$5[1];
  var focusClassNext = match$5[0];
  var match$6 = React.useState(function () {
        
      });
  var setFocusIdNext = match$6[1];
  var focusIdNext = match$6[0];
  var aaParentRef = React.useRef(null);
  var todosClickDelayTimeout = React.useRef(undefined);
  var match$7 = React.useState(function () {
        
      });
  var setTodosOfDragHandle = match$7[1];
  var todosOfDragHandle = match$7[0];
  var todosLastRelative = React.useRef(undefined);
  var projectClickDelayTimeout = React.useRef(undefined);
  var match$8 = React.useState(function () {
        
      });
  var setProjectOfDragHandle = match$8[1];
  var projectOfDragHandle = match$8[0];
  var projectLastRelative = React.useRef(undefined);
  var logExport = function () {
    console.log(projects.map(function (p) {
              return {
                      id: p.id,
                      name: p.name,
                      isActive: p.isActive,
                      todos: p.todos.map(function (t) {
                            return {
                                    id: t.id,
                                    text: t.text,
                                    project: t.project,
                                    status: t.status,
                                    parentTodo: t.parentTodo
                                  };
                          }),
                      hiddenTodos: Belt_MapString.toArray(p.hiddenTodos)
                    };
            }));
  };
  var projectToMoveHandleMouseDown = function (projectId, param) {
    var timeoutId = setTimeout((function () {
            setProjectOfDragHandle(function (s) {
                  return projectId;
                });
          }), 200);
    projectClickDelayTimeout.current = Caml_option.some(timeoutId);
  };
  var itemToMoveHandleMouseDown = function (itemId, param) {
    var timeoutId = setTimeout((function () {
            setTodosOfDragHandle(function (s) {
                  return Core__Array.reduce(projects, Belt_SetString.add(s, itemId), (function (a, c) {
                                return Core__Array.reduce(c.todos, a, (function (a2, c2) {
                                              if (Core__Option.mapOr(c2.parentTodo, false, (function (x) {
                                                        return Belt_SetString.has(a2, x);
                                                      }))) {
                                                return Belt_SetString.add(a2, c2.id);
                                              } else {
                                                return a2;
                                              }
                                            }));
                              }));
                });
          }), 200);
    todosClickDelayTimeout.current = Caml_option.some(timeoutId);
  };
  var projectToMoveHandleMouseEnter = function (itemId, param) {
    if (projectOfDragHandle !== undefined) {
      if (itemId === projectOfDragHandle) {
        projectLastRelative.current = undefined;
        return ;
      } else if (Core__Option.mapOr(projectLastRelative.current, true, (function (projectLastRelativeId) {
                return itemId !== projectLastRelativeId;
              }))) {
        projectLastRelative.current = itemId;
        return setProjects(function (projects) {
                    var itemIndex = projects.findIndex(function (p) {
                          return p.id === itemId;
                        });
                    var moveIndex = projects.findIndex(function (p) {
                          return p.id === projectOfDragHandle;
                        });
                    var fromBelow = itemIndex < moveIndex;
                    var projectToMove = projects.find(function (p) {
                          return p.id === projectOfDragHandle;
                        });
                    var projectsWithout = projects.filter(function (p) {
                          return p.id !== projectOfDragHandle;
                        });
                    return Core__Array.reduce(projectsWithout, [], (function (a, c) {
                                  if (c.id === itemId) {
                                    if (fromBelow) {
                                      return a.concat(Core__Option.mapOr(projectToMove, [], (function (v) {
                                                          return [v];
                                                        }))).concat([c]);
                                    } else {
                                      return a.concat([c]).concat(Core__Option.mapOr(projectToMove, [], (function (v) {
                                                        return [v];
                                                      })));
                                    }
                                  } else {
                                    return a.concat([c]);
                                  }
                                }));
                  });
      } else {
        return ;
      }
    }
    
  };
  var itemToMoveHandleMouseEnter = function (isProject, itemId, param) {
    var itemsToMove = Belt_SetString.union(checked, todosOfDragHandle);
    if (Belt_SetString.isEmpty(todosOfDragHandle)) {
      return ;
    }
    var isInMoveGroup = Belt_SetString.has(itemsToMove, itemId);
    if (isInMoveGroup) {
      todosLastRelative.current = undefined;
      return ;
    } else if (Core__Option.mapOr(todosLastRelative.current, true, (function (todosLastRelativeId) {
              return itemId !== todosLastRelativeId;
            }))) {
      todosLastRelative.current = itemId;
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
                  var applyNewParent = function (todos, newParent) {
                    return todos.map(function (t) {
                                return {
                                        id: t.id,
                                        text: t.text,
                                        project: t.project,
                                        status: t.status,
                                        parentTodo: Belt_SetString.has(itemsToMove, t.id) && !Core__Option.mapOr(t.parentTodo, false, (function (currentParentTodo) {
                                                return Belt_SetString.has(itemsToMove, currentParentTodo);
                                              })) ? newParent : t.parentTodo,
                                        depth: t.depth,
                                        childNumber: t.childNumber,
                                        hasArchivedChildren: t.hasArchivedChildren,
                                        hasChildren: t.hasChildren,
                                        ancArchived: t.ancArchived
                                      };
                              });
                  };
                  var itemIndex = Core__Option.mapOr(Caml_option.nullable_to_opt(aaParentRef.current), 0, (function (containerEl) {
                          return Array.prototype.slice.call(containerEl.children).findIndex(function (el) {
                                      return Core__Option.mapOr(Types.getIdFromId(el.id), false, (function (id) {
                                                    return id === itemId;
                                                  }));
                                    });
                        }));
                  var moveIndex = Core__Option.mapOr(Caml_option.nullable_to_opt(aaParentRef.current), 0, (function (containerEl) {
                          return Array.prototype.slice.call(containerEl.children).findIndex(function (el) {
                                      return Core__Option.mapOr(Types.getIdFromId(el.id), false, (function (id) {
                                                    return Belt_SetString.has(itemsToMove, id);
                                                  }));
                                    });
                        }));
                  var fromBelow = itemIndex < moveIndex;
                  var filterOutTodosToMove = function (p) {
                    return {
                            id: p.id,
                            name: p.name,
                            isActive: p.isActive,
                            todos: p.todos.filter(function (t) {
                                  return !Belt_SetString.has(itemsToMove, t.id);
                                }),
                            hideArchived: p.hideArchived,
                            hideAll: p.hideAll,
                            hiddenTodos: p.hiddenTodos
                          };
                  };
                  if (isProject && itemIndex === 0) {
                    return projects;
                  }
                  if (!isProject) {
                    return projects.map(function (p) {
                                var p$1 = filterOutTodosToMove(p);
                                return {
                                        id: p$1.id,
                                        name: p$1.name,
                                        isActive: p$1.isActive,
                                        todos: Belt_Array.concatMany(p$1.todos.map(function (t, param) {
                                                    if (t.id === itemId) {
                                                      if (fromBelow) {
                                                        return applyNewParent(todosToMove.concat([t]), t.parentTodo);
                                                      } else if (t.hasChildren) {
                                                        return applyNewParent([t].concat(todosToMove), t.id);
                                                      } else {
                                                        return applyNewParent([t].concat(todosToMove), t.parentTodo);
                                                      }
                                                    } else {
                                                      return [t];
                                                    }
                                                  })).map(function (t) {
                                              return {
                                                      id: t.id,
                                                      text: t.text,
                                                      project: p$1.id,
                                                      status: t.status,
                                                      parentTodo: t.parentTodo,
                                                      depth: t.depth,
                                                      childNumber: t.childNumber,
                                                      hasArchivedChildren: t.hasArchivedChildren,
                                                      hasChildren: t.hasChildren,
                                                      ancArchived: t.ancArchived
                                                    };
                                            }),
                                        hideArchived: p$1.hideArchived,
                                        hideAll: p$1.hideAll,
                                        hiddenTodos: p$1.hiddenTodos
                                      };
                              });
                  }
                  if (!fromBelow) {
                    return projects.map(function (p) {
                                var p$1 = filterOutTodosToMove(p);
                                if (p$1.id === itemId) {
                                  return {
                                          id: p$1.id,
                                          name: p$1.name,
                                          isActive: p$1.isActive,
                                          todos: applyNewParent(todosToMove.concat(p$1.todos).map(function (t) {
                                                    return {
                                                            id: t.id,
                                                            text: t.text,
                                                            project: p$1.id,
                                                            status: t.status,
                                                            parentTodo: t.parentTodo,
                                                            depth: t.depth,
                                                            childNumber: t.childNumber,
                                                            hasArchivedChildren: t.hasArchivedChildren,
                                                            hasChildren: t.hasChildren,
                                                            ancArchived: t.ancArchived
                                                          };
                                                  }), undefined),
                                          hideArchived: p$1.hideArchived,
                                          hideAll: p$1.hideAll,
                                          hiddenTodos: p$1.hiddenTodos
                                        };
                                } else {
                                  return p$1;
                                }
                              });
                  }
                  var projectIndex = projects.findIndex(function (p) {
                        return p.id === itemId;
                      });
                  return projects.map(function (p, i) {
                              var p$1 = filterOutTodosToMove(p);
                              if (i !== (projectIndex - 1 | 0)) {
                                return p$1;
                              }
                              var lastTodo = p$1.todos[p$1.todos.length - 1 | 0];
                              return {
                                      id: p$1.id,
                                      name: p$1.name,
                                      isActive: p$1.isActive,
                                      todos: applyNewParent(p$1.todos.concat(todosToMove).map(function (t) {
                                                return {
                                                        id: t.id,
                                                        text: t.text,
                                                        project: p$1.id,
                                                        status: t.status,
                                                        parentTodo: t.parentTodo,
                                                        depth: t.depth,
                                                        childNumber: t.childNumber,
                                                        hasArchivedChildren: t.hasArchivedChildren,
                                                        hasChildren: t.hasChildren,
                                                        ancArchived: t.ancArchived
                                                      };
                                              }), lastTodo.parentTodo),
                                      hideArchived: p$1.hideArchived,
                                      hideAll: p$1.hideAll,
                                      hiddenTodos: p$1.hiddenTodos
                                    };
                            });
                });
    } else {
      return ;
    }
  };
  var handleMouseUp = React.useCallback((function (param) {
          Core__Option.mapOr(todosClickDelayTimeout.current, undefined, (function (a) {
                  clearTimeout(a);
                }));
          setTodosOfDragHandle(function (param) {
                
              });
          todosLastRelative.current = undefined;
          Core__Option.mapOr(projectClickDelayTimeout.current, undefined, (function (a) {
                  clearTimeout(a);
                }));
          setProjectOfDragHandle(function (param) {
                
              });
          projectLastRelative.current = undefined;
        }), []);
  React.useEffect((function () {
          
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
                              }),
                          hideArchived: project.hideArchived,
                          hideAll: project.hideAll,
                          hiddenTodos: project.hiddenTodos
                        };
                }));
        }), []);
  var setTodos = React.useCallback((function (projectId, f) {
          updateProject(projectId, (function (project) {
                  return {
                          id: project.id,
                          name: project.name,
                          isActive: project.isActive,
                          todos: f(project.todos),
                          hideArchived: project.hideArchived,
                          hideAll: project.hideAll,
                          hiddenTodos: project.hiddenTodos
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
                                  parentTodo: todo.parentTodo,
                                  depth: t.depth,
                                  childNumber: t.childNumber,
                                  hasArchivedChildren: t.hasArchivedChildren,
                                  hasChildren: t.hasChildren,
                                  ancArchived: t.ancArchived
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
                                JsxRuntime.jsx("div", {
                                      className: "flex-1"
                                    }),
                                JsxRuntime.jsx("button", {
                                      children: "export",
                                      className: ["bg-[var(--t2)] px-2 rounded text-xs flex flex-row items-center gap-1 h-5 "].join(" "),
                                      onClick: (function (param) {
                                          logExport();
                                        })
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
                                                            todos: [],
                                                            hideArchived: false,
                                                            hideAll: false,
                                                            hiddenTodos: undefined
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
                        JsxRuntime.jsx("ul", {
                              children: projects.filter(function (project) {
                                      if (projectsTab === "Active") {
                                        return project.isActive;
                                      } else {
                                        return true;
                                      }
                                    }).map(function (project) {
                                    return JsxRuntime.jsx(Project.make, {
                                                project: project,
                                                todos: project.todos,
                                                updateProject: updateProject,
                                                updateTodo: updateTodo,
                                                selectedElement: selectedElement,
                                                setSelectedElement: setSelectedElement,
                                                displayElement: displayElement,
                                                setDisplayElement: setDisplayElement,
                                                setFocusIdNext: setFocusIdNext,
                                                setTodos: setTodos,
                                                getTodos: (function () {
                                                    return project.todos;
                                                  }),
                                                checked: checked,
                                                setChecked: setChecked,
                                                deleteTodo: deleteTodo,
                                                itemToMoveHandleMouseDown: itemToMoveHandleMouseDown,
                                                itemToMoveHandleMouseEnter: itemToMoveHandleMouseEnter,
                                                projectToMoveHandleMouseDown: projectToMoveHandleMouseDown,
                                                projectToMoveHandleMouseEnter: projectToMoveHandleMouseEnter,
                                                clearProjectLastRelative: (function () {
                                                    projectLastRelative.current = undefined;
                                                  })
                                              }, Types.getProjectId(project.id));
                                  }),
                              ref: Caml_option.some(aaParentRef),
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

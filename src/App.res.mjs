// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Uuid from "uuid";
import * as Types from "./Types.res.mjs";
import * as React from "react";
import * as Common from "./Common.res.mjs";
import * as Project from "./Project.res.mjs";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Array from "@rescript/core/src/Core__Array.res.mjs";
import * as DisplayTodo from "./DisplayTodo.res.mjs";
import * as SwitchJsx from "./Switch.jsx";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as Belt_MapString from "rescript/lib/es6/belt_MapString.js";
import * as DisplayProject from "./DisplayProject.res.mjs";
import * as Tb from "react-icons/tb";
import * as JsxRuntime from "react/jsx-runtime";

var defaultProjects = [{
    id: "1",
    name: "Project Omega",
    isActive: true
  }];

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
    hasArchivedChildren: false
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
    hasArchivedChildren: false
  }
];

var make = SwitchJsx.Switch;

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
                                    hasArchivedChildren: Belt_MapString.getWithDefault(parentAggs, todo.id, false)
                                  }]), todo.id, depth + 1 | 0);
                }));
  };
  return build([], rootMapId, 0);
}

function App$CheckedSummary(props) {
  var setTodos = props.setTodos;
  var setChecked = props.setChecked;
  var checked = props.checked;
  var match = React.useState(function () {
        return false;
      });
  var setStatusSelectIsOpen = match[1];
  var tmp;
  if (checked.length < 2) {
    tmp = null;
  } else {
    var checkedTodos = props.todos.filter(function (t) {
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
                      setTodos(function (todos) {
                            return todos.map(function (t) {
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
                                                  hasArchivedChildren: t.hasArchivedChildren
                                                };
                                        } else {
                                          return t;
                                        }
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
  var match$1 = Common.useLocalStorage("todos", defaultTodos);
  var setTodos = match$1[1];
  var todos = match$1[0];
  var match$2 = Common.useLocalStorage("showArchive", []);
  var setShowArchive = match$2[1];
  var showArchive = match$2[0];
  var match$3 = Common.useLocalStorage("checked", []);
  var setChecked = match$3[1];
  var checked = match$3[0];
  var match$4 = Common.useLocalStorage("projectsTab", "All");
  var setProjectTab = match$4[1];
  var projectsTab = match$4[0];
  var match$5 = React.useState(function () {
        
      });
  var setSelectedElement = match$5[1];
  var selectedElement = match$5[0];
  var match$6 = React.useState(function () {
        
      });
  var setDisplayElement = match$6[1];
  var displayElement = match$6[0];
  var match$7 = React.useState(function () {
        
      });
  var setFocusClassNext = match$7[1];
  var focusClassNext = match$7[0];
  var match$8 = React.useState(function () {
        
      });
  var setFocusIdNext = match$8[1];
  var focusIdNext = match$8[0];
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
  var updateTodo = React.useCallback((function (id, f) {
          setTodos(function (v) {
                return v.map(function (todo) {
                            if (todo.id === id) {
                              return f(todo);
                            } else {
                              return todo;
                            }
                          });
              });
        }), []);
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
  var deleteTodo = function (todo) {
    setTodos(function (todos) {
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
                                hasArchivedChildren: t.hasArchivedChildren
                              };
                      } else {
                        return t;
                      }
                    });
        });
  };
  var tmp;
  if (displayElement !== undefined) {
    if (displayElement.TAG === "Todo") {
      var todoId = displayElement._0;
      tmp = Core__Option.mapOr(todos.find(function (t) {
                return t.id === todoId;
              }), null, (function (todo) {
              return JsxRuntime.jsx(DisplayTodo.make, {
                          todo: todo,
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
                                JsxRuntime.jsxs("div", {
                                      children: [
                                        JsxRuntime.jsx("div", {
                                              children: "Show Inactive",
                                              className: "text-sm"
                                            }),
                                        JsxRuntime.jsx(make, {
                                              checked: projectsTab === "All",
                                              onCheckedChange: (function () {
                                                  setProjectTab(function (v) {
                                                        if (v === "All") {
                                                          return "Active";
                                                        } else {
                                                          return "All";
                                                        }
                                                      });
                                                })
                                            })
                                      ],
                                      className: "flex flex-row gap-2 "
                                    }),
                                JsxRuntime.jsxs("button", {
                                      children: [
                                        JsxRuntime.jsx(Tb.TbPlus, {}),
                                        "Project"
                                      ],
                                      className: ["bg-[var(--t2)] px-2 rounded text-xs flex flex-row items-center gap-1"].join(" "),
                                      onClick: (function (param) {
                                          var newProjectId = Uuid.v4();
                                          setProjects(function (v) {
                                                return [{
                                                            id: newProjectId,
                                                            name: "",
                                                            isActive: true
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
                                          setFocusClassNext(function (param) {
                                                return "class-display-title";
                                              });
                                        })
                                    })
                              ],
                              className: "flex flex-row gap-2 justify-between w-full p-1"
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
                                    var projectTodos = buildTodoTree(todos.filter(function (todo) {
                                                return todo.project === project.id;
                                              }).filter(function (todo) {
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
                                                deleteTodo: deleteTodo
                                              }, Types.getProjectId(project.id));
                                  })
                            })
                      ],
                      className: "flex-1"
                    }),
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsx(App$CheckedSummary, {
                              checked: checked,
                              todos: todos,
                              setChecked: setChecked,
                              setTodos: setTodos
                            }),
                        tmp
                      ],
                      className: " border-l flex-1"
                    })
              ],
              className: "flex flex-row h-dvh"
            });
}

var make$1 = App;

export {
  make$1 as make,
}
/* make Not a pure module */

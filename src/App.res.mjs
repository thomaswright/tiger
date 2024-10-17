// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Uuid from "uuid";
import * as Types from "./Types.res.mjs";
import * as React from "react";
import * as Common from "./Common.res.mjs";
import * as Project from "./Project.res.mjs";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
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
    isDone: false,
    status: "LaterUnsorted"
  },
  {
    id: "2",
    text: "Do Something Else",
    project: "1",
    isDone: false,
    status: "ArchiveNoNeed"
  }
];

function App(props) {
  var match = Common.useLocalStorage("projects", defaultProjects);
  var setProjects = match[1];
  var projects = match[0];
  var match$1 = Common.useLocalStorage("todos", defaultTodos);
  var getTodos = match$1[2];
  var setTodos = match$1[1];
  var todos = match$1[0];
  var match$2 = Common.useLocalStorage("showArchive", []);
  var setShowArchive = match$2[1];
  var showArchive = match$2[0];
  var match$3 = Common.useLocalStorage("projectsTab", "All");
  var setProjectTab = match$3[1];
  var projectsTab = match$3[0];
  var match$4 = React.useState(function () {
        
      });
  var setSelectElement = match$4[1];
  var selectElement = match$4[0];
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
  var tmp;
  if (displayElement !== undefined) {
    if (displayElement.TAG === "Todo") {
      var todoId = displayElement._0;
      tmp = Core__Option.mapOr(todos.find(function (t) {
                return t.id === todoId;
              }), null, (function (todo) {
              return JsxRuntime.jsx("div", {
                          children: JsxRuntime.jsx("input", {
                                className: ["px-2 flex-1 bg-inherit text-[--foreground] w-full outline-none \n          leading-none padding-none border-none h-5 -my-1 focus:text-blue-500"].join(" "),
                                id: "id-display-title",
                                placeholder: "Todo Text",
                                type: "text",
                                value: todo.text,
                                onKeyDown: (function (e) {
                                    if (e.key === "Escape") {
                                      return setFocusIdNext(function (param) {
                                                  return Types.getTodoId(todo.id);
                                                });
                                    }
                                    
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
                        });
            }));
    } else {
      var projectId = displayElement._0;
      tmp = Core__Option.mapOr(projects.find(function (p) {
                return p.id === projectId;
              }), null, (function (project) {
              return JsxRuntime.jsx("div", {
                          children: JsxRuntime.jsx("input", {
                                className: [" flex-1 bg-inherit text-[--foreground] w-full outline-none \n          leading-none padding-none border-none h-5 -my-1 focus:text-blue-500"].join(" "),
                                id: "id-display-title",
                                placeholder: "Project Name",
                                type: "text",
                                value: project.name,
                                onKeyDown: (function (e) {
                                    if (e.key === "Escape") {
                                      return setFocusIdNext(function (param) {
                                                  return Types.getProjectId(project.id);
                                                });
                                    }
                                    
                                  }),
                                onChange: (function (e) {
                                    updateProject(project.id, (function (p) {
                                            return {
                                                    id: p.id,
                                                    name: e.target.value,
                                                    isActive: p.isActive
                                                  };
                                          }));
                                  })
                              })
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
                                        JsxRuntime.jsx("button", {
                                              children: "All",
                                              className: [
                                                  "w-20  border-b-2",
                                                  projectsTab === "All" ? "border-red-500 text-red-500" : "border-transparent "
                                                ].join(" "),
                                              onClick: (function (param) {
                                                  setProjectTab(function (param) {
                                                        return "All";
                                                      });
                                                })
                                            }),
                                        JsxRuntime.jsx("button", {
                                              children: "Active",
                                              className: [
                                                  "w-20  border-b-2",
                                                  projectsTab === "Active" ? "border-red-500 text-red-500" : "border-transparent "
                                                ].join(" "),
                                              onClick: (function (param) {
                                                  setProjectTab(function (param) {
                                                        return "Active";
                                                      });
                                                })
                                            })
                                      ],
                                      className: "flex flex-row gap-2"
                                    }),
                                JsxRuntime.jsx("button", {
                                      children: "Add Project",
                                      className: ["bg-slate-200 px-2 rounded"].join(" "),
                                      onClick: (function (param) {
                                          var newProjectId = Uuid.v4();
                                          setProjects(function (v) {
                                                return [{
                                                            id: newProjectId,
                                                            name: "",
                                                            isActive: true
                                                          }].concat(v);
                                              });
                                          setSelectElement(function (param) {
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
                              className: "flex flex-row gap-2"
                            }),
                        JsxRuntime.jsx("div", {
                              children: projects.filter(function (project) {
                                      if (projectsTab === "Active") {
                                        return project.isActive;
                                      } else {
                                        return true;
                                      }
                                    }).map(function (project) {
                                    return JsxRuntime.jsx(Project.make, {
                                                project: project,
                                                todos: todos.filter(function (todo) {
                                                      return todo.project === project.id;
                                                    }),
                                                showArchive: showArchive.includes(project.id),
                                                setShowArchive: setShowArchive,
                                                updateProject: updateProject,
                                                updateTodo: updateTodo,
                                                selectElement: selectElement,
                                                setSelectElement: setSelectElement,
                                                displayElement: displayElement,
                                                setDisplayElement: setDisplayElement,
                                                setFocusIdNext: setFocusIdNext,
                                                setTodos: setTodos,
                                                getTodos: getTodos
                                              }, Types.getProjectId(project.id));
                                  })
                            })
                      ],
                      className: "flex-1"
                    }),
                JsxRuntime.jsx("div", {
                      children: tmp,
                      className: " border-l flex-1"
                    })
              ],
              className: "flex flex-row h-dvh"
            });
}

var make = App;

export {
  make ,
}
/* uuid Not a pure module */

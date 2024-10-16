// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Common from "./Common.res.mjs";
import * as Project from "./Project.res.mjs";
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

function App$Details(props) {
  return JsxRuntime.jsx("div", {
              children: "Details",
              className: " border-l flex-1"
            });
}

function App(props) {
  var match = Common.useLocalStorage("projects", defaultProjects);
  var setProjects = match[1];
  var match$1 = Common.useLocalStorage("todos", defaultTodos);
  var todos = match$1[0];
  var match$2 = Common.useLocalStorage("showArchive", []);
  var setShowArchive = match$2[1];
  var showArchive = match$2[0];
  var match$3 = Common.useLocalStorage("projectsTab", "All");
  var setProjectTab = match$3[1];
  var projectsTab = match$3[0];
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
  return JsxRuntime.jsxs("div", {
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
                        JsxRuntime.jsx("div", {
                              children: match[0].filter(function (project) {
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
                                                updateProject: updateProject
                                              });
                                  })
                            })
                      ],
                      className: "flex-1"
                    }),
                JsxRuntime.jsx(App$Details, {})
              ],
              className: "flex flex-row h-dvh"
            });
}

var make = App;

export {
  make ,
}
/* react Not a pure module */

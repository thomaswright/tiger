// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Common from "./Common.res.mjs";
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
    status: {
      TAG: "Keep",
      _0: "LaterWill"
    }
  },
  {
    id: "2",
    text: "Do Something Else",
    project: "1",
    isDone: false,
    status: {
      TAG: "Archive",
      _0: "Rejected"
    }
  }
];

function App(props) {
  var match = Common.useLocalStorage("projects", defaultProjects);
  Common.useLocalStorage("todos", defaultTodos);
  Common.useLocalStorage("showArchiveProjects", new Set([]));
  var match$1 = Common.useLocalStorage("projectsTab", "All");
  var setProjectTab = match$1[1];
  var projectsTab = match$1[0];
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsx("button", {
                              children: "All",
                              className: [
                                  "w-20 rounded",
                                  projectsTab === "All" ? "bg-slate-800 text-white" : "bg-slate-200 text-black"
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
                                  "w-20 rounded",
                                  projectsTab === "Active" ? "bg-slate-800 text-white" : "bg-slate-200 text-black"
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
                      children: match[0].filter(function (v) {
                              return v.isActive;
                            }).map(function (v) {
                            return JsxRuntime.jsx("div", {
                                        children: v.name
                                      });
                          })
                    })
              ],
              className: "p-6"
            });
}

var make = App;

export {
  make ,
}
/* Common Not a pure module */

// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Types from "./Types.res.mjs";
import * as Common from "./Common.res.mjs";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as Tb from "react-icons/tb";
import * as JsxRuntime from "react/jsx-runtime";
import ReactTextareaAutosize from "react-textarea-autosize";

function DisplayProject(props) {
  var setTodos = props.setTodos;
  var setProjects = props.setProjects;
  var updateProject = props.updateProject;
  var project = props.project;
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsx("div", {
                      children: JsxRuntime.jsx(ReactTextareaAutosize, {
                            className: [" flex-1 text-lg bg-inherit text-[--t10] w-full outline-none font-black tracking-tight focus:ring-0\n           border-none px-0 py-0"].join(" "),
                            id: "id-display-title",
                            style: {
                              resize: "none"
                            },
                            placeholder: "Project",
                            value: project.name,
                            onChange: (function (e) {
                                updateProject(project.id, (function (p) {
                                        return {
                                                id: p.id,
                                                name: e.target.value,
                                                isActive: p.isActive,
                                                todos: p.todos
                                              };
                                      }));
                              })
                          }),
                      className: "w-full px-2 py-1"
                    }),
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsx("button", {
                              children: project.isActive ? "Active" : "Inactive",
                              className: "rounded bg-[var(--t2)] px-2 text-xs h-fit flex-none",
                              onClick: (function (param) {
                                  updateProject(project.id, (function (p) {
                                          return {
                                                  id: p.id,
                                                  name: p.name,
                                                  isActive: !p.isActive,
                                                  todos: p.todos
                                                };
                                        }));
                                })
                            }),
                        JsxRuntime.jsx("div", {
                              className: "flex-1"
                            }),
                        JsxRuntime.jsx("button", {
                              children: JsxRuntime.jsx(Tb.TbTrash, {}),
                              className: ["\n          text-[var(--t4)] px-1 h-6 flex flex-row items-center justify-center rounded border-[var(--t3)]\n          hover:text-blue-600\n        "].join(" "),
                              onClick: (function (param) {
                                  Core__Option.mapOr(Caml_option.nullable_to_opt(document.getElementById(Types.getProjectId(project.id))), undefined, (function (projectEl) {
                                          Common.focusPreviousClass(Types.listItemClass, projectEl);
                                        }));
                                  setProjects(function (v) {
                                        return v.filter(function (p) {
                                                    return p.id !== project.id;
                                                  });
                                      });
                                  setTodos(project.id, (function (v) {
                                          return v.filter(function (p) {
                                                      return p.project !== project.id;
                                                    });
                                        }));
                                })
                            })
                      ],
                      className: "flex flex-row border-y items-center gap-3 p-1 px-2"
                    }),
                JsxRuntime.jsx("div", {
                      className: "p-2"
                    })
              ]
            });
}

var make = DisplayProject;

export {
  make ,
}
/* Common Not a pure module */

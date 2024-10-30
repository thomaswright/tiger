// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Array from "@rescript/core/src/Core__Array.res.mjs";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as Tb from "react-icons/tb";
import Format from "date-fns/format";
import GetDay from "date-fns/getDay";
import AddDays from "date-fns/addDays";
import GetDate from "date-fns/getDate";
import GetWeek from "date-fns/getWeek";
import GetMonth from "date-fns/getMonth";
import * as JsxRuntime from "react/jsx-runtime";
import AddMonths from "date-fns/addMonths";
import FormatISO from "date-fns/formatISO";
import IsSameDay from "date-fns/isSameDay";
import EndOfMonth from "date-fns/endOfMonth";
import StartOfMonth from "date-fns/startOfMonth";
import GetDaysInMonth from "date-fns/getDaysInMonth";
import EachDayOfInterval from "date-fns/eachDayOfInterval";

function getFirstSome(arr) {
  return Core__Array.reduce(arr, undefined, (function (a, c) {
                if (Core__Option.isSome(a) || !Core__Option.isSome(c)) {
                  return a;
                } else {
                  return c;
                }
              }));
}

function isFirstInstanceOfDay(date) {
  var firstDayOfMonth = StartOfMonth(date);
  var daysInFirstWeek = EachDayOfInterval({
        start: firstDayOfMonth,
        end: AddDays(firstDayOfMonth, 6)
      });
  return daysInFirstWeek.some(function (day) {
              return IsSameDay(day, date);
            });
}

function isFirstDayOfMonth(date) {
  return IsSameDay(StartOfMonth(date), date);
}

function Calendar(props) {
  var onClick = props.onClick;
  var defaultWindowAdj = 4;
  var match = React.useState(function () {
        return [
                -1,
                3
              ];
      });
  var setMonthAdj = match[1];
  var match$1 = match[0];
  var centerDate = new Date();
  var start = StartOfMonth(AddMonths(centerDate, match$1[0]));
  var end_ = EndOfMonth(AddMonths(centerDate, match$1[1]));
  var allDays = (function (param) {
        var a = param[0].concat([param[1]]);
        var lastIndex = a.length - 1 | 0;
        return a.map(function (w, i) {
                    if (i === 0) {
                      return Core__Option.mapOr(Core__Option.flatMap(w[0], (function (d) {
                                        return d;
                                      })), w, (function (d) {
                                    return Core__Array.make(GetDay(d), undefined).concat(w);
                                  }));
                    } else {
                      return Core__Option.mapOr(Core__Option.flatMap(w[lastIndex], (function (d) {
                                        return d;
                                      })), w, (function (d) {
                                    return w.concat(Core__Array.make(6 - GetDay(d) | 0, undefined));
                                  }));
                    }
                  });
      })(Core__Array.reduce(EachDayOfInterval({
                start: start,
                end: end_
              }), [
            [],
            [],
            GetWeek(start)
          ], (function (param, c) {
              var weekCheck = param[2];
              var weekBuild = param[1];
              var a = param[0];
              var currentWeek = GetWeek(c);
              if (currentWeek === weekCheck) {
                return [
                        a,
                        weekBuild.concat([Caml_option.some(c)]),
                        weekCheck
                      ];
              } else {
                return [
                        a.concat([weekBuild]),
                        [Caml_option.some(c)],
                        currentWeek
                      ];
              }
            })));
  var shifter = JsxRuntime.jsxs("div", {
        children: [
          JsxRuntime.jsx("button", {
                children: JsxRuntime.jsx(Tb.TbArrowLeft, {}),
                className: "",
                onClick: (function (param) {
                    setMonthAdj(function (param) {
                          return [
                                  param[0] - defaultWindowAdj | 0,
                                  param[1] - defaultWindowAdj | 0
                                ];
                        });
                  })
              }),
          Format(start, "MMM yyyy") + " - " + Format(end_, "MMM yyyy"),
          JsxRuntime.jsx("button", {
                children: JsxRuntime.jsx(Tb.TbArrowRight, {}),
                className: "",
                onClick: (function (param) {
                    setMonthAdj(function (param) {
                          return [
                                  param[0] + defaultWindowAdj | 0,
                                  param[1] + defaultWindowAdj | 0
                                ];
                        });
                  })
              })
        ],
        className: "text-2xs font-bold w-full flex items-center justify-around py-1"
      });
  return JsxRuntime.jsxs("div", {
              children: [
                shifter,
                JsxRuntime.jsx("div", {
                      children: allDays.map(function (week, i) {
                            return JsxRuntime.jsx("div", {
                                        children: week.map(function (day) {
                                              if (day === undefined) {
                                                return JsxRuntime.jsx("div", {
                                                            children: "",
                                                            className: ""
                                                          });
                                              }
                                              var day_ = Caml_option.valFromOption(day);
                                              var className = [
                                                  " text-2xs flex items-center justify-center hover:bg-blue-100 cursor-default border-r first:border-l h-7 ",
                                                  (GetMonth(day_) % 2 === 0, ""),
                                                  GetDate(day_) > (GetDaysInMonth(day_) - 7 | 0) ? "border-b border-b-black" : "border-b",
                                                  GetDate(day_) === GetDaysInMonth(day_) && GetDay(day_) !== 6 ? "border-r-black" : "",
                                                  (i === 0 || i === 1) && GetDate(day_) <= 7 ? "border-t border-t-black" : "",
                                                  i === 0 && GetDate(day_) === 1 && GetDay(day_) > 0 ? "border-l border-l-black" : ""
                                                ].join(" ");
                                              return JsxRuntime.jsxs(React.Fragment, {
                                                          children: [
                                                            JsxRuntime.jsx("div", {
                                                                  children: Format(day_, "d"),
                                                                  className: className,
                                                                  onClick: (function (param) {
                                                                      onClick(day_);
                                                                    })
                                                                }, FormatISO(day_) + "day"),
                                                            GetDate(day_) === 15 ? JsxRuntime.jsx("div", {
                                                                    children: JsxRuntime.jsx("span", {
                                                                          children: Format(day_, "MMM")
                                                                        }),
                                                                    className: "-translate-x-1/2 translate-y-1/2 text-2xs font-bold flex gap-1 text-center absolute top-0 left-1 -rotate-90"
                                                                  }, FormatISO(day_) + "month") : null
                                                          ]
                                                        });
                                            }),
                                        className: "grid grid-cols-7 relative pl-4 "
                                      }, Core__Option.mapOr(getFirstSome(week), "noMatch", (function (date_) {
                                              return FormatISO(date_);
                                            })));
                          }),
                      className: "py-2"
                    }),
                shifter
              ],
              className: "h-64 w-64 overflow-y-scroll p-3 border rounded border-plain-300 "
            });
}

var make = Calendar;

export {
  getFirstSome ,
  isFirstInstanceOfDay ,
  isFirstDayOfMonth ,
  make ,
}
/* react Not a pure module */

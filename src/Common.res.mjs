// Generated by ReScript, PLEASE EDIT WITH CARE

import * as OtherJs from "./other.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import StatusSelectJsx from "./StatusSelect.jsx";
import * as UseLocalStorageJs from "./useLocalStorage.js";
import UseLocalStorageJs$1 from "./useLocalStorage.js";

function useLocalStorage(prim0, prim1) {
  return UseLocalStorageJs$1(prim0, prim1);
}

function useLocalStorageListener(prim0, prim1) {
  return UseLocalStorageJs.useLocalStorageListener(prim0, prim1);
}

function focusPreviousClass(prim0, prim1) {
  OtherJs.focusPreviousClass(prim0, prim1);
}

function focusNextClass(prim0, prim1) {
  OtherJs.focusNextClass(prim0, prim1);
}

var make = StatusSelectJsx;

var StatusSelect = {
  make: make
};

function mapNullable(n, f) {
  Core__Option.mapOr((n == null) ? undefined : Caml_option.some(n), undefined, f);
}

export {
  useLocalStorage ,
  useLocalStorageListener ,
  focusPreviousClass ,
  focusNextClass ,
  StatusSelect ,
  mapNullable ,
}
/* make Not a pure module */

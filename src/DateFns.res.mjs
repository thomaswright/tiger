// Generated by ReScript, PLEASE EDIT WITH CARE

import * as DateFns from "date-fns";
import IsEqual from "date-fns/isEqual";

function isAfterOrEqual(x, y) {
  if (DateFns.isAfter(x, y)) {
    return true;
  } else {
    return IsEqual(x, y);
  }
}

function isBeforeOrEqual(x, y) {
  if (DateFns.isBefore(x, y)) {
    return true;
  } else {
    return IsEqual(x, y);
  }
}

export {
  isAfterOrEqual ,
  isBeforeOrEqual ,
}
/* date-fns Not a pure module */

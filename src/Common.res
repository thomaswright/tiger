open Types

@val @scope(("document", "documentElement", "style"))
external setRootStyleProperty: (string, string) => unit = "setProperty"

@module("./useLocalStorage.js")
external useLocalStorage: (string, 'a) => ('a, ('a => 'a) => unit, unit => 'a) = "default"

@module("./useLocalStorage.js")
external useLocalStorageListener: (string, 'a) => 'a = "useLocalStorageListener"

@module("./other.js")
external focusPreviousClass: (string, Dom.element) => unit = "focusPreviousClass"

@module("./other.js")
external focusNextClass: (string, Dom.element) => unit = "focusNextClass"

@module("uuid") external uuid: unit => string = "v4"

// (Dom.element, string, unit, unit) => unit
@module("@formkit/auto-animate") external autoAnimate: Dom.element => unit = "default"
@module("@formkit/auto-animate/react")
external useAutoAnimate: unit => (Dom.element => unit, bool => unit) = "useAutoAnimate"

module StatusSelect = {
  @react.component @module("./StatusSelect.jsx")
  external make: (
    ~status: option<status>,
    ~setStatus: status => unit,
    ~focusTodo: unit => unit,
    ~isOpen: bool,
    ~onOpenChange: bool => unit,
  ) => React.element = "default"
}

module DateSelect = {
  @react.component @module("./DateSelect.jsx")
  external make: (
    ~value: option<Date.t>,
    ~onClick: option<Date.t> => unit,
    ~className: string,
  ) => React.element = "default"
}

let mapNullable = (n, f) =>
  n
  ->Nullable.toOption
  ->Option.mapOr((), f)

let arrayToggle = (a, match) => {
  a->Array.includes(match) ? a->Array.filter(el => el != match) : a->Array.concat([match])
}

module TextareaAutosize = {
  @react.component(: ReactDOM.domProps) @module("react-textarea-autosize")
  external make: ReactDOM.domProps => React.element = "default"
}

@module("./assets/tiger.svg") external logoUrl: string = "default"

@module("./exportFunctions.js")
external exportToJsonFile: string => unit = "exportToJsonFile"

module ImportButton = {
  @module("./Import.jsx") @react.component
  external make: (~onImportJson: array<'a> => unit) => React.element = "default"
}

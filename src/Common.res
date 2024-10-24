open Types

@module("./useLocalStorage.js")
external useLocalStorage: (string, 'a) => ('a, ('a => 'a) => unit, unit => 'a) = "default"

@module("./useLocalStorage.js")
external useLocalStorageListener: (string, 'a) => 'a = "useLocalStorageListener"

@module("./other.js")
external focusPreviousClass: (string, Dom.element) => unit = "focusPreviousClass"

@module("./other.js")
external focusNextClass: (string, Dom.element) => unit = "focusNextClass"

@module("uuid") external uuid: unit => string = "v4"

@module("@formkit/auto-animate") external autoAnimate: Dom.element => unit = "default"
@module("@formkit/auto-animate/react")
external useAutoAnimate: unit => (React.ref<RescriptCore.Nullable.t<'a>>, bool => unit) =
  "useAutoAnimate"

module StatusSelect = {
  @react.component @module("./StatusSelect.jsx")
  external make: (
    ~status: option<status>,
    ~setStatus: status => unit,
    ~focusTodo: unit => unit,
    ~isOpen: bool,
    ~isPinned: bool,
    ~isArchived: bool,
    ~onOpenChange: bool => unit,
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

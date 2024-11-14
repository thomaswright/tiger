open Types

let mapNullable = (n, f) =>
  n
  ->Nullable.toOption
  ->Option.mapOr((), f)

module TextareaAutosize = {
  @react.component(: ReactDOM.domProps) @module("react-textarea-autosize")
  external make: ReactDOM.domProps => React.element = "default"
}

@val @scope(("document", "documentElement", "style"))
external setRootStyleProperty: (string, string) => unit = "setProperty"

@module("./useLocalStorage.js")
external useLocalStorage: (string, 'a) => ('a, ('a => 'a) => unit, unit => 'a) = "default"

@module("./useSessionStorage.js")
external useSessionStorage: (string, 'a) => ('a, ('a => 'a) => unit, unit => 'a) = "default"

@module("./useLocalStorage.js")
external useLocalStorageListener: (string, 'a) => 'a = "useLocalStorageListener"

@module("./other.js")
external focusPreviousClass: (string, Dom.element) => unit = "focusPreviousClass"

@module("./other.js")
external focusNextClass: (string, Dom.element) => unit = "focusNextClass"

@module("@legendapp/state/react")
external observer: React.component<'a> => React.component<'a> = "observer"

@module("./utils/SupaLegend.ts")
external addTodo: (string, Nullable.t<string>, float) => string = "addTodo"

@module("./utils/SupaLegend.ts")
external setTodoText: (string, string) => unit = "setTodoText"

@module("./utils/SupaLegend.ts")
external setTodoAdditionalText: (string, string) => unit = "setTodoAdditionalText"

@module("./utils/SupaLegend.ts")
external setTodoDate: (string, Nullable.t<string>) => unit = "setTodoDate"

// @module("./utils/SupaLegend.ts")
// external setTodoOutfit: (string, outfit) => unit = "setTodoOutfit"

@module("./utils/SupaLegend.ts")
external setTodoMode: (string, mode) => unit = "setTodoMode"

@module("./utils/SupaLegend.ts")
external setTodoShowMode: (string, mode) => unit = "setTodoShowMode"

// @module("./utils/SupaLegend.ts")
// external setTodoHidden: (string, bool) => unit = "setTodoHidden"

@module("./utils/SupaLegend.ts")
external setTodoStatus: (string, status) => unit = "setTodoStatus"

@module("./utils/SupaLegend.ts")
external setTodoPosition: (string, Nullable.t<string>, float) => unit = "setTodoPosition"

// @module("./utils/SupaLegend.ts")
// external toggleDone: string => unit = "toggleDone"

@module("./utils/SupaLegend.ts")
external deleteTodo: string => unit = "deleteTodo"

@module("@legendapp/state")
external batch: (unit => unit) => unit = "batch"

@module("./assets/tiger.svg") external logoUrl: string = "default"

module StatusSelect = {
  @react.component @module("./StatusSelect.jsx")
  external make: (
    ~status: option<status>,
    ~setStatus: status => unit,
    ~focusTodo: unit => unit,
    ~isOpen: bool,
    ~onOpenChange: bool => unit,
    ~hasHidden: bool,
    ~mode: mode,
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

let toNullableNull = o =>
  switch o {
  | Some(v) => Nullable.Value(v)
  | None => Null
  }

let useDebounce = (~initialValue, ~onTrigger, ~delay) => {
  let (val, setVal) = React.useState(() => initialValue)

  let delayedSetRef = React.useRef(None)

  React.useEffect(() => {
    delayedSetRef.current->Option.mapOr((), x => {
      clearTimeout(x)
    })

    if val != initialValue {
      let id = setTimeout(() => {
        onTrigger(val)
      }, delay)
      delayedSetRef.current = Some(id)
    }

    None
  }, [val])

  (val, setVal)
}

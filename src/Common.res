open Types

let mapNullable = (n, f) =>
  n
  ->Nullable.toOption
  ->Option.mapOr((), f)

module TextareaAutosize = {
  @react.component(: ReactDOM.domProps) @module("react-textarea-autosize")
  external make: ReactDOM.domProps => React.element = "default"
}

let arrayToggle = (v, el) =>
  v->Array.includes(el) ? v->Array.filter(x => x != el) : v->Array.concat([el])

@send @scope("classList") external addClass: (Dom.element, string) => unit = "add"
@send @scope("classList") external removeClass: (Dom.element, string) => unit = "remove"
@send @scope("classList") external hasClass: (Dom.element, string) => bool = "contains"

@module("uuid")
external uuid: unit => string = "v4"

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
external addTodo: (string, string, (array<string>, string) => array<string>) => string = "addTodo"

// @module("./utils/SupaLegend.ts")
// external addTodoByImport: (string, string, Nullable.t<string>, float, status) => unit =
//   "addTodoByImport"

@module("./utils/SupaLegend.ts")
external setTodoText: (string, string) => unit = "setTodoText"

@module("./utils/SupaLegend.ts")
external setTodoAdditionalText: (string, string) => unit = "setTodoAdditionalText"

@module("./utils/SupaLegend.ts")
external setTodoDate: (string, Nullable.t<string>) => unit = "setTodoDate"

@module("./utils/SupaLegend.ts")
external setTodoMode: (string, mode) => unit = "setTodoMode"

@module("./utils/SupaLegend.ts")
external setTodoModesShown: (string, array<mode> => array<mode>) => unit = "setTodoModesShown"

@module("./utils/SupaLegend.ts")
external setTodoStatus: (string, status) => unit = "setTodoStatus"

@module("./utils/SupaLegend.ts")
external setTodoParent: (string, string) => unit = "setTodoParent"

@module("./utils/SupaLegend.ts")
external setTodoOrder: (string, array<string> => array<string>) => unit = "setTodoOrder"

@module("./utils/SupaLegend.ts")
external deleteTodo: (string, string) => unit = "deleteTodo"

@module("@legendapp/state")
external batch: (unit => unit) => unit = "batch"

@module("./assets/tiger.svg") external logoUrl: string = "default"

let deleteTodoAndMoveChildren = todoRelation => {
  let todo = todoRelation.self
  batch(() => {
    todo.parent_todo
    ->Nullable.toOption
    ->Option.mapOr((), parent_todo => {
      deleteTodo(todo.id, parent_todo)

      setTodoOrder(
        parent_todo,
        order =>
          order->Array.reduce([], (a, c) => Array.concat(a, c == todo.id ? todo.order : [c])),
      )
      todoRelation.children->Array.forEachWithIndex(
        (child, _i) => {
          setTodoParent(child.id, parent_todo)
        },
      )
    })
  })
}

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
    ~setMode: mode => unit,
    ~date: option<Date.t>,
    ~setDate: option<Date.t> => unit,
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

let groupByAndSort = (arr, groupByKey, sortByKey) => {
  arr
  ->Array.reduce(SMap.empty, (a, c) => {
    let key = c->groupByKey->Option.getOr("root")

    a->SMap.update(key, o =>
      switch o {
      | None => Some([c])
      | Some(v) => Some(v->Array.concat([c]))
      }
    )
  })
  ->SMap.map(v =>
    v->Array.toSorted((a, b) => {
      a->sortByKey -. b->sortByKey
    })
  )
}

module ImportButton = {
  @module("./Import.jsx") @react.component
  external make: (~onImportJson: array<'a> => unit) => React.element = "default"
}

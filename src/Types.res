module SMap = Belt.Map.String
module SSet = Belt.Set.String

type status =
  | @as("Unsorted") Unsorted
  | @as("Future") Future
  | @as("NowIfTime") NowIfTime
  | @as("NowMustDo") NowMustDo
  | @as("Underway") Underway
  | @as("Paused") Paused
  | @as("ResolveDone") ResolveDone
  | @as("ResolveNo") ResolveNo

type outfit =
  | @as("Todo") Todo
  | @as("Project") Project
  | @as("Group") Group

type mode =
  | @as("Working") Working
  | @as("Stashed") Stashed
  | @as("Archive") Archive

let modeCompare = mode =>
  switch mode {
  | Working => 0.
  | Stashed => 1.
  | Archive => 2.
  }

type todo = {
  id: string,
  counter: int,
  text: Nullable.t<string>,
  additional_text: Nullable.t<string>,
  created_at: string,
  updated_at: string,
  parent_todo: Nullable.t<string>,
  deleted: bool,
  user_id: string,
  order: array<string>,
  status: status,
  target_date: Nullable.t<string>,
  mode: mode,
  modes_shown: array<mode>,
  is_first_of_mode: option<mode>,
  is_last_of_mode: option<mode>,
}

type todoRelation = {
  self: todo,
  depth: int,
  index: int,
  parent: Nullable.t<todo>,
  parents: array<string>,
  hasHiddenChildren: bool,
  hasArchivedChildren: bool,
  hasStashedChildren: bool,
  parentIndex: int,
  tios: array<todo>,
  sibs: array<todo>,
  children: array<todo>,
}

type view = | @as("Settings") Settings | @as("ProjectList") ProjectList

let statusToFloat = s => {
  [Unsorted, Future, NowIfTime, NowMustDo, Underway, Paused, ResolveDone, ResolveNo]
  ->Array.findIndex(a => a == s)
  ->Int.toFloat
}

let statusIcon = s => {
  switch s {
  | Unsorted => <div />
  | Future => <Icons.Future />
  | NowIfTime => <Icons.Clock />
  | NowMustDo => <Icons.Hourglass />
  | Underway => <Icons.Play />
  | Paused => <Icons.Pause />
  | ResolveDone => <Icons.Check />
  | ResolveNo => <Icons.X />
  }
}

let statusStringShort = s => {
  switch s {
  | Unsorted => ""
  | Future => "*"
  | NowIfTime => "?"
  | NowMustDo => "!"
  | Underway => ">"
  | Paused => "="
  | ResolveDone => "v"
  | ResolveNo => "x"
  }
}

let statusString = s => {
  switch s {
  | Unsorted => ""
  | Future => "Future"
  | NowIfTime => "If Time"
  | NowMustDo => "Must Do"
  | Underway => "Underway"
  | Paused => "Paused"
  | ResolveDone => "Done"
  | ResolveNo => "No"
  }
}

let statusColor = s =>
  switch s {
  | Unsorted => "var(--t3)"
  | Future => "var(--pink)"
  | NowIfTime => "var(--yellow)"
  | NowMustDo => "var(--yellow)"
  | Underway => "var(--green)"
  | Paused => "var(--green)"
  | ResolveDone => "var(--blue)"
  | ResolveNo => "var(--t7)"
  }

let statusColorText = _ => "var(--t0)"

let getTodoId = s => "todo-" ++ s
let getTodoInputId = s => "todoInput-" ++ s
let getDropId = s => "drop-" ++ s
let getDragId = s => "drag-" ++ s

let getIdFromId = s => {
  if s->String.includes("todo-") {
    s
    ->String.split("todo-")
    ->Array.get(1)
    ->Option.map(v => v)
  } else if s->String.includes("todoInput-") {
    s
    ->String.split("todoInput-")
    ->Array.get(1)
    ->Option.map(v => v)
  } else if s->String.includes("drop-") {
    s
    ->String.split("drop-")
    ->Array.get(1)
    ->Option.map(v => v)
  } else {
    None
  }
}

let listItemClass = "class-list-item"
let todoInputClass = "class-list-todo-input"

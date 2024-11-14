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

type todo = {
  id: string,
  counter: int,
  text: Nullable.t<string>,
  additional_text: Nullable.t<string>,
  done: bool,
  created_at: string,
  updated_at: string,
  parent_todo: Nullable.t<string>,
  deleted: bool,
  user_id: string,
  position: float,
  status: status,
  outfit: outfit,
  target_date: Nullable.t<string>,
  hidden: bool,
}

type todoRelation = {
  self: todo,
  depth: int,
  index: int,
  parent: Nullable.t<todo>,
  hasHiddenChildren: bool,
  parentIndex: int,
  tios: array<todo>,
  sibs: array<todo>,
  children: array<todo>,
}

type view = | @as("Settings") Settings | @as("ProjectList") ProjectList

// nextSibPosition: option<float>,
// prevSibPosition: option<float>,
// nextSibId: option<string>,
// prevSibId: option<string>,
// nextSibIds: array<string>,
// lastSibPosition: option<float>,
// lastChildPosition: option<float>,

let statusToFloat = s => {
  [Unsorted, Future, NowIfTime, NowMustDo, Underway, Paused, ResolveDone, ResolveNo]
  ->Array.findIndex(a => a == s)
  ->Int.toFloat
}

let statusStringShort = s => {
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

let statusString = s => {
  switch s {
  | Unsorted => "Unsorted"
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
  | Unsorted => "var(--t2)"
  | Future => "var(--lightBlue)"
  | NowIfTime => "var(--lightOrange)"
  | NowMustDo => "var(--lightOrange)"
  | Underway => "var(--lightGreen)"
  | Paused => "var(--lightGreen)"
  | ResolveDone => "var(--lightPurple)"
  | ResolveNo => "var(--lightPurple)"
  }

let statusColorText = s =>
  switch s {
  | Unsorted => "var(--t8)"
  | Future => "var(--darkBlue)"
  | NowIfTime => "var(--darkOrange)"
  | NowMustDo => "var(--darkOrange)"
  | Underway => "var(--darkGreen)"
  | Paused => "var(--darkGreen)"
  | ResolveDone => "var(--darkPurple)"
  | ResolveNo => "var(--darkPurple)"
  }

let getTodoId = s => "todo-" ++ s
let getTodoInputId = s => "todo-input-" ++ s

// let getProjectId = s => "project-" ++ s
// let getProjectInputId = s => "project-input-" ++ s

let getIdFromId = s => {
  if s->String.includes("todo-") {
    s
    ->String.split("todo-")
    ->Array.get(1)
    ->Option.map(v => v)
  } else if s->String.includes("project-") {
    s
    ->String.split("project-")
    ->Array.get(1)
    ->Option.map(v => v)
  } else {
    None
  }
}

let listItemClass = "class-list-item"
let todoInputClass = "class-list-todo-input"

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
  | @as("ArchiveDone") ArchiveDone
  | @as("ArchiveNo") ArchiveNo

type box =
  | @as("Working") Working
  | @as("Pinned") Pinned
  | @as("Archive") Archive

type todo = {
  id: string,
  text: string,
  additionalText: string,
  project: string,
  status: status,
  // box: box,
  parentTodo: option<string>,
  depth: option<int>,
  childNumber: option<int>,
  hasArchivedChildren: bool,
  hasChildren: bool,
  ancArchived: bool,
  targetDate: option<string>,
}

type project = {
  id: string,
  name: string,
  additionalText: string,
  isActive: bool,
  todos: array<todo>,
  hideArchived: bool,
  hideAll: bool,
  hiddenTodos: SMap.t<array<todo>>,
}

type projectsTab = | @as("All") All | @as("Active") Active

type selectElement = Todo(string) | Project(string)

// let isArchiveStatus = s =>
//   switch s {
//   | ArchiveDone | ArchiveReject | ArchiveNoNeed | Trash => true
//   | _ => false
//   }

let statusToFloat = s => {
  [
    Unsorted,
    Future,
    NowIfTime,
    NowMustDo,
    Underway,
    Paused,
    ResolveDone,
    ResolveNo,
    ArchiveDone,
    ArchiveNo,
  ]
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
  | ArchiveDone => "Done"
  | ArchiveNo => "No"
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
  | ArchiveDone => "Done & Archived"
  | ArchiveNo => "No & Archived"
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
  | ArchiveDone => "var(--lightGray)"
  | ArchiveNo => "var(--lightGray)"
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
  | ArchiveDone => "var(--darkGray)"
  | ArchiveNo => "var(--darkGray)"
  }

let statusIsResolved = s =>
  switch s {
  | ResolveDone
  | ResolveNo => true
  | _ => false
  }

let getTodoId = s => "todo-" ++ s
let getTodoInputId = s => "todo-input-" ++ s

let getProjectId = s => "project-" ++ s
let getProjectInputId = s => "project-input-" ++ s

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

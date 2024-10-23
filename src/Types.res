type status =
  | @as("Underway") Underway
  | @as("Suspended") Suspended
  | @as("UnderwayWrapUp") UnderwayWrapUp
  | @as("NowUrgent") NowUrgent
  | @as("NowWillDo") NowWillDo
  | @as("NowIfTime") NowIfTime
  | @as("FutureSoon") FutureSoon
  | @as("FutureWillDo") FutureWillDo
  | @as("FutureConsider") FutureConsider
  | @as("ResolveDone") ResolveDone
  | @as("ResolveNo") ResolveNo
  | @as("ResolveScrap") ResolveScrap
  | @as("Unsorted") Unsorted

type box =
  | @as("Working") Working
  | @as("Pinned") Pinned
  | @as("Archive") Archive

type todo = {
  id: string,
  text: string,
  project: string,
  status: status,
  box: box,
  parentTodo: option<string>,
  depth: option<int>,
  childNumber: option<int>,
  hasArchivedChildren: bool,
  hasChildren: bool,
}

type project = {
  id: string,
  name: string,
  isActive: bool,
  todos: array<todo>,
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
    Underway,
    Suspended,
    UnderwayWrapUp,
    NowUrgent,
    NowWillDo,
    NowIfTime,
    FutureSoon,
    FutureWillDo,
    FutureConsider,
    ResolveDone,
    ResolveNo,
    ResolveScrap,
  ]
  ->Array.findIndex(a => a == s)
  ->Int.toFloat
}

let statusStringShort = s => {
  switch s {
  | Unsorted => ""
  | Underway => "Underway"
  | Suspended => "Paused"
  | UnderwayWrapUp => "Wrap Up"
  | NowUrgent => "Must Do"
  | NowWillDo => "If Time"
  | NowIfTime => "If Time"
  | FutureSoon => "Soon"
  | FutureWillDo => "Future"
  | FutureConsider => "Consider"
  | ResolveDone => "Done"
  | ResolveNo => "Scrap"
  | ResolveScrap => "Scrap"
  }
}

let statusString = s => {
  switch s {
  | Unsorted => "No Status"
  | Underway => "Underway"
  | Suspended => "Underway: Paused"
  | UnderwayWrapUp => "Underway: Wrap Up"
  | NowUrgent => "Now: Must Do"
  | NowWillDo => "Now: If Time"
  | NowIfTime => "Now: If Time"
  | FutureSoon => "Future: Soon"
  | FutureWillDo => "Future"
  | FutureConsider => "Future: Consider"
  | ResolveDone => "Resolved: Done"
  | ResolveNo => "Resolved: Scrap"
  | ResolveScrap => "Resolved: Scrap"
  }
}

let statusColor = s =>
  switch s {
  | Unsorted => "var(--Unsorted)"
  | Underway => "var(--Underway)"
  | Suspended => "var(--Suspended)"
  | UnderwayWrapUp => "var(--UnderwayWrapUp)"
  | NowUrgent => "var(--NowUrgent)"
  | NowWillDo => "var(--NowWillDo)"
  | NowIfTime => "var(--NowIfTime)"
  | FutureSoon => "var(--FutureSoon)"
  | FutureWillDo => "var(--FutureWillDo)"
  | FutureConsider => "var(--FutureConsider)"
  | ResolveDone => "var(--ResolveDone)"
  | ResolveNo => "var(--ResolveNo)"
  | ResolveScrap => "var(--ResolveScrap)"
  }

let statusColorText = s =>
  switch s {
  | Unsorted => "var(--UnsortedText)"
  | Underway => "var(--UnderwayText)"
  | Suspended => "var(--SuspendedText)"
  | UnderwayWrapUp => "var(--UnderwayWrapUpText)"
  | NowUrgent => "var(--NowUrgentText)"
  | NowWillDo => "var(--NowWillDoText)"
  | NowIfTime => "var(--NowIfTimeText)"
  | FutureSoon => "var(--FutureSoonText)"
  | FutureWillDo => "var(--FutureWillDoText)"
  | FutureConsider => "var(--FutureConsiderText)"
  | ResolveDone => "var(--ResolveDoneText)"
  | ResolveNo => "var(--ResolveNoText)"
  | ResolveScrap => "var(--ResolveScrapText)"
  }

let statusIsResolved = s =>
  switch s {
  | ResolveDone
  | ResolveNo
  | ResolveScrap => true
  | _ => false
  }

let getTodoId = s => "todo-" ++ s
let getTodoInputId = s => "todo-input-" ++ s

let getProjectId = s => "project-" ++ s
let getProjectInputId = s => "project-input-" ++ s

let listItemClass = "class-list-item"
let todoInputClass = "class-list-todo-input"

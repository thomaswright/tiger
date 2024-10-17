type status =
  | @as("TodoUrgent") TodoUrgent
  | @as("TodoHigh") TodoHigh
  | @as("TodoMedium") TodoMedium
  | @as("TodoLow") TodoLow
  | @as("LaterWill") LaterWill
  | @as("LaterMaybe") LaterMaybe
  | @as("LaterUnlikely") LaterUnlikely
  | @as("LaterUnsorted") LaterUnsorted
  | @as("ResolveDone") ResolveDone
  | @as("ResolveReject") ResolveReject
  | @as("ResolveNoNeed") ResolveNoNeed
  | @as("ArchiveDone") ArchiveDone
  | @as("ArchiveReject") ArchiveReject
  | @as("ArchiveNoNeed") ArchiveNoNeed
  | @as("Trash") Trash

type todo = {
  id: string,
  text: string,
  project: string,
  isDone: bool,
  status: status,
}

type project = {
  id: string,
  name: string,
  isActive: bool,
}

type projectsTab = | @as("All") All | @as("Active") Active

type selectElement = Todo(string) | Project(string)

let isArchiveStatus = s =>
  switch s {
  | ArchiveDone | ArchiveReject | ArchiveNoNeed | Trash => true
  | _ => false
  }

let statusToFloat = s => {
  switch s {
  | TodoUrgent => 0.
  | TodoHigh => 1.
  | TodoMedium => 2.
  | TodoLow => 3.
  | LaterWill => 4.
  | LaterMaybe => 5.
  | LaterUnlikely => 6.
  | LaterUnsorted => 7.
  | ResolveDone => 8.
  | ResolveReject => 9.
  | ResolveNoNeed => 10.
  | ArchiveDone => 11.
  | ArchiveReject => 12.
  | ArchiveNoNeed => 13.
  | Trash => 14.
  }
}

let statusString = s => {
  switch s {
  | TodoUrgent => "Todo: Urgent"
  | TodoHigh => "Todo: High"
  | TodoMedium => "Todo: Medium"
  | TodoLow => "Todo: Low"
  | LaterWill => "Later: Will Do"
  | LaterMaybe => "Later: Maybe"
  | LaterUnlikely => "Later: Unlikely"
  | LaterUnsorted => "Later: Unsorted"
  | ResolveDone => "Resolve: Done"
  | ResolveReject => "Resolve: Reject"
  | ResolveNoNeed => "Resolve: No Need"
  | ArchiveDone => "Archive: Done"
  | ArchiveReject => "Archive: Reject"
  | ArchiveNoNeed => "Archive: No Need"
  | Trash => "Trash"
  }
}

let statusStringShort = s => {
  switch s {
  | TodoUrgent => "!"
  | TodoHigh => "1"
  | TodoMedium => "2"
  | TodoLow => "3"
  | LaterWill => "A"
  | LaterMaybe => "B"
  | LaterUnlikely => "C"
  | LaterUnsorted => "-"
  | ResolveDone => "✔︎"
  | ResolveReject => "🞫"
  | ResolveNoNeed => "○"
  | ArchiveDone => "✔︎"
  | ArchiveReject => "🞫"
  | ArchiveNoNeed => "○"
  | Trash => "T"
  }
}

let statusColor = s =>
  switch s {
  | TodoUrgent => "var(--todoU)"
  | TodoHigh => "var(--todo1)"
  | TodoMedium => "var(--todo2)"
  | TodoLow => "var(--todo3)"
  | LaterWill => "var(--later)"
  | LaterMaybe => "var(--later)"
  | LaterUnlikely => "var(--later)"
  | LaterUnsorted => "var(--later)"
  | ResolveDone => "var(--resolve)"
  | ResolveReject => "var(--resolve)"
  | ResolveNoNeed => "var(--resolve)"
  | ArchiveDone => "var(--archive)"
  | ArchiveReject => "var(--archive)"
  | ArchiveNoNeed => "var(--archive)"
  | Trash => "var(--archive)"
  }

let getProjectId = s => "project-" ++ s
let getTodoId = s => "todo-" ++ s
let getTodoInputId = s => "todo-input-" ++ s

let listItemClass = "class-list-item"
let todoInputClass = "class-list-todo-input"

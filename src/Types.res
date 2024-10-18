// "Must"
// "If Have Time"
// "Maybe Do"
// "Will Do"
// "Unlikely"
// "Think About"
// "Future"
// "Half Done"
// "In Progress"
// "No"
// "Scrap"
// "Done"

type status =
  | @as("Urgent") Urgent
  | @as("High") High
  | @as("Medium") Medium
  | @as("Low") Low
  | @as("Will") Will
  | @as("Maybe") Maybe
  | @as("Unlikely") Unlikely
  | @as("Unsorted") Unsorted
  | @as("Done") Done
  | @as("Rejected") Rejected
  | @as("Closed") Closed

type box =
  | @as("Working") Working
  | @as("Pinned") Pinned
  | @as("Archive") Archive

type todo = {
  id: string,
  text: string,
  project: string,
  isDone: bool,
  status: status,
  box: box,
}

type project = {
  id: string,
  name: string,
  isActive: bool,
}

type projectsTab = | @as("All") All | @as("Active") Active

type selectElement = Todo(string) | Project(string)

// let isArchiveStatus = s =>
//   switch s {
//   | ArchiveDone | ArchiveReject | ArchiveNoNeed | Trash => true
//   | _ => false
//   }

let statusToFloat = s => {
  switch s {
  | Urgent => 0.
  | High => 1.
  | Medium => 2.
  | Low => 3.
  | Will => 4.
  | Maybe => 5.
  | Unlikely => 6.
  | Unsorted => 7.
  | Done => 8.
  | Rejected => 9.
  | Closed => 10.
  }
}

let statusString = s => {
  switch s {
  | Urgent => "Todo: Urgent"
  | High => "Todo: High"
  | Medium => "Todo: Medium"
  | Low => "Todo: Low"
  | Will => "Later: Will"
  | Maybe => "Later: Maybe"
  | Unlikely => "Later: Unlikely"
  | Unsorted => "Later: Unsorted"
  | Done => "Resolve: Done"
  | Rejected => "Resolve: Reject"
  | Closed => "Resolve: Close"
  }
}

let statusStringShort = s => {
  switch s {
  | Urgent => "!"
  | High => "High"
  | Medium => "Med"
  | Low => "Low"
  | Will => "Will"
  | Maybe => "May"
  | Unlikely => "Slim"
  | Unsorted => ""
  | Done => "✔︎"
  | Rejected => "🞫"
  | Closed => "-"

  // | TodoUrgent => "!"
  // | TodoHigh => "High"
  // | TodoMedium => "Med"
  // | TodoLow => "Low"
  // | LaterWill => "Will"
  // | LaterMaybe => "May"
  // | LaterUnlikely => "Slim"
  // | LaterUnsorted => ""
  // | ResolveDone => "✔︎"
  // | ResolveReject => "🞫"
  // | ResolveNoNeed => "-"
  // | ArchiveDone => "✔︎"
  // | ArchiveReject => "🞫"
  // | ArchiveNoNeed => "-"
  // | Trash => "T"
  }
}

// let statusIcon = s => {
//   switch s {
//   | TodoUrgent => "!"->React.string
//   | TodoHigh => "1"->React.string
//   | TodoMedium => "2"->React.string
//   | TodoLow => "3"->React.string
//   | LaterWill => "A"->React.string
//   | LaterMaybe => "B"->React.string
//   | LaterUnlikely => "C"->React.string
//   | LaterUnsorted => <Icons.Minus />
//   | ResolveDone => <Icons.Check />
//   | ResolveReject => <Icons.X />
//   | ResolveNoNeed => <Icons.Slash />
//   | ArchiveDone => <Icons.Check />
//   | ArchiveReject => <Icons.X />
//   | ArchiveNoNeed => <Icons.Slash />
//   | Trash => <Icons.Trash />
//   }
// }

let statusColor = s =>
  switch s {
  | Urgent => "var(--urgent)"
  | High => "var(--high)"
  | Medium => "var(--medium)"
  | Low => "var(--low)"
  | Will => "var(--will)"
  | Maybe => "var(--maybe)"
  | Unlikely => "var(--unlikely)"
  | Unsorted => "var(--unsorted)"
  | Done => "var(--done)"
  | Rejected => "var(--rejected)"
  | Closed => "var(--closed)"
  }

let getProjectId = s => "project-" ++ s
let getTodoId = s => "todo-" ++ s
let getTodoInputId = s => "todo-input-" ++ s

let listItemClass = "class-list-item"
let todoInputClass = "class-list-todo-input"

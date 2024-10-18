type status =
  | @as("Underway") Underway
  | @as("UnderwayHalfDone") UnderwayHalfDone
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
  [
    Unsorted,
    Underway,
    UnderwayHalfDone,
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

let statusString = s => {
  switch s {
  | Unsorted => ""
  | Underway => "Underway"
  | UnderwayHalfDone => "Half Done"
  | UnderwayWrapUp => "Wrap Up"
  | NowUrgent => "Urgent"
  | NowWillDo => "Will Do"
  | NowIfTime => "If Time"
  | FutureSoon => "Soon"
  | FutureWillDo => "Future"
  | FutureConsider => "Consider"
  | ResolveDone => "Done"
  | ResolveNo => "No"
  | ResolveScrap => "Scrap"
  }
}

let statusStringShort = statusString

// = s => {
//   switch s {
//   | Urgent => "!"
//   | High => "High"
//   | Medium => "Med"
//   | Low => "Low"
//   | Will => "Will"
//   | Maybe => "May"
//   | Unlikely => "Slim"
//   | Unsorted => ""
//   | Done => "✔︎"
//   | Rejected => "🞫"
//   | Closed => "-"

//   // | TodoUrgent => "!"
//   // | TodoHigh => "High"
//   // | TodoMedium => "Med"
//   // | TodoLow => "Low"
//   // | LaterWill => "Will"
//   // | LaterMaybe => "May"
//   // | LaterUnlikely => "Slim"
//   // | LaterUnsorted => ""
//   // | ResolveDone => "✔︎"
//   // | ResolveReject => "🞫"
//   // | ResolveNoNeed => "-"
//   // | ArchiveDone => "✔︎"
//   // | ArchiveReject => "🞫"
//   // | ArchiveNoNeed => "-"
//   // | Trash => "T"
//   }
// }

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
  | Unsorted => "var(--Unsorted)"
  | Underway => "var(--Underway)"
  | UnderwayHalfDone => "var(--UnderwayHalfDone)"
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
  | UnderwayHalfDone => "var(--UnderwayHalfDoneText)"
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

let getProjectId = s => "project-" ++ s
let getTodoId = s => "todo-" ++ s
let getTodoInputId = s => "todo-input-" ++ s

let listItemClass = "class-list-item"
let todoInputClass = "class-list-todo-input"

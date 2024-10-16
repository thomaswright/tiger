type status =
  | TodoUrgent
  | TodoHigh
  | TodoMedium
  | TodoLow
  | LaterWill
  | LaterMaybe
  | LaterUnlikely
  | LaterUnsorted
  | ResolveDone
  | ResolveWont
  | ResolveNoNeed
  | ArchiveDone
  | ArchiveWont
  | ArchiveNoNeed

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

let isArchiveStatus = s =>
  switch s {
  | ArchiveDone | ArchiveWont | ArchiveNoNeed => true
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
  | ResolveWont => 9.
  | ResolveNoNeed => 10.
  | ArchiveDone => 11.
  | ArchiveWont => 12.
  | ArchiveNoNeed => 13.
  }
}

let statusString = s => {
  switch s {
  | TodoUrgent => "TodoUrgent"
  | TodoHigh => "TodoHigh"
  | TodoMedium => "TodoMedium"
  | TodoLow => "TodoLow"
  | LaterWill => "LaterWill"
  | LaterMaybe => "LaterMaybe"
  | LaterUnlikely => "LaterUnlikely"
  | LaterUnsorted => "LaterUnsorted"
  | ResolveDone => "ResolveDone"
  | ResolveWont => "ResolveWont"
  | ResolveNoNeed => "ResolveNoNeed"
  | ArchiveDone => "ArchiveDone"
  | ArchiveWont => "ArchiveWont"
  | ArchiveNoNeed => "ArchiveNoNeed"
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
  | ResolveWont => "🞫"
  | ResolveNoNeed => "○"
  | ArchiveDone => "✔︎"
  | ArchiveWont => "🞫"
  | ArchiveNoNeed => "○"
  }
}

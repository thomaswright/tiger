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

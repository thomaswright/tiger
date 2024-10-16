type keepStatus =
  | Unsorted
  | DoneKeep
  | TodoUrgent
  | TodoHigh
  | TodoMedium
  | TodoLow
  | LaterWill
  | LaterMaybe
  | LaterUnlikely
  | LaterWont

type archiveStatus =
  | DoneArchive
  | Rejected
  | Mitigated
  | NotNeeded
  | Duplicate

type status = Archive(archiveStatus) | Keep(keepStatus)

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

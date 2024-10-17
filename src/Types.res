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

let isArchiveStatus = s =>
  switch s {
  | ArchiveDone | ArchiveReject | ArchiveNoNeed => true
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
  | TodoUrgent => "Urgent"
  | TodoHigh => "High"
  | TodoMedium => "Medium"
  | TodoLow => "Low"
  | LaterWill => "Will Do"
  | LaterMaybe => "Maybe"
  | LaterUnlikely => "Unlikely"
  | LaterUnsorted => "Unsorted"
  | ResolveDone => "Done"
  | ResolveReject => "Reject"
  | ResolveNoNeed => "No Need"
  | ArchiveDone => "Done"
  | ArchiveReject => "Reject"
  | ArchiveNoNeed => "No Need"
  | Trash => "Delete"
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
  | Trash => "D"
  }
}

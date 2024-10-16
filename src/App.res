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

type projectsTab = All | Active

let defaultProjects = [
  {
    id: "1",
    name: "Project Omega",
    isActive: true,
  },
]
let defaultTodos = [
  {
    text: "Do Something",
    project: "1",
    id: "1",
    isDone: false,
    status: Keep(LaterWill),
  },
  {
    text: "Do Something Else",
    project: "1",
    id: "2",
    isDone: false,
    status: Archive(Rejected),
  },
]

// let filterMap = (m, f) => m ->
// Map.entries -> Array.fromIterator -> Array.filter(f) -> Map.fromArray

// let mapToArray = m => m ->
// Map.entries -> Array.fromIterator

@react.component
let make = () => {
  let (projects, setProjects, _) = Common.useLocalStorage("projects", defaultProjects)
  let (todos, setTodos, _) = Common.useLocalStorage("todos", defaultTodos)
  let (showArchiveProjects, setShowArchiveProjects, _) = Common.useLocalStorage(
    "showArchiveProjects",
    Set.fromArray([]),
  )
  let (projectsTab, setProjectTab, _) = Common.useLocalStorage("projectsTab", All)

  <div className="p-6">
    <div className="flex flex-row gap-2">
      <button
        onClick={_ => setProjectTab(_ => All)}
        className={[
          "w-20 rounded",
          projectsTab == All ? "bg-slate-800 text-white" : "bg-slate-200 text-black",
        ]->Array.join(" ")}>
        {"All"->React.string}
      </button>
      <button
        onClick={_ => setProjectTab(_ => Active)}
        className={[
          "w-20 rounded",
          projectsTab == Active ? "bg-slate-800 text-white" : "bg-slate-200 text-black",
        ]->Array.join(" ")}>
        {"Active"->React.string}
      </button>
    </div>
    <div>
      {projects
      ->Array.filter(v => v.isActive)
      ->Array.map(v => <div> {v.name->Jsx.string} </div>)
      ->Jsx.array}
    </div>
  </div>
}

open Types

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
  let (showArchive, setShowArchive, _) = Common.useLocalStorage("showArchive", [])
  let (projectsTab, setProjectTab, _) = Common.useLocalStorage("projectsTab", All)
  let updateProject = React.useCallback0((id, f) => {
    setProjects(v => v->Array.map(project => project.id == id ? f(project) : project))
  })

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
      ->Array.filter(project => projectsTab == Active ? project.isActive : true)
      ->Array.map(project =>
        <Project
          showArchive={showArchive->Array.includes(project.id)}
          setShowArchive={setShowArchive}
          project
          todos={todos->Array.filter(todo => todo.project == project.id)}
          updateProject
        />
      )
      ->React.array}
    </div>
  </div>
}

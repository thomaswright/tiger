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
    status: LaterUnsorted,
  },
  {
    text: "Do Something Else",
    project: "1",
    id: "2",
    isDone: false,
    status: ArchiveNoNeed,
  },
]

// let filterMap = (m, f) => m ->
// Map.entries -> Array.fromIterator -> Array.filter(f) -> Map.fromArray

// let mapToArray = m => m ->
// Map.entries -> Array.fromIterator

module Details = {
  @react.component
  let make = (~selectElement) => {
    <div className=" border-l flex-1"> {"Details"->React.string} </div>
  }
}

@react.component
let make = () => {
  let (projects, setProjects, _) = Common.useLocalStorage("projects", defaultProjects)
  let (todos, setTodos, _) = Common.useLocalStorage("todos", defaultTodos)
  let (showArchive, setShowArchive, _) = Common.useLocalStorage("showArchive", [])
  let (projectsTab, setProjectTab, _) = Common.useLocalStorage("projectsTab", All)
  let (selectElement, setSelectElement) = React.useState(_ => None)

  let updateProject = React.useCallback0((id, f) => {
    setProjects(v => v->Array.map(project => project.id == id ? f(project) : project))
  })
  let updateTodo = React.useCallback0((id, f) => {
    setTodos(v => v->Array.map(todo => todo.id == id ? f(todo) : todo))
  })

  <div className="flex flex-row h-dvh">
    // <StatusSelector />
    <div className="flex-1">
      <div className="flex flex-row gap-2">
        <button
          onClick={_ => setProjectTab(_ => All)}
          className={[
            "w-20  border-b-2",
            projectsTab == All ? "border-red-500 text-red-500" : "border-transparent ",
          ]->Array.join(" ")}>
          {"All"->React.string}
        </button>
        <button
          onClick={_ => setProjectTab(_ => Active)}
          className={[
            "w-20  border-b-2",
            projectsTab == Active ? "border-red-500 text-red-500" : "border-transparent ",
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
            updateTodo
            selectElement
            setSelectElement
          />
        )
        ->React.array}
      </div>
    </div>
    <div className=" border-l flex-1">
      {switch selectElement {
      | Some(Todo(todoId)) => todoId->React.string
      | Some(Project(projectId)) => projectId->React.string
      | _ => React.null
      }}
    </div>
  </div>
}

open Types
open Webapi.Dom

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
    status: Unsorted,
    box: Working,
  },
  {
    text: "Do Something Else",
    project: "1",
    id: "2",
    isDone: false,
    status: Unsorted,
    box: Archive,
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

module Switch = {
  @module("./Switch.jsx") @react.component
  external make: (~checked: bool, ~onCheckedChange: unit => unit) => React.element = "Switch"
}

@react.component
let make = () => {
  let (projects, setProjects, _) = Common.useLocalStorage("projects", defaultProjects)
  let (todos, setTodos, getTodos) = Common.useLocalStorage("todos", defaultTodos)
  let (showArchive, setShowArchive, _) = Common.useLocalStorage("showArchive", [])
  let (projectsTab, setProjectTab, _) = Common.useLocalStorage("projectsTab", All)
  let (selectElement, setSelectElement) = React.useState(_ => None)
  let (displayElement, setDisplayElement) = React.useState(_ => None)
  let (focusClassNext, setFocusClassNext) = React.useState(_ => None)
  let (focusIdNext, setFocusIdNext) = React.useState(_ => None)

  let updateProject = React.useCallback0((id, f) => {
    setProjects(v => v->Array.map(project => project.id == id ? f(project) : project))
  })
  let updateTodo = React.useCallback0((id, f) => {
    setTodos(v => v->Array.map(todo => todo.id == id ? f(todo) : todo))
  })

  React.useEffectOnEveryRender(() => {
    focusClassNext
    ->Option.flatMap(x =>
      document
      ->Document.getElementsByClassName(x)
      ->HtmlCollection.toArray
      ->Array.get(0)
    )
    ->Option.mapOr((), element => {
      element->Obj.magic->HtmlElement.focus
      setFocusClassNext(_ => None)
    })

    focusIdNext
    ->Option.flatMap(x => document->Document.getElementById(x))
    ->Option.mapOr((), element => {
      element->Obj.magic->HtmlElement.focus
      setFocusIdNext(_ => None)
    })

    None
  })

  <div className="flex flex-row h-dvh">
    // <StatusSelector />
    <div className="flex-1">
      <div className="flex flex-row gap-2 justify-between w-full p-1">
        <div className="flex flex-row gap-2 ">
          <div className="text-sm"> {"Show NonActive"->React.string} </div>
          <Switch
            checked={projectsTab == All}
            onCheckedChange={() => setProjectTab(v => v == All ? Active : All)}
          />
        </div>
        <button
          onClick={_ => {
            let newProjectId = Common.uuid()
            setProjects(v =>
              Array.concat(
                [
                  {
                    id: newProjectId,
                    name: "",
                    isActive: true,
                  },
                ],
                v,
              )
            )
            setSelectElement(_ => Some(Project(newProjectId)))
            setDisplayElement(_ => Some(Project(newProjectId)))
            setFocusClassNext(_ => Some("class-display-title"))
          }}
          className={["bg-[var(--t2)] px-2 rounded text-sm"]->Array.join(" ")}>
          {"Add Project"->React.string}
        </button>
      </div>
      <div>
        {projects
        ->Array.filter(project => projectsTab == Active ? project.isActive : true)
        ->Array.map(project =>
          <Project
            key={getProjectId(project.id)}
            showArchive={showArchive->Array.includes(project.id)}
            setShowArchive={setShowArchive}
            project
            todos={todos->Array.filter(todo => todo.project == project.id)}
            updateProject
            updateTodo
            selectElement
            setSelectElement
            displayElement
            setDisplayElement
            setFocusIdNext
            setTodos
            getTodos
          />
        )
        ->React.array}
      </div>
    </div>
    <div className=" border-l flex-1">
      {switch displayElement {
      | Some(Todo(todoId)) =>
        todos
        ->Array.find(t => t.id == todoId)
        ->Option.mapOr(React.null, todo => {
          <DisplayTodo todo setFocusIdNext updateTodo setTodos />
        })
      | Some(Project(projectId)) =>
        projects
        ->Array.find(p => p.id == projectId)
        ->Option.mapOr(React.null, project => {
          <DisplayProject project updateProject setProjects setTodos />
        })
      | _ => React.null
      }}
    </div>
  </div>
}

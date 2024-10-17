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
      <div className="flex flex-row gap-2">
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
          className={["bg-slate-200 px-2 rounded"]->Array.join(" ")}>
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
          <div>
            <input
              type_="text"
              id="id-display-title"
              className={[
                "px-2 flex-1 bg-inherit text-[--foreground] w-full outline-none 
          leading-none padding-none border-none h-5 -my-1 focus:text-blue-500",
              ]->Array.join(" ")}
              placeholder={"Todo Text"}
              value={todo.text}
              onKeyDown={e => {
                if e->ReactEvent.Keyboard.key == "Escape" {
                  setFocusIdNext(_ => Some(getTodoId(todo.id)))
                }
              }}
              onChange={e => {
                updateTodo(todo.id, t => {
                  ...t,
                  text: ReactEvent.Form.target(e)["value"],
                })
              }}
            />
          </div>
        })
      | Some(Project(projectId)) =>
        projects
        ->Array.find(p => p.id == projectId)
        ->Option.mapOr(React.null, project => {
          <div>
            <input
              type_="text"
              id="id-display-title"
              className={[
                " flex-1 bg-inherit text-[--foreground] w-full outline-none 
          leading-none padding-none border-none h-5 -my-1 focus:text-blue-500",
              ]->Array.join(" ")}
              placeholder={"Project Name"}
              value={project.name}
              onKeyDown={e => {
                if e->ReactEvent.Keyboard.key == "Escape" {
                  setFocusIdNext(_ => Some(getProjectId(project.id)))
                }
              }}
              onChange={e => {
                updateProject(project.id, p => {
                  ...p,
                  name: ReactEvent.Form.target(e)["value"],
                })
              }}
            />
          </div>
        })
      | _ => React.null
      }}
    </div>
  </div>
}

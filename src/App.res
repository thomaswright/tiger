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
    status: Unsorted,
    box: Working,
    parentTodo: None,
    depth: None,
    childNumber: None,
  },
  {
    text: "Do Something Else",
    project: "1",
    id: "2",
    status: ResolveScrap,
    box: Archive,
    parentTodo: None,
    depth: None,
    childNumber: None,
  },
]

// let filterMap = (m, f) => m ->
// Map.entries -> Array.fromIterator -> Array.filter(f) -> Map.fromArray

// let mapToArray = m => m ->
// Map.entries -> Array.fromIterator

module Details = {
  @react.component
  let make = (~selectedElement) => {
    <div className=" border-l flex-1"> {"Details"->React.string} </div>
  }
}

module Switch = {
  @module("./Switch.jsx") @react.component
  external make: (~checked: bool, ~onCheckedChange: unit => unit) => React.element = "Switch"
}

module Map = Belt.Map.String

let buildTodoTree = (input: array<todo>) => {
  let rootMapId = "_"
  let parentMap = input->Array.reduce(Map.empty, (a, c) => {
    let mapId = c.parentTodo->Option.getOr(rootMapId)
    a->Map.update(mapId, v => v->Option.mapOr([c], v => Array.concat(v, [c]))->Some)
  })

  let mutParentMap = ref(parentMap)

  let rec build = (arr, mapId, depth) => {
    let children = mutParentMap.contents->Map.get(mapId)
    // this is to prevent accidental inf loops
    mutParentMap := mutParentMap.contents->Map.remove(mapId)

    children
    ->Option.getOr([])
    ->Array.reduceWithIndex(arr, (a, todo, i) => {
      build(
        a->Array.concat([
          {
            ...todo,
            depth: Some(depth),
            childNumber: Some(i),
          },
        ]),
        todo.id,
        depth + 1,
      )
    })
  }

  build([], rootMapId, 0)
}

// const groupedItems = items.reduce((group, item) => {
//   // Get the group key (category in this case)
//   const key = item.category;

//   // If the group doesn't exist, create it
//   if (!group[key]) {
//     group[key] = [];
//   }

//   // Push the item into the appropriate group
//   group[key].push(item);

//   // Return the updated group
//   return group;
// }, {});

// let rec f = (input) => {
//   let left = ref([...input])

//   while (left -> Array.length > 0) {
//     let c = left[0]
//     let rest = left -> Array.sliceToEnd(~start=1)
//     let (children, notChildren) = rest -> Belt.Array.partition((v) => v.parentTodo == c.id)
//     let result :=
//     result.contents->
//     Array.concat([c])
//     ->Array.concat(f(children))
//     let left := notChildren

//   }
// }

module CheckedSummary = {
  @react.component
  let make = (
    ~checked,
    ~todos: array<todo>,
    ~setChecked,
    ~setTodos: (array<Types.todo> => array<Types.todo>) => unit,
  ) => {
    let (statusSelectIsOpen, setStatusSelectIsOpen) = React.useState(() => false)

    <div className="h-8 text-sm px-2 flex flex-row gap-2 items-center border-b">
      {if checked->Array.length < 2 {
        React.null
      } else {
        <React.Fragment>
          <Common.StatusSelect
            isPinned={false}
            isArchived={false}
            isOpen={statusSelectIsOpen}
            onOpenChange={v => {
              setStatusSelectIsOpen(_ => v)
            }}
            status={
              let checkedTodos = todos->Array.filter(t => checked->Array.includes(t.id))
              checkedTodos
              ->Array.get(0)
              ->Option.flatMap(first => {
                if checkedTodos->Array.every(t => t.status == first.status) {
                  Some(first.status)
                } else {
                  None
                }
              })
            }
            focusTodo={() => {()}}
            setStatus={newStatus =>
              setTodos(todos =>
                todos->Array.map(t => {
                  if checked->Array.includes(t.id) {
                    {
                      ...t,
                      status: newStatus,
                      box: t.box == Archive && !(newStatus->statusIsResolved) ? Working : t.box,
                    }
                  } else {
                    t
                  }
                })
              )}
          />
          {`${checked->Array.length->Int.toString} Checked`->React.string}
          <div className="flex-1" />
          <button className="px-2" onClick={_ => setChecked(_ => [])}>
            {"Clear"->React.string}
          </button>
        </React.Fragment>
      }}
    </div>
  }
}
@react.component
let make = () => {
  let (projects, setProjects, _) = Common.useLocalStorage("projects", defaultProjects)
  let (todos, setTodos, getTodos) = Common.useLocalStorage("todos", defaultTodos)
  let (showArchive, setShowArchive, _) = Common.useLocalStorage("showArchive", [])
  let (checked, setChecked, _) = Common.useLocalStorage("checked", [])
  let (projectsTab, setProjectTab, _) = Common.useLocalStorage("projectsTab", All)
  let (selectedElement, setSelectedElement) = React.useState(_ => None)
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

  let deleteTodo = (todo: todo) =>
    setTodos(todos =>
      todos
      ->Array.filter(t => t.id != todo.id)
      ->Array.map(t => {
        if t.parentTodo == Some(todo.id) {
          {
            ...t,
            parentTodo: todo.parentTodo,
          }
        } else {
          t
        }
      })
    )

  <div className="flex flex-row h-dvh">
    // <StatusSelector />
    <div className="flex-1">
      <div className="flex flex-row gap-2 justify-between w-full p-1">
        <div className="flex flex-row gap-2 ">
          <div className="text-sm"> {"Show Inactive"->React.string} </div>
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
            setSelectedElement(_ => Some(Project(newProjectId)))
            setDisplayElement(_ => Some(Project(newProjectId)))
            setFocusClassNext(_ => Some("class-display-title"))
          }}
          className={[
            "bg-[var(--t2)] px-2 rounded text-xs flex flex-row items-center gap-1",
          ]->Array.join(" ")}>
          <Icons.Plus />
          {"Project"->React.string}
        </button>
      </div>
      <div>
        {projects
        ->Array.filter(project => projectsTab == Active ? project.isActive : true)
        ->Array.map(project => {
          let showArchive = showArchive->Array.includes(project.id)
          let projectTodos =
            todos
            ->Array.filter(todo => todo.project == project.id)
            ->Array.filter(todo => showArchive ? true : todo.box != Archive)
            ->buildTodoTree
          <Project
            key={getProjectId(project.id)}
            showArchive={showArchive}
            setShowArchive={setShowArchive}
            project
            todos={projectTodos}
            updateProject
            updateTodo
            selectedElement
            setSelectedElement
            displayElement
            setDisplayElement
            setFocusIdNext
            setTodos
            getTodos={() => projectTodos}
            setChecked
            checked
            deleteTodo
          />
        })
        ->React.array}
      </div>
    </div>
    <div className=" border-l flex-1">
      <CheckedSummary checked={checked} todos={todos} setChecked={setChecked} setTodos />
      {switch displayElement {
      | Some(Todo(todoId)) =>
        todos
        ->Array.find(t => t.id == todoId)
        ->Option.mapOr(React.null, todo => {
          <DisplayTodo todo setFocusIdNext updateTodo setTodos deleteTodo />
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

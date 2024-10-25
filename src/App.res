open Types
open Webapi.Dom

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
    hasArchivedChildren: false,
    hasChildren: false,
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
    hasArchivedChildren: false,
    hasChildren: false,
  },
]

let defaultProjects = [
  {
    id: "1",
    name: "Project Omega",
    isActive: true,
    todos: defaultTodos,
  },
]

// let filterMap = (m, f) => m ->
// Map.entries -> Array.fromIterator -> Array.filter(f) -> Map.fromArray

// let mapToArray = m => m ->
// Map.entries -> Array.fromIterator

@module("./assets/tiger.svg") external logoUrl: string = "default"

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

  let parentAggs = parentMap->Map.map(children => children->Array.some(v => v.box == Archive))

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
            hasArchivedChildren: parentAggs->Map.getWithDefault(todo.id, false),
            hasChildren: parentMap->Map.getWithDefault(todo.id, [])->Array.length > 0,
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
    ~projects: array<project>,
    ~setChecked,
    ~setProjects: (array<Types.project> => array<Types.project>) => unit,
  ) => {
    let (statusSelectIsOpen, setStatusSelectIsOpen) = React.useState(() => false)
    let allTodos = Array.concatMany([], projects->Array.map(p => p.todos))
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
              let checkedTodos = allTodos->Array.filter(t => checked->Array.includes(t.id))
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
              setProjects(projects => {
                projects->Array.map(project => {
                  ...project,
                  todos: project.todos->Array.map(
                    t => {
                      if checked->Array.includes(t.id) {
                        {
                          ...t,
                          status: newStatus,
                          box: t.box == Archive && !(newStatus->statusIsResolved) ? Working : t.box,
                        }
                      } else {
                        t
                      }
                    },
                  ),
                })
              })}
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

module SSet = Belt.Set.String
module SMap = Belt.Map.String

@react.component
let make = () => {
  let (projects, setProjects, _) = Common.useLocalStorage("projects", defaultProjects)
  // let (todos, setTodos, getTodos) = Common.useLocalStorage("todos", defaultTodos)
  let (showArchive, setShowArchive, _) = Common.useLocalStorage("showArchive", [])
  let (checked, setChecked, _) = Common.useLocalStorage("checked", [])
  let (projectsTab, _setProjectTab, _) = Common.useLocalStorage("projectsTab", All)
  let (selectedElement, setSelectedElement) = React.useState(_ => None)
  let (displayElement, setDisplayElement) = React.useState(_ => None)
  let (focusClassNext, setFocusClassNext) = React.useState(_ => None)
  let (focusIdNext, setFocusIdNext) = React.useState(_ => None)
  let (itemsToMove, setItemsToMove) = React.useState(_ => SSet.empty)
  // let (setAaParent, aaEnable) = Common.useAutoAnimate()

  let aaParentRef: React.ref<RescriptCore.Nullable.t<Dom.element>> = React.useRef(Nullable.null)

  let clickDelayTimeout = React.useRef(None)
  let lastRelative = React.useRef(None)

  // React.useEffect1(() => {
  //   switch aaParentRef.current {
  //   | Null | Undefined => ()
  //   | Value(v) => setAaParent(v)
  //   }

  //   None
  // }, [aaParentRef])

  let itemToMoveHandleMouseDown = (itemId, _) => {
    let timeoutId = setTimeout(() => {
      // startXStep(e)
      setItemsToMove(s => s->SSet.add(itemId))
      // aaEnable(true)
    }, 200)
    clickDelayTimeout.current = timeoutId->Some
  }

  let itemToMoveHandleMouseEnter = (isProject, itemId, _) => {
    let isInMoveGroup = itemsToMove->SSet.has(itemId)
    if isInMoveGroup {
      lastRelative.current = None
    } else if lastRelative.current->Option.mapOr(true, lastRelativeId => itemId != lastRelativeId) {
      lastRelative.current = Some(itemId)

      setProjects(projects => {
        let todosToMove = projects->Array.reduce([], (pa, pc) => {
          pc.todos->Array.reduce(
            pa,
            (ta, tc) => {
              itemsToMove->SSet.has(tc.id) ? ta->Array.concat([tc]) : ta
            },
          )
        })

        let itemIndex =
          aaParentRef.current
          ->Nullable.toOption
          ->Option.mapOr(0, containerEl => {
            containerEl
            ->Obj.magic
            ->HtmlElement.children
            ->HtmlCollection.toArray
            ->Array.findIndex(
              el => {
                el
                ->Obj.magic
                ->HtmlElement.id
                ->getIdFromId
                ->Option.mapOr(false, id => id == itemId)
              },
            )
          })

        let moveIndex =
          aaParentRef.current
          ->Nullable.toOption
          ->Option.mapOr(0, containerEl => {
            containerEl
            ->Obj.magic
            ->HtmlElement.children
            ->HtmlCollection.toArray
            ->Array.findIndex(
              el => {
                el
                ->Obj.magic
                ->HtmlElement.id
                ->getIdFromId
                ->Option.mapOr(
                  false,
                  id => {
                    itemsToMove->SSet.has(id)
                  },
                )
              },
            )
          })

        let fromBelow = itemIndex < moveIndex

        let filterOutTodosToMove = p => {
          ...p,
          todos: p.todos->Array.filter(t => !(itemsToMove->SSet.has(t.id))),
        }
        if isProject && itemIndex == 0 {
          projects
        } else if isProject {
          if fromBelow {
            let projectIndex = projects->Array.findIndex(p => p.id == itemId)
            projects->Array.mapWithIndex((p, i) => {
              p
              ->filterOutTodosToMove
              ->{
                p => {
                  i == projectIndex - 1
                    ? {
                        ...p,
                        todos: Array.concat(p.todos, todosToMove)->Array.map(
                          t => {...t, project: p.id},
                        ),
                      }
                    : p
                }
              }
            })
          } else {
            projects->Array.map(p =>
              p
              ->filterOutTodosToMove
              ->{
                p =>
                  p.id == itemId
                    ? {
                        ...p,
                        todos: Array.concat(todosToMove, p.todos)->Array.map(
                          t => {...t, project: p.id},
                        ),
                      }
                    : p
              }
            )
          }
        } else {
          projects->Array.map(p =>
            p
            ->filterOutTodosToMove
            ->{
              p => {
                ...p,
                todos: p.todos
                ->Array.map(
                  t => {
                    if t.id == itemId {
                      fromBelow ? Array.concat(todosToMove, [t]) : Array.concat([t], todosToMove)
                    } else {
                      [t]
                    }
                  },
                )
                ->Belt.Array.concatMany
                ->Array.map(t => {...t, project: p.id}),
              }
            }
          )
        }
      })
    } else {
      ()
    }
  }

  let handleMouseUp = React.useCallback0(_ => {
    clickDelayTimeout.current->Option.mapOr((), a => clearTimeout(a))
    setItemsToMove(_ => SSet.empty)

    // aaEnable(false)
    lastRelative.current = None

    // setItemMap(m => {...m, saved: m.working})
    // setItemOrder(o => {...o, saved: o.working})

    // endXStep()
  })

  React.useEffect0(() => {
    // aaEnable(false)
    None
  })

  React.useEffect0(() => {
    Webapi.Dom.document->Document.addMouseUpEventListener(handleMouseUp)
    Some(() => Webapi.Dom.document->Document.removeMouseUpEventListener(handleMouseUp))
  })

  let updateProject = React.useCallback0((id, f) => {
    setProjects(v => v->Array.map(project => project.id == id ? f(project) : project))
  })

  let updateTodo = React.useCallback0((projectId, todoId, f) => {
    updateProject(projectId, project => {
      ...project,
      todos: project.todos->Array.map(todo => todo.id == todoId ? f(todo) : todo),
    })
  })

  let setTodos = React.useCallback0((projectId, f) => {
    updateProject(projectId, project => {
      ...project,
      todos: f(project.todos),
    })
  })

  let deleteTodo = (projectId, todo: todo) =>
    setTodos(projectId, todos =>
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

  React.useEffectOnEveryRender(() => {
    focusClassNext
    ->Option.flatMap(x =>
      Webapi.Dom.document
      ->Document.getElementsByClassName(x)
      ->HtmlCollection.toArray
      ->Array.get(0)
    )
    ->Option.mapOr((), element => {
      element->Obj.magic->HtmlElement.focus
      setFocusClassNext(_ => None)
    })

    focusIdNext
    ->Option.flatMap(x => Webapi.Dom.document->Document.getElementById(x))
    ->Option.mapOr((), element => {
      element->Obj.magic->HtmlElement.focus
      setFocusIdNext(_ => None)
    })

    None
  })

  <div className="flex flex-row h-dvh text-[var(--t9)]">
    // <StatusSelector />
    <div className="flex-1 overflow-y-scroll">
      <div className="flex flex-row gap-2 justify-between items-center w-full h-10 border-b px-2">
        <img src={logoUrl} width={"24"} className="py-0.5 " />
        // <div className="flex flex-row gap-2 ">
        //   <div className="text-sm"> {"Show Inactive"->React.string} </div>
        //   <Switch
        //     checked={projectsTab == All}
        //     onCheckedChange={() => setProjectTab(v => v == All ? Active : All)}
        //   />
        // </div>
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
                    todos: [],
                  },
                ],
                v,
              )
            )
            setSelectedElement(_ => Some(Project(newProjectId)))
            setDisplayElement(_ => Some(Project(newProjectId)))
            setFocusIdNext(_ => Some(getProjectInputId(newProjectId)))
          }}
          className={[
            "bg-[var(--t2)] px-2 rounded text-xs flex flex-row items-center gap-1 h-5 ",
          ]->Array.join(" ")}>
          <Icons.Plus />
          {"Project"->React.string}
        </button>
      </div>
      <ul className="pb-20" ref={ReactDOM.Ref.domRef(aaParentRef)}>
        {projects
        ->Array.filter(project => projectsTab == Active ? project.isActive : true)
        ->Array.map(project => {
          let showArchive = showArchive->Array.includes(project.id)
          let projectTodos =
            project.todos
            ->Array.filter(todo => showArchive ? true : todo.box != Archive)
            ->buildTodoTree

          let newTodoAfter = (after, parentTodo) => {
            let newId = Common.uuid()

            let newTodo = {
              id: newId,
              text: "",
              project: project.id,
              status: Unsorted,
              box: Working,
              parentTodo,
              depth: None,
              childNumber: None,
              hasArchivedChildren: false,
              hasChildren: false,
            }

            setTodos(project.id, todos => {
              if after == None {
                [newTodo]->Array.concat(todos)
              } else {
                todos->Array.reduce(
                  [],
                  (a, c) => {
                    Some(c.id) == after
                      ? a->Array.concat([c])->Array.concat([newTodo])
                      : a->Array.concat([c])
                  },
                )
              }
            })

            setFocusIdNext(_ => Some(getTodoInputId(newId)))
          }

          <React.Fragment>
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
              itemToMoveHandleMouseDown
              itemToMoveHandleMouseEnter
            />
            {project.todos
            // ->Array.toSorted((a, b) => a.status->statusToFloat -. b.status->statusToFloat)
            ->Array.map(todo =>
              <Project.Todo
                key={getTodoId(todo.id)}
                project
                todo
                updateTodo
                showArchive
                isSelected={selectedElement == Some(Todo(todo.id))}
                isDisplayElement={displayElement == Some(Todo(todo.id))}
                setSelectedElement
                displayElement
                setDisplayElement
                setTodos
                setFocusIdNext
                newTodoAfter
                getTodos={() => projectTodos}
                setChecked
                deleteTodo
                isChecked={checked->Array.includes(todo.id)}
                itemToMoveHandleMouseDown
                itemToMoveHandleMouseEnter
              />
            )
            ->React.array}
          </React.Fragment>
        })
        ->React.array}
      </ul>
    </div>
    <div className=" border-l flex-1">
      <CheckedSummary checked={checked} projects={projects} setChecked={setChecked} setProjects />
      {switch displayElement {
      | Some(Todo(todoId)) =>
        projects
        ->Array.reduce(None, (a, c) => {
          a->Option.isSome ? a : c.todos->Array.find(t => t.id == todoId)->Option.map(v => (c, v))
        })
        ->Option.mapOr(React.null, ((project, todo)) => {
          <DisplayTodo todo project setFocusIdNext updateTodo setTodos deleteTodo />
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

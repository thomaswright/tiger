open Types
open Webapi.Dom

let p1DefaultTodos = [
  {
    text: "Call Amber",
    additionalText: "",
    project: "p1",
    id: "1",
    status: Future,
    // box: Working,
    parentTodo: None,
    depth: None,
    childNumber: None,
    hasArchivedChildren: false,
    hasChildren: false,
    ancArchived: false,
    targetDate: None,
  },
  {
    text: "Confirm cyan flux",
    additionalText: "",
    project: "p1",
    id: "2",
    status: NowIfTime,
    // box: Archive,
    parentTodo: None,
    depth: None,
    childNumber: None,
    hasArchivedChildren: false,
    hasChildren: false,
    ancArchived: false,
    targetDate: None,
  },
  {
    text: "Initiate azul bending",
    additionalText: "",
    project: "p1",
    id: "3",
    status: ResolveDone,
    // box: Archive,
    parentTodo: None,
    depth: None,
    childNumber: None,
    hasArchivedChildren: false,
    hasChildren: false,
    ancArchived: false,
    targetDate: None,
  },
]

let p2DefaultTodos = [
  {
    text: "Chroma degradation",
    additionalText: "",
    project: "p2",
    id: "4",
    status: Unsorted,
    // box: Archive,
    parentTodo: None,
    depth: None,
    childNumber: None,
    hasArchivedChildren: false,
    hasChildren: false,
    ancArchived: false,
    targetDate: None,
  },
]

let defaultProjects = [
  {
    id: "p1",
    name: "Project Indigo",
    additionalText: "",
    isActive: true,
    todos: p1DefaultTodos,
    hiddenTodos: SMap.empty,
    hideArchived: false,
    hideAll: false,
  },
  {
    id: "p2",
    name: "Project Grayscale",
    additionalText: "",
    isActive: true,
    todos: p2DefaultTodos,
    hiddenTodos: SMap.empty,
    hideArchived: false,
    hideAll: false,
  },
]

// let filterMap = (m, f) => m ->
// Map.entries -> Array.fromIterator -> Array.filter(f) -> Map.fromArray

// let mapToArray = m => m ->
// Map.entries -> Array.fromIterator

// module Switch = {
//   @module("./Switch.jsx") @react.component
//   external make: (~checked: bool, ~onCheckedChange: unit => unit) => React.element = "Switch"
// }

// module Map = Belt.Map.String

let buildTodoTree = (input: array<todo>) => {
  let rootMapId = "_"
  let parentMap = input->Array.reduce(SMap.empty, (a, c) => {
    let mapId = c.parentTodo->Option.getOr(rootMapId)
    a->SMap.update(mapId, v => v->Option.mapOr([c], v => Array.concat(v, [c]))->Some)
  })

  let mutParentMap = ref(parentMap)

  let parentAggs =
    parentMap->SMap.map(children =>
      children->Array.some(v => v.status == ArchiveNo || v.status == ArchiveDone)
    )

  let rec build = (arr, mapId, ancArchived, depth) => {
    let children = mutParentMap.contents->SMap.get(mapId)
    // this is to prevent accidental inf loops
    mutParentMap := mutParentMap.contents->SMap.remove(mapId)
    children
    ->Option.getOr([])
    ->Array.reduceWithIndex(arr, (a, todo, i) => {
      build(
        a->Array.concat([
          {
            ...todo,
            depth: Some(depth),
            childNumber: Some(i),
            hasArchivedChildren: parentAggs->SMap.getWithDefault(todo.id, false),
            hasChildren: parentMap->SMap.getWithDefault(todo.id, [])->Array.length > 0,
            ancArchived,
          },
        ]),
        todo.id,
        ancArchived || todo.status == ArchiveNo || todo.status == ArchiveDone,
        depth + 1,
      )
    })
  }

  build([], rootMapId, false, 0)
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
    <div
      className="flex-1 h-full text-sm border-r border-[var(--t3)] flex flex-row gap-2 items-center">
      {if checked->SSet.size < 2 {
        React.null
      } else {
        <React.Fragment>
          <Common.StatusSelect
            isOpen={statusSelectIsOpen}
            onOpenChange={v => {
              setStatusSelectIsOpen(_ => v)
            }}
            status={
              let checkedTodos = allTodos->Array.filter(t => checked->SSet.has(t.id))
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
                      if checked->SSet.has(t.id) {
                        {
                          ...t,
                          status: newStatus,
                        }
                      } else {
                        t
                      }
                    },
                  ),
                })
              })}
          />
          {`${checked->SSet.size->Int.toString} Checked`->React.string}
          <div className="flex-1" />
          <button className="px-2 mr-2" onClick={_ => setChecked(_ => SSet.empty)}>
            {"Clear"->React.string}
          </button>
        </React.Fragment>
      }}
    </div>
  }
}

let _adjustProject = (projects, f, id) =>
  projects->Array.map(p => {
    if p.id == id {
      f(p)
    } else {
      p
    }
  })

@react.component
let make = () => {
  let (projects, setProjectsPreCompute, getProjects) = Common.useLocalStorage(
    StorageKeys.projects,
    defaultProjects->Array.map(p => {
      ...p,
      todos: p.todos->buildTodoTree,
    }),
  )
  let setProjects = f =>
    setProjectsPreCompute(projects => {
      projects
      ->f
      ->Array.map(p => {
        ...p,
        todos: p.todos->buildTodoTree,
      })
    })

  let (checked, setChecked) = React.useState(() => SSet.empty)
  let (projectsTab, _setProjectTab, _) = Common.useLocalStorage(StorageKeys.projectsTab, All)
  let (selectedElement, setSelectedElement) = React.useState(_ => None)
  let (displayElement, setDisplayElement) = React.useState(_ => None)
  let (viewSettings, setViewSettings) = React.useState(_ => true)
  let (focusClassNext, setFocusClassNext) = React.useState(_ => None)

  let (focusIdNext, setFocusIdNext) = React.useState(_ => None)

  let aaParentRef: React.ref<RescriptCore.Nullable.t<Dom.element>> = React.useRef(Nullable.null)

  let todosClickDelayTimeout = React.useRef(None)
  let (todosOfDragHandle, setTodosOfDragHandle) = React.useState(_ => SSet.empty)
  let todosLastRelative = React.useRef(None)

  let projectClickDelayTimeout = React.useRef(None)
  let (projectOfDragHandle, setProjectOfDragHandle) = React.useState(_ => None)
  let projectLastRelative = React.useRef(None)

  let (baseColor, setBaseColor, _) = Common.useLocalStorage(
    StorageKeys.baseColor,
    "var(--blueBase)",
  )

  React.useEffect1(() => {
    Common.setRootStyleProperty("--tBase", baseColor)

    None
  }, [baseColor])

  let onExportJson = () => {
    projects
    ->Array.map(p =>
      {
        "id": p.id,
        "name": p.name,
        "isActive": p.isActive,
        "todos": p.todos->Array.map(t => {
          {
            "id": t.id,
            "text": t.text,
            "project": t.project,
            "status": t.status,
            "parentTodo": t.parentTodo,
          }
        }),
        "hiddenTodos": p.hiddenTodos->SMap.toArray,
      }
    )
    ->Js.Json.stringifyAny
    ->Option.mapOr((), Common.exportToJsonFile)
  }

  let onImportJson = json => {
    setProjects(_ =>
      json->Array.map(jsonProject => {
        id: jsonProject["id"],
        name: jsonProject["name"],
        additionalText: jsonProject["additionalText"],
        isActive: jsonProject["isActive"],
        todos: jsonProject["todos"]->Array.map(
          t => {
            id: t["id"],
            text: t["text"],
            additionalText: t["additionalText"],
            project: t["project"],
            status: t["status"],
            parentTodo: t["parentTodo"],
            depth: None,
            childNumber: None,
            hasArchivedChildren: false,
            hasChildren: false,
            ancArchived: false,
            targetDate: None,
          },
        ),
        hiddenTodos: jsonProject["hiddenTodos"]->SMap.fromArray,
        hideAll: jsonProject["todos"]->Array.length == 0,
        hideArchived: jsonProject["hiddenTodos"]->Array.length > 0,
      })
    )
  }

  // React.useEffect1(() => {
  //   switch aaParentRef.current {
  //   | Null | Undefined => ()
  //   | Value(v) => setAaParent(v)
  //   }

  //   None
  // }, [aaParentRef])

  let projectToMoveHandleMouseDown = (projectId, _) => {
    let timeoutId = setTimeout(() => {
      // startXStep(e)

      setProjectOfDragHandle(_ => Some(projectId))
    }, 200)
    projectClickDelayTimeout.current = timeoutId->Some
  }

  let itemToMoveHandleMouseDown = (itemId, _) => {
    let timeoutId = setTimeout(() => {
      // startXStep(e)

      setTodosOfDragHandle(s => {
        // s->SSet.add(itemId)
        projects->Array.reduce(
          s->SSet.add(itemId),
          (a, c) => {
            c.todos->Array.reduce(
              a,
              (a2, c2) => {
                c2.parentTodo->Option.mapOr(false, x => a2->SSet.has(x)) ? a2->SSet.add(c2.id) : a2
              },
            )
          },
        )
      })
      // aaEnable(true)
    }, 200)
    todosClickDelayTimeout.current = timeoutId->Some
  }

  let projectToMoveHandleMouseEnter = (itemId, _) => {
    switch projectOfDragHandle {
    | None => ()
    | Some(projectId) =>
      if itemId == projectId {
        projectLastRelative.current = None
      } else if (
        projectLastRelative.current->Option.mapOr(true, projectLastRelativeId =>
          itemId != projectLastRelativeId
        )
      ) {
        projectLastRelative.current = Some(itemId)
        setProjects(projects => {
          let itemIndex = projects->Array.findIndex(p => p.id == itemId)
          let moveIndex = projects->Array.findIndex(p => p.id == projectId)
          let fromBelow = itemIndex < moveIndex

          let projectToMove = projects->Array.find(p => p.id == projectId)
          let projectsWithout = projects->Array.filter(p => p.id != projectId)

          projectsWithout->Array.reduce([], (a, c) => {
            if c.id == itemId {
              if fromBelow {
                a
                ->Array.concat(projectToMove->Option.mapOr([], v => [v]))
                ->Array.concat([c])
              } else {
                a
                ->Array.concat([c])
                ->Array.concat(projectToMove->Option.mapOr([], v => [v]))
              }
            } else {
              a->Array.concat([c])
            }
          })
        })
      } else {
        ()
      }
    }
  }

  let itemToMoveHandleMouseEnter = (isProject, itemId, _) => {
    let itemsToMove = SSet.union(checked, todosOfDragHandle)

    if todosOfDragHandle->SSet.isEmpty {
      ()
    } else {
      let isInMoveGroup = itemsToMove->SSet.has(itemId)
      if isInMoveGroup {
        todosLastRelative.current = None
      } else if (
        todosLastRelative.current->Option.mapOr(true, todosLastRelativeId =>
          itemId != todosLastRelativeId
        )
      ) {
        todosLastRelative.current = Some(itemId)

        setProjects(projects => {
          let todosToMove = projects->Array.reduce([], (pa, pc) => {
            pc.todos->Array.reduce(
              pa,
              (ta, tc) => {
                itemsToMove->SSet.has(tc.id) ? ta->Array.concat([tc]) : ta
              },
            )
          })

          let applyNewParent = (todos: array<todo>, newParent) => {
            todos->Array.map(t => {
              ...t,
              parentTodo: if itemsToMove->SSet.has(t.id) {
                if (
                  t.parentTodo->Option.mapOr(
                    false,
                    currentParentTodo => itemsToMove->SSet.has(currentParentTodo),
                  )
                ) {
                  t.parentTodo
                } else {
                  newParent
                }
              } else {
                t.parentTodo
              },
            })
          }

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
                          todos: {
                            let lastTodo = p.todos->Array.getUnsafe(p.todos->Array.length - 1)

                            Array.concat(p.todos, todosToMove)
                            ->Array.map(t => {...t, project: p.id})
                            ->applyNewParent(lastTodo.parentTodo)
                          },
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
                          todos: Array.concat(todosToMove, p.todos)
                          ->Array.map(t => {...t, project: p.id})
                          ->applyNewParent(None),
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
                  ->Array.mapWithIndex(
                    (t, _) => {
                      if t.id == itemId {
                        if fromBelow {
                          // let newParent =
                          //   p.todos->Array.get(i - 1)->Option.flatMap(t2 => t2.parentTodo)

                          Array.concat(todosToMove, [t])->applyNewParent(t.parentTodo)
                        } else if t.hasChildren {
                          Array.concat([t], todosToMove)->applyNewParent(Some(t.id))
                        } else {
                          Array.concat([t], todosToMove)->applyNewParent(t.parentTodo)
                        }
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
  }

  let handleMouseUp = React.useCallback0(_ => {
    todosClickDelayTimeout.current->Option.mapOr((), a => clearTimeout(a))
    setTodosOfDragHandle(_ => SSet.empty)
    todosLastRelative.current = None

    projectClickDelayTimeout.current->Option.mapOr((), a => clearTimeout(a))
    setProjectOfDragHandle(_ => None)
    projectLastRelative.current = None

    // aaEnable(false)

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

  let handleHide = (hideAllMode, forcedShow, p) => {
    let archivedPred = t => t.status == ArchiveDone || t.status == ArchiveNo
    let allPred = _ => true

    let pred = hideAllMode ? allPred : archivedPred

    if forcedShow->Option.getOr(hideAllMode ? p.hideAll : p.hideArchived) {
      let parentMap = p.todos->Array.reduce(SMap.empty, (a, c) => {
        let mapId = c.parentTodo->Option.getOr("None")
        a->SMap.update(mapId, v => v->Option.mapOr([c], v => Array.concat(v, [c]))->Some)
      })

      let rec recurse = (todos: array<todo>) => {
        todos->Array.reduce([], (a, t) => {
          let regularTodos =
            parentMap
            ->SMap.get(t.id)
            ->Option.mapOr([], v => {
              recurse(v)
            })

          let hiddenTodos =
            p.hiddenTodos
            ->SMap.get(t.id)
            ->Option.mapOr([], v => {
              recurse(v)
            })
          a
          ->Array.concat([t])
          ->Array.concat(regularTodos)
          ->Array.concat(hiddenTodos)
        })
      }

      {
        ...p,
        todos: p.todos
        ->Array.filter(t => t.parentTodo->Option.isNone)
        ->recurse
        ->Array.concat(p.hiddenTodos->SMap.get("None")->Option.mapOr([], todos => todos->recurse)),
        hiddenTodos: SMap.empty,
        hideArchived: hideAllMode ? p.hideArchived : false,
        hideAll: hideAllMode ? false : p.hideAll,
      }
    } else {
      let mutHiddenTodos = ref(p.hiddenTodos)

      let newTodos = p.todos->Array.reduce([], (a, c) => {
        if pred(c) {
          mutHiddenTodos :=
            mutHiddenTodos.contents->SMap.update(c.parentTodo->Option.getOr("None"), v => {
              switch v {
              | None => Some([c])
              | Some(x) => Some(Array.concat(x, [c]))
              }
            })
          a
        } else if c.ancArchived {
          mutHiddenTodos :=
            c.parentTodo->Option.mapOr(mutHiddenTodos.contents, parentTodo => {
              mutHiddenTodos.contents->SMap.update(
                parentTodo,
                v => {
                  switch v {
                  | None => Some([c])
                  | Some(x) => Some(Array.concat(x, [c]))
                  }
                },
              )
            })

          a
        } else {
          a->Array.concat([c])
        }
      })
      {
        ...p,
        todos: newTodos,
        hiddenTodos: mutHiddenTodos.contents,
        hideArchived: hideAllMode ? p.hideArchived : true,
        hideAll: hideAllMode ? true : p.hideAll,
      }
    }
  }

  let newTodoAfter = projectId => (after, parentTodo) => {
    let newId = Common.uuid()

    let newTodo = {
      id: newId,
      text: "",
      additionalText: "",
      project: projectId,
      status: Unsorted,
      // box: Working,
      parentTodo,
      depth: None,
      childNumber: None,
      hasArchivedChildren: false,
      hasChildren: false,
      ancArchived: false,
      targetDate: None,
    }

    setTodos(projectId, todos => {
      if after == None {
        [newTodo]->Array.concat(todos)
      } else {
        todos->Array.reduce([], (a, c) => {
          Some(c.id) == after ? a->Array.concat([c])->Array.concat([newTodo]) : a->Array.concat([c])
        })
      }
    })

    setFocusIdNext(_ => Some(getTodoInputId(newId)))
  }

  let allProjectsHidden = projects->Array.every(p => p.hideAll)
  <div className="flex flex-col-reverse sm:flex-row max-h-dvh h-dvh text-[var(--t10)] ">
    // <StatusSelector />
    <div className="flex-1 flex flex-col h-1/2 sm:h-full border-t sm:border-t-0">
      <div
        className="flex-none flex flex-row gap-2 justify-between items-center w-full h-10 border-b border-[var(--t3)] px-2">
        // <img src={logoUrl} width={"24"} className="py-0.5 " />
        // <div className="flex flex-row gap-2 ">
        //   <div className="text-sm"> {"Show Inactive"->React.string} </div>
        //   <Switch
        //     checked={projectsTab == All}
        //     onCheckedChange={() => setProjectTab(v => v == All ? Active : All)}
        //   />
        // </div>
        <CheckedSummary checked={checked} projects={projects} setChecked={setChecked} setProjects />
        <div className="flex flex-row items-center justify-center gap-2">
          <button
            onClick={_ => {
              let newProjectId = Common.uuid()
              let newProject = {
                id: newProjectId,
                name: "",
                additionalText: "",
                isActive: true,
                todos: [],
                hiddenTodos: SMap.empty,
                hideArchived: false,
                hideAll: false,
              }
              setProjects(v => {
                let relativeProject = switch displayElement {
                | Some(Project(projectId)) => Some(projectId)
                | Some(Todo(todoId)) =>
                  v->Array.reduce(None, (a, c) => {
                    a->Option.isSome
                      ? a
                      : c.todos->Array.find(t => t.id == todoId)->Option.isSome
                      ? Some(c.id)
                      : None
                  })
                | _ => None
                }

                relativeProject->Option.mapOr(Array.concat([newProject], v), relativeProject =>
                  v->Array.reduce(
                    [],
                    (a, c) => {
                      c.id == relativeProject
                        ? a->Array.concat([c])->Array.concat([newProject])
                        : a->Array.concat([c])
                    },
                  )
                )
              })
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
          <button
            onClick={_ =>
              setProjects(projects =>
                projects->Array.map(p => handleHide(true, Some(allProjectsHidden), p))
              )}
            className={[
              "rounded flex flex-row items-center justify-center gap-1 h-5 w-5 text-[var(--t6)] ",
            ]->Array.join(" ")}>
            {allProjectsHidden ? <Icons.ChevronDown /> : <Icons.ChevronUp />}
          </button>
        </div>
      </div>
      <ul className="pb-20 flex-1 overflow-y-scroll" ref={ReactDOM.Ref.domRef(aaParentRef)}>
        {projects
        ->Array.filter(project => projectsTab == Active ? project.isActive : true)
        ->Array.map(project => {
          let newTodoAfter = newTodoAfter(project.id)
          <React.Fragment>
            <Project
              key={getProjectId(project.id)}
              project
              updateProject
              selectedElement
              setSelectedElement
              setDisplayElement
              newTodoAfter
              itemToMoveHandleMouseEnter
              projectToMoveHandleMouseDown
              projectToMoveHandleMouseEnter
              handleHide
            />
            {project.todos
            ->Array.map(todo =>
              <Todo
                key={getTodoId(todo.id)}
                project
                todo
                updateTodo
                hasHiddenTodos={project.hideArchived &&
                project.hiddenTodos
                ->SMap.get(todo.id)
                ->Option.mapOr(false, hiddenTodos => hiddenTodos->Array.length > 0)}
                isSelected={selectedElement == Some(Todo(todo.id))}
                isDisplayElement={displayElement == Some(Todo(todo.id))}
                setSelectedElement
                setDisplayElement
                setTodos
                setFocusIdNext
                newTodoAfter
                getTodos={() =>
                  getProjects()
                  ->Array.find(p => p.id == project.id)
                  ->Option.mapOr([], p => p.todos)}
                setChecked
                deleteTodo
                isChecked={checked->SSet.has(todo.id)}
                itemToMoveHandleMouseDown
                itemToMoveHandleMouseEnter
                clearProjectLastRelative={() => {
                  projectLastRelative.current = None
                }}
              />
            )
            ->React.array}
          </React.Fragment>
        })
        ->React.array}
      </ul>
    </div>
    <div className=" border-l border-[var(--t3)] flex-1 flex flex-col h-1/2 sm:h-full">
      <div
        className="flex-none flex flex-row gap-2 justify-between items-center w-full h-10 border-b border-[var(--t3)] px-2">
        <div className="flex-1" />
        <button
          onClick={_ => {
            setViewSettings(_ => true)
            setDisplayElement(_ => None)
            setSelectedElement(_ => None)
          }}>
          <img src={Common.logoUrl} width={"24"} className="py-0.5 " />
        </button>
      </div>
      {if displayElement->Option.isSome || selectedElement->Option.isSome {
        <React.Fragment>
          {switch displayElement {
          | Some(Todo(todoId)) =>
            projects
            ->Array.reduce(None, (a, c) => {
              a->Option.isSome
                ? a
                : c.todos->Array.find(t => t.id == todoId)->Option.map(v => (c, v))
            })
            ->Option.mapOr(React.null, ((project, todo)) => {
              <DisplayTodo todo project setFocusIdNext updateTodo deleteTodo />
            })
          | Some(Project(projectId)) =>
            projects
            ->Array.find(p => p.id == projectId)
            ->Option.mapOr(React.null, project => {
              <DisplayProject project updateProject setProjects setTodos handleHide />
            })
          | _ => React.null
          }}
        </React.Fragment>
      } else if viewSettings {
        <Settings onExportJson onImportJson setBaseColor />
      } else {
        React.null
      }}
    </div>
  </div>
}

open! Webapi.Dom
open Common
open Types

type position = {
  top: float,
  right: float,
  bottom: float,
  left: float,
}

let elementPosition = element => {
  let a = element->Element.getBoundingClientRect

  {
    top: a->DomRect.top,
    right: a->DomRect.right,
    bottom: a->DomRect.bottom,
    left: a->DomRect.left,
  }
}

let dragItem = ref(None)
let dropItem = ref(None)

@react.component
let make = (
  ~todos: array<todoRelation>,
  ~allTodos as _: array<todoRelation>,
  ~root: todoRelation,
  ~logout: unit => unit,
) => {
  let (theme, setTheme) = Theme.useTheme()

  let (selectedElement, setSelectedElement, _) = useSessionStorage(
    StorageKeys.selectedElement,
    None,
  )
  let (displayElement, setDisplayElement, _) = useSessionStorage(StorageKeys.displayElement, None)
  let (view, setView, _) = useSessionStorage(StorageKeys.view, None) //  React.useState(() => None)
  let (showCheckboxes, _setShowCheckboxes, _) = useSessionStorage(StorageKeys.showCheckboxes, false)

  let (checked, setChecked) = React.useState(() => SSet.empty)
  // let (dragItem, setDragItem) = React.useState(() => None)
  let (moveActive, setMoveActive) = React.useState(() => false)

  let (focusClassNext, setFocusClassNext) = React.useState(_ => None)
  let (focusIdNext, setFocusIdNext) = React.useState(_ => None)

  let aaParentRef: React.ref<RescriptCore.Nullable.t<Dom.element>> = React.useRef(Nullable.null)

  // let (baseColor, setBaseColor, _) = Common.useLocalStorage(
  //   StorageKeys.baseColor,
  //   "var(--blueBase)",
  // )

  let onMouseMove = event => {
    switch dragItem.contents {
    | None => ()
    | Some(_) => {
        let _mouseLeft = event->MouseEvent.clientX->Int.toFloat
        let mouseTop = event->MouseEvent.clientY->Int.toFloat
        let closest = ref(None)

        document
        ->Document.getElementsByClassName("drag-marker")
        ->HtmlCollection.toArray
        ->Array.forEach(v => {
          switch closest.contents {
          | None => closest.contents = Some(v)
          | Some(best) => {
              let bestPos = best->elementPosition
              let bestDist = Math.abs(bestPos.top -. mouseTop)
              // let bestDist = Math.hypot(bestPos.top -. mouseTop, bestPos.left -. mouseLeft)

              let pos = v->elementPosition
              let dist = Math.abs(pos.top -. mouseTop)

              // let dist = Math.hypot(pos.top -. mouseTop, pos.left -. mouseLeft)
              if dist < bestDist {
                closest.contents = Some(v)
              }
            }
          }
          v->Common.addClass("opacity-0")
        })

        switch closest.contents {
        | None => ()
        | Some(best) => {
            dropItem.contents = Some(best)
            best->removeClass("opacity-0")
          }
        }
      }
    }
  }

  let moveItem = dragItem => {
    switch dropItem.contents {
    | Some(dropItemElement) =>
      getIdFromId(dropItemElement->Element.id)->Option.mapOr((), dropItemId => {
        todos
        ->Array.find(todo => todo.self.id == dropItemId)
        ->Option.mapOr((), dropItem => {
          // Console.log2(dropItem, dragItem)
          if (
            dropItem.self.id != dragItem.self.id &&
              !(dropItem.parents->Array.includes(dragItem.self.id))
          ) {
            // Console.log("move")
            dropItem.parent
            ->Nullable.toOption
            ->Option.mapOr(
              (),
              parent => {
                batch(
                  () => {
                    // set new parent
                    setTodoParent(dragItem.self.id, parent.id)
                    // remove from old parent order
                    dragItem.parent
                    ->Nullable.toOption
                    ->Option.mapOr(
                      (),
                      formerDragParent =>
                        setTodoOrder(
                          formerDragParent.id,
                          order => order->Array.filter(v => v != dragItem.self.id),
                        ),
                    )
                    let bottomMarker = dropItemElement->hasClass("drag-marker-bottom")
                    // add to new parent order
                    setTodoOrder(
                      parent.id,
                      order =>
                        order->Array.reduce(
                          [],
                          (a, c) =>
                            Array.concat(
                              a,
                              c == dropItem.self.id
                                ? bottomMarker ? [c, dragItem.self.id] : [dragItem.self.id, c]
                                : [c],
                            ),
                        ),
                    )
                    setTodoMode(dragItem.self.id, dropItem.self.mode)
                  },
                )
              },
            )
          }
        })
      })
    | _ => ()
    }
  }

  let onMouseUp = _ => {
    dragItem.contents->Option.mapOr((), d => {
      let itemToMove = d
      dragItem.contents = None
      document
      ->Document.getElementsByClassName("drag-marker")
      ->HtmlCollection.toArray
      ->Array.forEach(v => {
        v->addClass("opacity-0")
      })
      document
      ->Document.getElementsByClassName("drag-mask")
      ->HtmlCollection.toArray
      ->Array.forEach(v => {
        // v->addClass("opacity-0")
        v->removeClass("opacity-20")
        v->addClass("opacity-0")
      })
      moveItem(itemToMove)
    })
  }

  React.useEffect0(() => {
    window->Window.addMouseMoveEventListener(onMouseMove)
    window->Window.addMouseUpEventListener(onMouseUp)
    window->Window.addKeyDownEventListener(event => {
      if event->KeyboardEvent.key == "Alt" {
        setMoveActive(_ => true)
      }
    })
    window->Window.addKeyUpEventListener(event => {
      if event->KeyboardEvent.key == "Alt" {
        setMoveActive(_ => false)
      }
    })
    None
  })

  // React.useEffect1(() => {
  //   Common.setRootStyleProperty("--tBase", baseColor)

  //   None
  // }, [baseColor])

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

  switch view {
  | Some(Settings) =>
    <Settings
      logout={() => {
        setView(_ => None)
        logout()
      }}
      backToTodos={() => setView(_ => None)}
    />
  | _ =>
    <div className="flex flex-col justify-center text-[var(--t10)] h-dvh">
      <div
        className="flex-1 flex flex-col overflow-hidden sm:h-full border-t sm:border-t-0 md:border-r max-w-4xl border-[var(--t3)]">
        <div
          className="flex-none flex flex-row gap-2 justify-between items-center w-full h-10 border-b border-[var(--t3)] px-2">
          // <CheckedSummary checked={checked} projects={projects} setChecked={setChecked} setProjects />

          <button
            onClick={_ => {
              setView(_ => Some(Settings))
            }}>
            <img src={Common.logoUrl} width={"24"} className="py-0.5 " />
          </button>
          <div className="border-l border-[var(--t3)] mx-1 h-full bg-green-400" />
          <button
            className="text-[var(--t6)] "
            onClick={_ => setTheme(_ => theme == Dark ? Light : Dark)}>
            {theme == Dark ? <Icons.Sun className="w-4 h-4" /> : <Icons.Moon className="w-4 h-4" />}
          </button>
          // <button
          //   className="px-2 bg-[var(--t2)] rounded text-sm h-5"
          //   onClick={_ => {
          //     setShowCheckboxes(v => !v)
          //     if showCheckboxes {
          //       setChecked(_ => SSet.empty)
          //     }
          //   }}>
          //   {"Show Checkboxes"->React.string}
          // </button>
          <div className="flex-1" />
          <button
            className="px-2 bg-[var(--t2)] rounded text-sm h-5"
            onClick={_ => {
              let newId = addTodo("", root.self.id, (order, id) => Array.concat([id], order))
              setFocusIdNext(_ => Some(getTodoInputId(newId)))
            }}>
            <Icons.Plus />
          </button>
          <Todo.TopCollapseControls todos={todos} todo={root.self} todoRelation={root} />
        </div>
        <ul className="pb-5 flex-1 overflow-y-scroll" ref={ReactDOM.Ref.domRef(aaParentRef)}>
          {todos
          ->Array.map(todoRelation => {
            <Todo
              key={todoRelation.self.id}
              getTodos={_ => todos}
              moveActive
              todoRelation={todoRelation}
              isSelected={selectedElement == Some(todoRelation.self.id)}
              setSelectedElement
              isDisplayElement={displayElement == Some(todoRelation.self.id)}
              setDisplayElement
              showCheckboxes
              setFocusIdNext
              isChecked={checked->SSet.has(todoRelation.self.id)}
              setChecked
              // itemToMoveHandleMouseDown={(_, todoId) => dragItem.contents = Some(todoId)}
              // itemToMoveHandleMouseEnter={(_, _, _) => ()}
              setDrag={_ => {
                dragItem.contents = Some(todoRelation)
                document
                ->Document.getElementById(getDragId(todoRelation.self.id))
                ->Option.mapOr((), element => {
                  element->removeClass("opacity-0")
                  element->addClass("opacity-20")
                })

                // setDragItem(_ => Some(todoRelation))
              }}
            />
          })
          ->React.array}
        </ul>
        <div
          className="flex-none flex flex-row gap-2 justify-between items-center w-full h-20 border-t border-[var(--t3)]">
          {switch displayElement {
          | Some(todoId) =>
            todos
            ->Array.find(t => t.self.id == todoId)
            ->Option.mapOr(React.null, todoRelation => {
              <AdditionText todoRelation />
            })
          | _ => React.null
          }}
        </div>
      </div>
    </div>
  }
}

let make = observer(make)

let default = make

// let onImportJson = json => {
//   let maxPosition = allTodos->Array.reduce(0., (a, c) => Math.max(a, c.self.position))
//   batch(() => {
//     let idMap = json->Array.map(v => (v["id"], uuid()))

//     json->Array.forEachWithIndex((v, i) => {
//       addTodoByImport(
//         idMap
//         ->Array.find(((oldId, _)) => oldId == v["id"])
//         ->Option.mapOr(uuid(), ((_, newId)) => newId),
//         v["text"],
//         switch (v["parent_todo"]: Nullable.t<string>) {
//         | Undefined => Null
//         | Null => Null
//         | Value(x) =>
//           idMap
//           ->Array.find(((oldId, _)) => oldId == x)
//           ->Option.mapOr(Nullable.Null, ((_, newId)) => Value(newId))
//         },
//         maxPosition +. i->Int.toFloat,
//         v["status"],
//       )
//     })
//   })
// }

// <div
//       className=" border-l border-[var(--t3)] flex-none h-60 sticky sm:static sm:flex-1 bg-white top-0 flex flex-col overflow-hidden sm:h-full">
//       <div
//         className="flex-none flex flex-row gap-2 justify-between items-center w-full h-10 border-b border-[var(--t3)] px-2">
//         <button
//           className="px-2 bg-[var(--t2)] rounded text-sm h-5"
//           onClick={_ => {
//             setView(_ => Some(ProjectList))
//             setDisplayElement(_ => None)
//             setSelectedElement(_ => None)
//           }}>
//           {"Top Level"->React.string}
//         </button>
//         <div className="flex-1" />
//         <button
//           onClick={_ => {
//             setView(_ => Some(Settings))
//             setDisplayElement(_ => None)
//             setSelectedElement(_ => None)
//           }}>
//           <img src={Common.logoUrl} width={"24"} className="py-0.5 " />
//         </button>
//       </div>
//       {if displayElement->Option.isSome || selectedElement->Option.isSome {
//         <React.Fragment>
//           {switch displayElement {
//           | Some(todoId) =>
//             allTodos
//             ->Array.find(t => t.self.id == todoId)
//             ->Option.mapOr(React.null, todoRelation => {
//               <DisplayTodo todoRelation setFocusIdNext />
//             })
//           | _ => React.null
//           }}
//         </React.Fragment>
//       } else {
//         switch view {
//         | Some(Settings) => <Settings setBaseColor logout />
//         | Some(ProjectList) =>
//           <div className="overflow-y-scroll">
//             <ModeMgr todo={None} />
//           </div>

//         | None => React.null
//         }
//       }}
//     </div>

// ------------

// <button
//   onClick={_ => {
//     let newProjectId = Common.uuid()
//     let newProject = {
//       id: newProjectId,
//       name: "",
//       additionalText: "",
//       isActive: true,
//       todos: [],
//       hiddenTodos: SMap.empty,
//       hideArchived: false,
//       hideAll: false,
//     }
//     setProjects(v => {
//       let relativeProject = switch displayElement {
//       | Some(Project(projectId)) => Some(projectId)
//       | Some(Todo(todoId)) =>
//         v->Array.reduce(None, (a, c) => {
//           a->Option.isSome
//             ? a
//             : c.todos->Array.find(t => t.id == todoId)->Option.isSome
//             ? Some(c.id)
//             : None
//         })
//       | _ => None
//       }
//       relativeProject->Option.mapOr(Array.concat([newProject], v), relativeProject =>
//         v->Array.reduce(
//           [],
//           (a, c) => {
//             c.id == relativeProject
//               ? a->Array.concat([c])->Array.concat([newProject])
//               : a->Array.concat([c])
//           },
//         )
//       )
//     })
//     setSelectedElement(_ => Some(Project(newProjectId)))
//     setDisplayElement(_ => Some(Project(newProjectId)))
//     setFocusIdNext(_ => Some(getProjectInputId(newProjectId)))
//   }}
//   className={[
//     "bg-[var(--t2)] px-2 rounded text-xs flex flex-row items-center gap-1 h-5 ",
//   ]->Array.join(" ")}>
//   <Icons.Plus />
//   {"Project"->React.string}
// </button>
// <button
//   onClick={_ =>
//     setProjects(projects =>
//       projects->Array.map(p => handleHide(true, Some(allProjectsHidden), p))
//     )}
//   className={[
//     "rounded flex flex-row items-center justify-center gap-1 h-5 w-5 text-[var(--t6)] ",
//   ]->Array.join(" ")}>
//   {allProjectsHidden ? <Icons.ChevronDown /> : <Icons.ChevronUp />}
// </button>

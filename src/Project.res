open Types
open Webapi.Dom
open Common

module Todo = {
  @react.component
  let make = (
    ~project: project,
    ~todo: todo,
    ~updateTodo,
    ~isSelected,
    ~setSelectedElement,
    ~displayElement as _,
    ~isDisplayElement,
    ~setDisplayElement,
    ~setTodos: (string, array<Types.todo> => array<Types.todo>) => unit,
    ~setFocusIdNext,
    ~newTodoAfter: (option<string>, option<string>) => unit,
    ~getTodos: unit => array<todo>,
    ~isChecked: bool,
    ~setChecked,
    ~deleteTodo,
    ~hideArchived,
    ~itemToMoveHandleMouseDown,
    ~itemToMoveHandleMouseEnter,
  ) => {
    let (statusSelectIsOpen, setStatusSelectIsOpen) = React.useState(() => false)
    let inputRef = React.useRef(Nullable.null)
    let containerRef = React.useRef(Nullable.null)

    let (stagedForDelete, setStagedForDelete) = React.useState(_ => false)
    let focusContainer = () => {
      containerRef.current->mapNullable(dom => {
        dom->Obj.magic->HtmlElement.focus
      })
    }
    // let clickDelayTimeout = React.useRef(None)
    // let onCheckboxMouseDown = e => {
    //   let timeoutId = setTimeout(() => {
    //     focusContainer()
    //     itemToMoveHandleMouseDown(todo.id, e)
    //   }, 500)
    //   clickDelayTimeout.current = timeoutId->Some
    // }

    // let onCheckboxMouseUp = _ => {
    //   clickDelayTimeout.current->Option.mapOr((), timeoutId => clearTimeout(timeoutId))
    // }

    let indentation = e => {
      if e->ReactEvent.Keyboard.key == "Tab" {
        e->ReactEvent.Keyboard.preventDefault
      }

      // Indents
      if (
        ((e->ReactEvent.Keyboard.key == "Tab" && !(e->ReactEvent.Keyboard.shiftKey)) ||
          (e->ReactEvent.Keyboard.key == "]" && e->ReactEvent.Keyboard.metaKey)) &&
          todo.childNumber->Option.mapOr(false, childNumber => childNumber != 0)
      ) {
        e->ReactEvent.Keyboard.preventDefault

        let todos = getTodos()
        let newParent =
          todos->Array.find(t =>
            t.parentTodo == todo.parentTodo &&
              t.childNumber == todo.childNumber->Option.map(c => c - 1)
          )
        setTodos(project.id, todos =>
          todos->Array.map(t => {
            if t.id == todo.id {
              {
                ...t,
                parentTodo: newParent->Option.map(t => t.id),
              }
            } else if t.parentTodo == Some(todo.id) {
              {
                ...t,
                parentTodo: newParent->Option.map(t => t.id),
              }
            } else {
              t
            }
          })
        )
      }

      // De Indents
      if (
        ((e->ReactEvent.Keyboard.key == "Tab" && e->ReactEvent.Keyboard.shiftKey) ||
          (e->ReactEvent.Keyboard.key == "[" && e->ReactEvent.Keyboard.metaKey)) &&
          todo.parentTodo != None
      ) {
        e->ReactEvent.Keyboard.preventDefault

        let todos = getTodos()
        let todoIndex = todos->Array.findIndex(t => t.id == todo.id)
        let todosGoingBack = todos->Array.slice(~start=0, ~end=todoIndex)->Array.toReversed
        let todosGoingForward = todos->Array.sliceToEnd(~start=todoIndex + 1)

        todo.depth->Option.mapOr((), todoDepth => {
          let newChildren = ref([])
          let break = ref(false)
          let i = ref(0)
          while !break.contents && i.contents < todosGoingForward->Array.length {
            let t = todosGoingForward->Array.getUnsafe(i.contents)
            if t.depth->Option.mapOr(false, d => d < todoDepth) {
              break := true
            } else {
              if t.depth->Option.mapOr(false, d => d == todoDepth) {
                newChildren := newChildren.contents->Array.concat([t.id])
              }
              i := i.contents + 1
            }
          }

          let newParent =
            todosGoingBack
            ->Array.find(t => t.depth == Some(todoDepth - 2))
            ->Option.map(t => t.id)

          setTodos(project.id, todos => {
            todos->Array.map(
              t => {
                if t.id == todo.id {
                  {
                    ...t,
                    parentTodo: newParent,
                  }
                } else if newChildren.contents->Array.includes(t.id) {
                  {
                    ...t,
                    parentTodo: Some(todo.id),
                  }
                } else {
                  t
                }
              },
            )
          })
        })
      }
    }

    let onKeyDownContainer = e => {
      open ReactEvent.Keyboard
      if (
        isSelected &&
        containerRef.current->Nullable.toOption == Webapi.Dom.document->Document.activeElement
      ) {
        containerRef.current->mapNullable(dom => {
          indentation(e)
          if e->key == "s" {
            e->preventDefault
            setStatusSelectIsOpen(_ => true)
          }

          if e->key == "ArrowUp" {
            e->preventDefault
            Common.focusPreviousClass(listItemClass, dom)
          }

          if e->key == "ArrowDown" {
            e->preventDefault
            Common.focusNextClass(listItemClass, dom)
          }

          if e->key == "Backspace" && e->metaKey {
            deleteTodo(project.id, todo)

            containerRef.current->mapNullable(containerEl => {
              Common.focusPreviousClass(listItemClass, containerEl)
            })
          }

          if e->key == "Backspace" && !(e->metaKey) {
            if stagedForDelete {
              deleteTodo(project.id, todo)

              containerRef.current->mapNullable(containerEl => {
                Common.focusPreviousClass(listItemClass, containerEl)
              })
            } else {
              setStagedForDelete(_ => true)
            }
          }

          if e->key == "Enter" && e->metaKey {
            newTodoAfter(Some(todo.id), todo.hasChildren ? Some(todo.id) : todo.parentTodo)
          }

          if e->key == "Enter" {
            e->preventDefault
            inputRef.current->mapNullable(inputEl => {
              let inputEl = inputEl->Obj.magic
              inputEl->HtmlElement.focus
              inputEl->HtmlInputElement.setSelectionStart(inputEl->HtmlInputElement.selectionEnd)
            })
          }

          if e->key == "Escape" {
            if stagedForDelete {
              setStagedForDelete(_ => false)
            } else {
              // e->preventDefault // ?
              setSelectedElement(_ => None)
              setDisplayElement(_ => None)

              dom->Obj.magic->HtmlElement.blur
            }
          }
        })
      }
    }

    let onKeyDownInput = e => {
      open ReactEvent.Keyboard

      setStagedForDelete(_ => false)

      if isSelected {
        if e->key == "Escape" {
          // e->preventDefault // ?
          e->stopPropagation

          focusContainer()
        }

        inputRef.current->mapNullable(dom => {
          indentation(e)

          let cursorPosition = dom->Obj.magic->HtmlInputElement.selectionStart->Option.getOr(0)
          let inputValueLength = dom->Obj.magic->HtmlInputElement.value->String.length

          if e->key == "ArrowUp" {
            e->stopPropagation
            if cursorPosition == 0 {
              e->preventDefault
              // Common.focusPreviousClass(todoInputClass, dom)
              focusContainer()
            }
          }

          if e->key == "ArrowDown" {
            e->stopPropagation
            if cursorPosition == inputValueLength {
              e->preventDefault
              // Common.focusNextClass(todoInputClass, dom)
              focusContainer()
            }
          }

          if e->key == "Backspace" && inputValueLength == 0 {
            if stagedForDelete {
              deleteTodo(project.id, todo)

              containerRef.current->mapNullable(containerEl => {
                Common.focusPreviousClass(listItemClass, containerEl)
              })
            } else {
              setStagedForDelete(_ => true)
            }
          }

          if e->key == "Enter" && cursorPosition == inputValueLength {
            e->preventDefault
            e->stopPropagation
            newTodoAfter(Some(todo.id), todo.hasChildren ? Some(todo.id) : todo.parentTodo)
          }
        })
      }
    }

    <li
      id={getTodoId(todo.id)}
      tabIndex={0}
      ref={ReactDOM.Ref.domRef(containerRef)}
      onBlur={_ => {
        setSelectedElement(_ => None)
        setStagedForDelete(_ => false)
      }}
      onFocus={_ => {
        setSelectedElement(_ => Some(Todo(todo.id)))
        setDisplayElement(_ => Some(Todo(todo.id)))
      }}
      onKeyDown={onKeyDownContainer}
      onMouseEnter={e => itemToMoveHandleMouseEnter(false, todo.id, e)}
      className={[
        listItemClass,
        "group flex flex-row justify-start items-center outline-none  pl-1",
      ]->Array.join(" ")}>
      {Array.make(~length=todo.depth->Option.getOr(0), false)
      ->Array.mapWithIndex((_, i) => {
        <div key={i->Int.toString} className="self-stretch w-2 border-l ml-2 border-[var(--t3)] " />
      })
      ->React.array}
      <div
        className={[
          "group flex flex-row justify-start items-center h-full flex-1 pl-1 rounded-sm",
          stagedForDelete ? "outline-red-700" : "focus-within:outline-purple-500 outline-blue-500",
          stagedForDelete ? "bg-red-200 " : isChecked ? "bg-sky-50" : "",
          isSelected ? "outline outline-2 -outline-offset-2 " : "",
          isDisplayElement && !isSelected ? "bg-sky-200" : "",
        ]->Array.join(" ")}>
        <Common.StatusSelect
          isOpen={statusSelectIsOpen}
          onOpenChange={v => {
            if !v {
              setStatusSelectIsOpen(_ => v)
            } else {
              setStatusSelectIsOpen(_ => v)
            }
          }}
          status={Some(todo.status)}
          focusTodo={() => {
            // this isn't set directly because the "Enter"
            // will then fire on the container then focusing
            // the input *shrugs*
            setFocusIdNext(_ => Some(getTodoId(todo.id)))
          }}
          setStatus={newStatus =>
            updateTodo(project.id, todo.id, t => {
              ...t,
              status: newStatus,
              // box: t.box == Archive && !(newStatus->statusIsResolved) ? Working : t.box,
            })}
        />
        <div
          className={[
            "relative flex-1 ml-1 flex flex-row h-full justify-start items-center ",
          ]->Array.join(" ")}>
          {if (
            hideArchived &&
            project.hiddenTodos
            ->SMap.get(todo.id)
            ->Option.mapOr(false, hiddenTodos => hiddenTodos->Array.length > 0)
          ) {
            <div
              className="absolute bg-white text-[var(--darkPurple)] bg-[var(--lightPurple)] text-xs h-3 w-3 -left-3 -top-0 flex flex-row items-center justify-center rounded-full">
              <Icons.Archive />
            </div>
          } else {
            React.null
          }}
          {isSelected || isDisplayElement
            ? React.null
            : <div className="h-px w-full absolute bg-[var(--t2)] -bottom-0" />}
          <Common.TextareaAutosize
            id={getTodoInputId(todo.id)}
            ref={ReactDOM.Ref.domRef(inputRef)}
            className={[
              todoInputClass,
              "mx-1 my-1 block text-sm font-medium  w-full h-5 border-0 px-0 py-0 focus:ring-0 focus:z-10
                 text-[var(--t8)]",
              isChecked ? "bg-sky-50" : isDisplayElement && !isSelected ? "bg-sky-200" : "bg-white",
            ]->Array.join(" ")}
            placeholder={""}
            style={{resize: "none"}}
            value={todo.text}
            onBlur={_ => setSelectedElement(_ => None)}
            onFocus={_ => {
              setSelectedElement(_ => Some(Todo(todo.id)))
              setDisplayElement(_ => Some(Todo(todo.id)))
            }}
            onKeyDown={onKeyDownInput}
            // onMouseDown={onInputMouseDown}
            // onMouseUp={onInputMouseUp}
            onChange={e => {
              updateTodo(project.id, todo.id, t => {
                ...t,
                text: ReactEvent.Form.target(e)["value"],
              })
            }}
          />
          <div
            className={[
              "cursor-default absolute right-0 flex-row items-center gap-1.5 pr-1.5  h-full
              
              ",
              isChecked ? "flex" : " hidden group-hover:flex",
            ]->Array.join(" ")}>
            <div
              onMouseDown={e => itemToMoveHandleMouseDown(todo.id, e)}
              className={" w-4 h-4 text-gray-500 hidden group-hover:block bg-white rounded-sm 0 "}>
              <Icons.DragDrop />
            </div>
            <button
              className={[
                "w-4 h-4 flex-row items-center justify-center cursor-default hidden group-hover:flex rounded-sm text-sm text-gray-500 border-gray-500 bg-white ",
              ]->Array.join(" ")}
              onClick={_ => {
                newTodoAfter(Some(todo.id), Some(todo.id))
              }}>
              <Icons.Plus />
            </button>
            <input
              onChange={_ => {
                setChecked(v =>
                  v->SSet.has(todo.id) ? v->SSet.remove(todo.id) : v->SSet.add(todo.id)
                )
              }}
              checked={isChecked}
              type_={"checkbox"}
              className={[
                "border-gray-300 bg-white rounded text-blue-400 w-4 h-4 focus:ring-offset-0 focus:ring-blue-500",
              ]->Array.join(" ")}
            />
          </div>
        </div>
      </div>
    </li>
  }
}

@react.component
let make = (
  ~project: project,
  ~todos: array<todo>,
  // ~showArchive,
  // ~setShowArchive,
  ~updateProject,
  ~updateTodo,
  ~selectedElement,
  ~setSelectedElement,
  ~displayElement,
  ~setDisplayElement,
  ~setFocusIdNext,
  ~setTodos: (string, array<Types.todo> => array<Types.todo>) => unit,
  ~getTodos,
  ~checked,
  ~setChecked,
  ~deleteTodo,
  ~itemToMoveHandleMouseDown,
  ~itemToMoveHandleMouseEnter,
) => {
  let projectRef = React.useRef(Nullable.null)
  let inputRef = React.useRef(Nullable.null)

  let isSelected = selectedElement == Some(Project(project.id))

  let newTodoAfter = (after, parentTodo) => {
    let newId = Common.uuid()

    let newTodo = {
      id: newId,
      text: "",
      project: project.id,
      status: Unsorted,
      // box: Working,
      parentTodo,
      depth: None,
      childNumber: None,
      hasArchivedChildren: false,
      hasChildren: false,
      ancArchived: false,
    }

    setTodos(project.id, todos => {
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

  let onKeyDownProject = e => {
    if isSelected {
      projectRef.current->mapNullable(dom => {
        if e->ReactEvent.Keyboard.key == "ArrowUp" {
          e->ReactEvent.Keyboard.preventDefault
          Common.focusPreviousClass(listItemClass, dom)
        }

        if e->ReactEvent.Keyboard.key == "ArrowDown" {
          e->ReactEvent.Keyboard.preventDefault
          Common.focusNextClass(listItemClass, dom)
        }

        if e->ReactEvent.Keyboard.key == "Backspace" && e->ReactEvent.Keyboard.metaKey {
          projectRef.current->mapNullable(containerEl => {
            Common.focusPreviousClass(listItemClass, containerEl)
          })
        }

        if e->ReactEvent.Keyboard.key == "Enter" && e->ReactEvent.Keyboard.metaKey {
          newTodoAfter(None, None)
        }

        if e->ReactEvent.Keyboard.key == "Enter" {
          e->ReactEvent.Keyboard.preventDefault
          inputRef.current->mapNullable(inputEl => {
            let inputEl = inputEl->Obj.magic
            inputEl->HtmlElement.focus
            inputEl->HtmlInputElement.setSelectionStart(inputEl->HtmlInputElement.selectionEnd)
          })
        }

        if e->ReactEvent.Keyboard.key == "Escape" {
          // e->ReactEvent.Keyboard.preventDefault // ?
          setSelectedElement(_ => None)
          setDisplayElement(_ => None)

          dom->Obj.magic->HtmlElement.blur
        }
      })
    }
  }

  let onKeyDownInput = e => {
    if isSelected {
      if e->ReactEvent.Keyboard.key == "Escape" {
        // e->ReactEvent.Keyboard.preventDefault // ?
        e->ReactEvent.Keyboard.stopPropagation
        projectRef.current->mapNullable(dom => {
          dom->Obj.magic->HtmlElement.focus
        })
      }

      inputRef.current->mapNullable(dom => {
        let cursorPosition = dom->Obj.magic->HtmlInputElement.selectionStart->Option.getOr(0)
        let inputValueLength = dom->Obj.magic->HtmlInputElement.value->String.length

        if e->ReactEvent.Keyboard.key == "ArrowUp" {
          e->ReactEvent.Keyboard.stopPropagation
          if cursorPosition == 0 {
            e->ReactEvent.Keyboard.preventDefault
            // Common.focusPreviousClass(todoInputClass, dom)
            projectRef.current->mapNullable(dom => {
              dom->Obj.magic->HtmlElement.focus
            })
          }
        }

        if e->ReactEvent.Keyboard.key == "ArrowDown" {
          e->ReactEvent.Keyboard.stopPropagation
          if cursorPosition == inputValueLength {
            e->ReactEvent.Keyboard.preventDefault
            // Common.focusNextClass(todoInputClass, dom)
            projectRef.current->mapNullable(dom => {
              dom->Obj.magic->HtmlElement.focus
            })
          }
        }

        if e->ReactEvent.Keyboard.key == "Enter" && cursorPosition == inputValueLength {
          e->ReactEvent.Keyboard.stopPropagation
          e->ReactEvent.Keyboard.preventDefault
          newTodoAfter(None, None)

          // projectRef.current->mapNullable(dom => {
          //   dom->Obj.magic->HtmlElement.focus
          // })
        }
      })
    }
  }

  let handleHide = hideAllMode => {
    let archivedPred = t => t.status == ArchiveDone || t.status == ArchiveNo
    let allPred = _ => true

    let pred = hideAllMode ? allPred : archivedPred

    _ =>
      updateProject(project.id, p => {
        if hideAllMode ? p.hideAll : p.hideArchived {
          let parentMap = p.todos->Array.reduce(SMap.empty, (a, c) => {
            let mapId = c.parentTodo->Option.getOr("None")
            a->SMap.update(mapId, v => v->Option.mapOr([c], v => Array.concat(v, [c]))->Some)
          })

          let rec recurse = (todos: array<todo>) => {
            todos->Array.reduce([], (a, t) => {
              let regularTodos =
                parentMap
                ->SMap.get(t.id)
                ->Option.mapOr(
                  [],
                  v => {
                    recurse(v)
                  },
                )

              let hiddenTodos =
                p.hiddenTodos
                ->SMap.get(t.id)
                ->Option.mapOr(
                  [],
                  v => {
                    recurse(v)
                  },
                )
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
            ->Array.concat(
              p.hiddenTodos->SMap.get("None")->Option.mapOr([], todos => todos->recurse),
            ),
            hiddenTodos: SMap.empty,
            hideArchived: hideAllMode ? p.hideArchived : false,
            hideAll: hideAllMode ? false : p.hideAll,
          }
        } else {
          let mutHiddenTodos = ref(SMap.empty)

          let newTodos = p.todos->Array.reduce([], (a, c) => {
            if pred(c) {
              mutHiddenTodos :=
                mutHiddenTodos.contents->SMap.update(
                  c.parentTodo->Option.getOr("None"),
                  v => {
                    switch v {
                    | None => Some([c])
                    | Some(x) => Some(Array.concat(x, [c]))
                    }
                  },
                )
              a
            } else if c.ancArchived {
              mutHiddenTodos :=
                c.parentTodo->Option.mapOr(
                  mutHiddenTodos.contents,
                  parentTodo => {
                    mutHiddenTodos.contents->SMap.update(
                      parentTodo,
                      v => {
                        switch v {
                        | None => Some([c])
                        | Some(x) => Some(Array.concat(x, [c]))
                        }
                      },
                    )
                  },
                )

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
      })
  }

  let handleHideAll = handleHide(true)
  let handleHideArchived = handleHide(false)

  <React.Fragment>
    <li
      key={getProjectId(project.id)}
      id={getProjectId(project.id)}
      tabIndex={0}
      ref={ReactDOM.Ref.domRef(projectRef)}
      onKeyDown={onKeyDownProject}
      onBlur={_ => setSelectedElement(_ => None)}
      onFocus={_ => {
        setSelectedElement(_ => Some(Project(project.id)))
        setDisplayElement(_ => Some(Project(project.id)))
      }}
      onMouseEnter={e => itemToMoveHandleMouseEnter(true, project.id, e)}
      className={[
        listItemClass,
        // "first:mt-1 mt-1",
        "relative group  flex flex-row justify-between items-center bg-[var(--t0)] px-1 text-[var(--t9)]
        gap-1 border-b border-b-[var(--t2)] border-t-[var(--t0)]",
        isSelected
          ? "outline outline-2 -outline-offset-2 outline-purple-500 focus:outline-blue-500"
          : "",
      ]->Array.join(" ")}>
      <Common.TextareaAutosize
        id={getProjectInputId(project.id)}
        style={{resize: "none"}}
        ref={ReactDOM.Ref.domRef(inputRef)}
        className={[
          todoInputClass,
          "ml-1 my-1 block text-lg font-black tracking-tight  w-full border-0 px-0 py-0 focus:ring-0 
               leading-none bg-transparent",
        ]->Array.join(" ")}
        placeholder={""}
        value={project.name}
        onBlur={_ => setSelectedElement(_ => None)}
        onFocus={_ => {
          setSelectedElement(_ => Some(Todo(project.id)))
          setDisplayElement(_ => Some(Todo(project.id)))
        }}
        onKeyDown={onKeyDownInput}
        onChange={e => {
          updateProject(project.id, t => {
            ...t,
            name: ReactEvent.Form.target(e)["value"],
          })
        }}
      />
      {project.hideAll
        ? React.null
        : <button
            onClick={_ => {
              newTodoAfter(None, None)
            }}
            className="absolute right-16 hidden group-hover:block bg-[var(--t1)] p-0.5 text-xs rounded  flex-none ">
            <Icons.Plus />
          </button>}
      {project.hideAll
        ? React.null
        : <button
            className="text-2xs rounded h-5 w-5 flex-none font-mono flex flex-row justify-center items-center text-[var(--t6)] mr-1"
            onClick={handleHideArchived}>
            {project.hideArchived ? <Icons.ArchiveOff /> : <Icons.Archive />}
            // {showArchive
            //   ? <span className="line-through"> {"closed"->React.string} </span>
            //   : <span> {"closed"->React.string} </span>}
          </button>}
      <button
        className="text-2xs rounded h-5 w-5 flex-none font-mono flex flex-row justify-center items-center text-[var(--t6)] mr-1"
        onClick={handleHideAll}>
        {project.hideAll ? <Icons.ChevronDown /> : <Icons.ChevronUp />}
      </button>
    </li>
    {todos
    // ->Array.toSorted((a, b) => a.status->statusToFloat -. b.status->statusToFloat)
    ->Array.map(todo =>
      <Todo
        key={getTodoId(todo.id)}
        project
        todo
        updateTodo
        hideArchived={project.hideArchived}
        isSelected={selectedElement == Some(Todo(todo.id))}
        isDisplayElement={displayElement == Some(Todo(todo.id))}
        setSelectedElement
        displayElement
        setDisplayElement
        setTodos
        setFocusIdNext
        newTodoAfter
        getTodos={getTodos}
        setChecked
        deleteTodo
        isChecked={checked->SSet.has(todo.id)}
        itemToMoveHandleMouseDown
        itemToMoveHandleMouseEnter
      />
    )
    ->React.array}
  </React.Fragment>
}

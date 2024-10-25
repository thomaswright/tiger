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
    ~showArchive as _,
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
        (e->ReactEvent.Keyboard.key == "Tab" ||
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

          setTodos(project.id, todos =>
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
          )
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
            setTodos(project.id, todos => todos->Array.filter(t => t.id != todo.id))
            containerRef.current->mapNullable(containerEl => {
              Common.focusPreviousClass(listItemClass, containerEl)
            })
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
            // e->preventDefault // ?
            setSelectedElement(_ => None)
            setDisplayElement(_ => None)

            dom->Obj.magic->HtmlElement.blur
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
          isPinned={todo.box == Pinned}
          isArchived={todo.box == Archive}
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
              box: t.box == Archive && !(newStatus->statusIsResolved) ? Working : t.box,
            })}
        />
        <div
          className={[
            "relative flex-1 ml-1 flex flex-row h-full justify-start items-center ",
          ]->Array.join(" ")}>
          // {if todo.hasArchivedChildren && showArchive {
          //   <div
          //     className="absolute bg-purple-800 text-xs h-1.5 w-1.5 -left-2 top-0 flex flex-row items-center justify-center rounded-full">
          //     // <Icons.EyeClosed />
          //   </div>
          // } else {
          //   React.null
          // }}
          {isSelected || isDisplayElement
            ? React.null
            : <div className="h-px w-full absolute bg-[var(--t2)] -bottom-0" />}
          <Common.TextareaAutosize
            id={getTodoInputId(todo.id)}
            ref={ReactDOM.Ref.domRef(inputRef)}
            className={[
              todoInputClass,
              "mx-1 my-1 block text-sm font-medium  w-full h-5 border-0 px-0 py-0 focus:ring-0 
                bg-transparent text-[var(--t8)]",
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
            onMouseDown={e => itemToMoveHandleMouseDown(todo.id, e)}
            className={"absolute w-4 h-4 text-gray-500 mr-1 hidden group-hover:block right-12  "}>
            <Icons.DragDrop />
          </div>
          <button
            className={[
              "absolute hidden group-hover:block right-7 bg-[var(--t1)] rounded p-0.5  text-xs  ",
            ]->Array.join(" ")}
            onClick={_ => {
              newTodoAfter(Some(todo.id), Some(todo.id))
            }}>
            <Icons.Plus />
          </button>
          <input
            onChange={_ => {
              setChecked(v => v->Common.arrayToggle(todo.id))
            }}
            checked={isChecked}
            type_={"checkbox"}
            className={[
              "absolute right-1 border-[var(--t3)]
             rounded mx-1 text-blue-400 h-3.5 w-3.5 focus:ring-offset-0 focus:ring-blue-500",
              isChecked ? "" : " hidden group-hover:block",
            ]->Array.join(" ")}
          />
        </div>
      </div>
    </li>
  }
}

@react.component
let make = (
  ~project: project,
  ~todos: array<todo>,
  ~showArchive,
  ~setShowArchive,
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
      "group  flex flex-row justify-between items-center bg-[var(--t0)] px-1 text-[var(--t9)]
        gap-1 border-b-[var(--t6)] border-t-[var(--t0)]",
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
    <div className="flex-1" />
    <button
      onClick={_ => {
        newTodoAfter(None, None)
      }}
      className="hidden group-hover:block bg-[var(--t1)] p-0.5 text-xs rounded  flex-none mr-2">
      <Icons.Plus />
    </button>
    <button
      className="text-2xs rounded h-6 w-6 flex-none font-mono strike"
      onClick={_ => setShowArchive(v => v->arrayToggle(project.id))}>
      {showArchive ? <Icons.Eye /> : <Icons.EyeClosed />}
      // {showArchive
      //   ? <span className="line-through"> {"closed"->React.string} </span>
      //   : <span> {"closed"->React.string} </span>}
    </button>
  </li>
}

open Types
open Webapi.Dom
module StatusSelect = {
  @react.component @module("./StatusSelect.jsx")
  external make: (~status: status, ~setStatus: status => unit) => React.element = "default"
}

let listItemClass = "class-list-item"
let todoInputClass = "class-list-todo-input"

module Todo = {
  @react.component
  let make = (
    ~todo: todo,
    ~updateTodo,
    ~isSelected,
    ~setSelectElement,
    ~displayElement,
    ~setDisplayElement,
    ~setTodos: (array<Types.todo> => array<Types.todo>) => unit,
    ~setFocusIdNext,
  ) => {
    let inputRef = React.useRef(Nullable.null)
    let containerRef = React.useRef(Nullable.null)
    let (stagedForDelete, setStagedForDelete) = React.useState(_ => false)

    let onKeyDownContainer = e => {
      if isSelected {
        containerRef.current
        ->Nullable.toOption
        ->Option.mapOr((), dom => {
          if e->ReactEvent.Keyboard.key == "ArrowUp" {
            e->ReactEvent.Keyboard.preventDefault
            Common.focusPreviousClass(listItemClass, dom)
          }

          if e->ReactEvent.Keyboard.key == "ArrowDown" {
            e->ReactEvent.Keyboard.preventDefault
            Common.focusNextClass(listItemClass, dom)
          }

          if e->ReactEvent.Keyboard.key == "Backspace" && e->ReactEvent.Keyboard.metaKey {
            setTodos(todos => todos->Array.filter(t => t.id != todo.id))
            containerRef.current
            ->Nullable.toOption
            ->Option.mapOr((), containerEl => {
              Common.focusPreviousClass(listItemClass, containerEl)
            })
          }

          if e->ReactEvent.Keyboard.key == "Enter" && e->ReactEvent.Keyboard.metaKey {
            let newId = Common.uuid()
            setTodos(v =>
              v
              ->Array.findIndexOpt(t => t.id == todo.id)
              ->Option.mapOr(
                v,
                i => {
                  v->Array.toSpliced(
                    ~start=i + 1,
                    ~remove=0,
                    ~insert=[
                      {
                        id: newId,
                        text: "",
                        project: todo.project,
                        isDone: false,
                        status: LaterUnsorted,
                      },
                    ],
                  )
                },
              )
            )

            setFocusIdNext(_ => Some(getTodoInputId(newId)))

            e->ReactEvent.Keyboard.preventDefault
            inputRef.current
            ->Nullable.toOption
            ->Option.mapOr((), inputEl => {
              let inputEl = inputEl->Obj.magic
              inputEl->HtmlElement.focus
              inputEl->HtmlInputElement.setSelectionStart(inputEl->HtmlInputElement.selectionEnd)
            })
          }

          if e->ReactEvent.Keyboard.key == "Enter" {
            e->ReactEvent.Keyboard.preventDefault
            inputRef.current
            ->Nullable.toOption
            ->Option.mapOr((), inputEl => {
              let inputEl = inputEl->Obj.magic
              inputEl->HtmlElement.focus
              inputEl->HtmlInputElement.setSelectionStart(inputEl->HtmlInputElement.selectionEnd)
            })
          }

          if e->ReactEvent.Keyboard.key == "Escape" {
            // e->ReactEvent.Keyboard.preventDefault // ?
            setSelectElement(_ => None)
            setDisplayElement(_ => None)

            dom->Obj.magic->HtmlElement.blur
          }
        })
      }
    }

    let onKeyDownInput = e => {
      setStagedForDelete(_ => false)

      if isSelected {
        if e->ReactEvent.Keyboard.key == "Escape" {
          // e->ReactEvent.Keyboard.preventDefault // ?
          e->ReactEvent.Keyboard.stopPropagation
          containerRef.current
          ->Nullable.toOption
          ->Option.mapOr((), dom => {
            dom->Obj.magic->HtmlElement.focus
          })
        }

        inputRef.current
        ->Nullable.toOption
        ->Option.mapOr((), dom => {
          let cursorPosition = dom->Obj.magic->HtmlInputElement.selectionStart->Option.getOr(0)
          let inputValueLength = dom->Obj.magic->HtmlInputElement.value->String.length

          if e->ReactEvent.Keyboard.key == "ArrowUp" {
            e->ReactEvent.Keyboard.stopPropagation
            if cursorPosition == 0 {
              e->ReactEvent.Keyboard.preventDefault
              // Common.focusPreviousClass(todoInputClass, dom)
              containerRef.current
              ->Nullable.toOption
              ->Option.mapOr((), dom => {
                dom->Obj.magic->HtmlElement.focus
              })
            }
          }

          if e->ReactEvent.Keyboard.key == "ArrowDown" {
            e->ReactEvent.Keyboard.stopPropagation
            if cursorPosition == inputValueLength {
              e->ReactEvent.Keyboard.preventDefault
              // Common.focusNextClass(todoInputClass, dom)
              containerRef.current
              ->Nullable.toOption
              ->Option.mapOr((), dom => {
                dom->Obj.magic->HtmlElement.focus
              })
            }
          }

          if e->ReactEvent.Keyboard.key == "Backspace" && inputValueLength == 0 {
            if stagedForDelete {
              setTodos(todos => todos->Array.filter(t => t.id != todo.id))
              containerRef.current
              ->Nullable.toOption
              ->Option.mapOr((), containerEl => {
                Common.focusPreviousClass(listItemClass, containerEl)
              })
            } else {
              setStagedForDelete(_ => true)
            }
          }

          if e->ReactEvent.Keyboard.key == "Enter" && cursorPosition == inputValueLength {
            Console.log("next")
            e->ReactEvent.Keyboard.stopPropagation
            let newId = Common.uuid()
            setTodos(v =>
              v
              ->Array.findIndexOpt(t => t.id == todo.id)
              ->Option.mapOr(
                v,
                i => {
                  v->Array.toSpliced(
                    ~start=i + 1,
                    ~remove=0,
                    ~insert=[
                      {
                        id: newId,
                        text: "",
                        project: todo.project,
                        isDone: false,
                        status: LaterUnsorted,
                      },
                    ],
                  )
                },
              )
            )

            setFocusIdNext(_ => Some(getTodoInputId(newId)))

            e->ReactEvent.Keyboard.preventDefault
            inputRef.current
            ->Nullable.toOption
            ->Option.mapOr((), inputEl => {
              let inputEl = inputEl->Obj.magic
              inputEl->HtmlElement.focus
              inputEl->HtmlInputElement.setSelectionStart(inputEl->HtmlInputElement.selectionEnd)
            })
          }
        })
      }
    }

    <div
      id={getTodoId(todo.id)}
      tabIndex={0}
      ref={ReactDOM.Ref.domRef(containerRef)}
      onBlur={_ => {
        setSelectElement(_ => None)
        setStagedForDelete(_ => false)
      }}
      onFocus={_ => {
        setSelectElement(_ => Some(Todo(todo.id)))
        setDisplayElement(_ => Some(Todo(todo.id)))
      }}
      onKeyDown={onKeyDownContainer}
      className={[
        listItemClass,
        "flex flex-row justify-start items-center gap-2 px-2",
        // "focus:bg-slate-100 focus:outline focus:outline-1 focus:-outline-offset-1",
        // "focus-within:bg-slate-100 focus-within:outline focus-within:outline-1 focus-within:-outline-offset-1",

        stagedForDelete
          ? "bg-red-200 outline outline-1 -outline-offset-1"
          : isSelected
          ? "bg-slate-100 outline outline-1 -outline-offset-1"
          : "",
      ]->Array.join(" ")}>
      <StatusSelect
        status={todo.status}
        setStatus={newStatus =>
          updateTodo(todo.id, todo => {
            ...todo,
            status: newStatus,
          })}
      />
      <input
        id={getTodoInputId(todo.id)}
        ref={ReactDOM.Ref.domRef(inputRef)}
        type_="text"
        className={[
          todoInputClass,
          " flex-1 bg-inherit text-[--foreground] w-full outline-none 
          leading-none padding-none border-none h-5 -my-1 focus:text-blue-500",
        ]->Array.join(" ")}
        placeholder={""}
        value={todo.text}
        onBlur={_ => setSelectElement(_ => None)}
        onFocus={_ => {
          setSelectElement(_ => Some(Todo(todo.id)))
          setDisplayElement(_ => Some(Todo(todo.id)))
        }}
        onKeyDown={onKeyDownInput}
        onChange={e => {
          updateTodo(todo.id, t => {
            ...t,
            text: ReactEvent.Form.target(e)["value"],
          })
        }}
      />
    </div>
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
  ~selectElement,
  ~setSelectElement,
  ~displayElement,
  ~setDisplayElement,
  ~setFocusIdNext,
  ~setTodos,
) => {
  let projectRef = React.useRef(Nullable.null)

  let isSelected = selectElement == Some(Project(project.id))

  let onKeyDownProject = e => {
    if isSelected {
      // if e->ReactEvent.Keyboard.key == "Enter" {
      //   setFocusIdNext(_ => Some("id-display-title"))
      // }

      projectRef.current
      ->Nullable.toOption
      ->Option.mapOr((), dom => {
        if e->ReactEvent.Keyboard.key == "ArrowUp" {
          e->ReactEvent.Keyboard.preventDefault
          Common.focusPreviousClass(listItemClass, dom)
        }

        if e->ReactEvent.Keyboard.key == "ArrowDown" {
          e->ReactEvent.Keyboard.preventDefault
          Common.focusNextClass(listItemClass, dom)
        }
      })
    }
  }

  <div className="border-b">
    <div
      id={getProjectId(project.id)}
      tabIndex={0}
      ref={ReactDOM.Ref.domRef(projectRef)}
      onKeyDown={onKeyDownProject}
      onFocus={_ => {
        setSelectElement(_ => Some(Project(project.id)))
        setDisplayElement(_ => Some(Project(project.id)))
      }}
      className={[
        listItemClass,
        "h-6 flex flex-row justify-between items-center bg-slate-300",
        isSelected ? "outline outline-1 -outline-offset-1" : "",
      ]->Array.join(" ")}>
      <div className=" flex-none px-2"> {project.name->React.string} </div>
      <div className="flex-1" />
      <button
        className="rounded bg-slate-200 px-1 text-xs h-fit flex-none"
        onClick={_ =>
          updateProject(project.id, p => {
            ...p,
            isActive: !p.isActive,
          })}>
        {(project.isActive ? "Active" : "Not Active")->React.string}
      </button>
      <button
        className="text-xs rounded h-3 w-4 flex-none"
        onClick={_ =>
          setShowArchive(v =>
            v->Array.includes(project.id)
              ? v->Array.filter(el => el != project.id)
              : v->Array.concat([project.id])
          )}>
        {(showArchive ? "^" : "v")->React.string}
      </button>
    </div>
    <div>
      <div className="flex flex-col divide-y ">
        {todos
        ->Array.filter(todo => showArchive ? true : !isArchiveStatus(todo.status))
        // ->Array.toSorted((a, b) => a.status->statusToFloat -. b.status->statusToFloat)
        ->Array.map(todo =>
          <Todo
            key={getTodoId(todo.id)}
            todo
            updateTodo
            isSelected={selectElement == Some(Todo(todo.id))}
            setSelectElement
            displayElement
            setDisplayElement
            setTodos
            setFocusIdNext
          />
        )
        ->React.array}
      </div>
    </div>
  </div>
}

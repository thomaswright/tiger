open Types
open Webapi.Dom
open Common

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
    ~newTodoAfter,
    ~getTodos: unit => array<todo>,
  ) => {
    let addSubTodo = _ => ()

    let (statusSelectIsOpen, setStatusSelectIsOpen) = React.useState(() => false)
    let inputRef = React.useRef(Nullable.null)
    let containerRef = React.useRef(Nullable.null)

    let (stagedForDelete, setStagedForDelete) = React.useState(_ => false)

    let onKeyDownContainer = e => {
      if isSelected && containerRef.current->Nullable.toOption == document->Document.activeElement {
        containerRef.current->mapNullable(dom => {
          if e->ReactEvent.Keyboard.key == "s" {
            e->ReactEvent.Keyboard.preventDefault
            setStatusSelectIsOpen(_ => true)
          }

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
            containerRef.current->mapNullable(containerEl => {
              Common.focusPreviousClass(listItemClass, containerEl)
            })
          }

          if e->ReactEvent.Keyboard.key == "Enter" && e->ReactEvent.Keyboard.metaKey {
            getTodos()
            ->Array.findIndexOpt(v => v.id == todo.id)
            ->Option.mapOr((), todoIndex => newTodoAfter(todoIndex))
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
          containerRef.current->mapNullable(dom => {
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
              containerRef.current->mapNullable(dom => {
                dom->Obj.magic->HtmlElement.focus
              })
            }
          }

          if e->ReactEvent.Keyboard.key == "ArrowDown" {
            e->ReactEvent.Keyboard.stopPropagation
            if cursorPosition == inputValueLength {
              e->ReactEvent.Keyboard.preventDefault
              // Common.focusNextClass(todoInputClass, dom)
              containerRef.current->mapNullable(dom => {
                dom->Obj.magic->HtmlElement.focus
              })
            }
          }

          if e->ReactEvent.Keyboard.key == "Backspace" && inputValueLength == 0 {
            if stagedForDelete {
              setTodos(todos => todos->Array.filter(t => t.id != todo.id))
              containerRef.current->mapNullable(containerEl => {
                Common.focusPreviousClass(listItemClass, containerEl)
              })
            } else {
              setStagedForDelete(_ => true)
            }
          }

          if e->ReactEvent.Keyboard.key == "Enter" && cursorPosition == inputValueLength {
            e->ReactEvent.Keyboard.stopPropagation
            getTodos()
            ->Array.findIndexOpt(v => v.id == todo.id)
            ->Option.mapOr((), todoIndex => newTodoAfter(todoIndex))
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
        // "focus:bg-blue-300 focus-within:bg-green-200", // helpful for debug
        "group flex flex-row justify-start items-center  pl-2 h-6",
        stagedForDelete
          ? "bg-red-200 outline outline-1 -outline-offset-1"
          : isSelected
          ? "bg-var(--t1) outline outline-1 -outline-offset-1"
          : "",
      ]->Array.join(" ")}>
      <div className="text-xs w-5">
        {switch todo.box {
        | Working => React.null
        | Archive => <Icons.Archive />
        | Pinned => <Icons.Pin />
        }}
      </div>
      <Common.StatusSelect
        isOpen={statusSelectIsOpen}
        isPinned={todo.box == Pinned}
        isArchived={todo.box == Archive}
        onOpenChange={v => {
          if !v {
            containerRef.current->mapNullable(dom => {
              dom->Obj.magic->HtmlElement.focus
            })
            setStatusSelectIsOpen(_ => v)
          } else {
            setStatusSelectIsOpen(_ => v)
          }
        }}
        status={todo.status}
        focusTodo={() => {
          // this isn't set directly because the "Enter"
          // will then fire on the container then focusing
          // the input *shrugs*
          setFocusIdNext(_ => Some(getTodoId(todo.id)))
        }}
        setStatus={newStatus =>
          updateTodo(todo.id, t => {
            ...t,
            status: newStatus,
            box: t.box == Archive && !(newStatus->statusIsResolved) ? Working : t.box,
          })}
      />
      <input
        id={getTodoInputId(todo.id)}
        ref={ReactDOM.Ref.domRef(inputRef)}
        type_="text"
        className={[
          todoInputClass,
          "mx-1 flex-1 bg-inherit text-[--t10] w-full outline-none  text-xs font-medium
          leading-none padding-none border-none h-5 -my-1 focus:text-blue-600",
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
      <button
        className={["text-xs  mr-1", isSelected ? "" : "hidden"]->Array.join(" ")}
        onClick={_ => addSubTodo(todo.id)}>
        <Icons.Plus />
      </button>
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
  ~setTodos: (array<Types.todo> => array<Types.todo>) => unit,
  ~getTodos,
) => {
  let projectRef = React.useRef(Nullable.null)

  let isSelected = selectElement == Some(Project(project.id))

  let newTodoAfter = i => {
    let newId = Common.uuid()
    setTodos(v => {
      v->Array.toSpliced(
        ~start=i + 1,
        ~remove=0,
        ~insert=[
          {
            id: newId,
            text: "",
            project: project.id,
            isDone: false,
            status: Unsorted,
            box: Working,
          },
        ],
      )
    })

    setFocusIdNext(_ => Some(getTodoInputId(newId)))
  }

  let onKeyDownProject = e => {
    if isSelected {
      if e->ReactEvent.Keyboard.key == "Enter" {
        // setFocusIdNext(_ => Some("id-display-title"))
        newTodoAfter(-1)
      }

      projectRef.current->mapNullable(dom => {
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

  <div className="">
    <div
      id={getProjectId(project.id)}
      tabIndex={0}
      ref={ReactDOM.Ref.domRef(projectRef)}
      onKeyDown={onKeyDownProject}
      onBlur={_ => setSelectElement(_ => None)}
      onFocus={_ => {
        setSelectElement(_ => Some(Project(project.id)))
        setDisplayElement(_ => Some(Project(project.id)))
      }}
      className={[
        listItemClass,
        "h-7 flex flex-row justify-between items-center bg-[var(--t2)] px-1 gap-1",
        isSelected ? "outline outline-1 -outline-offset-1 " : "",
      ]->Array.join(" ")}>
      <div className=" flex-none px-2 text-sm"> {project.name->React.string} </div>
      <div className="flex-1" />
      <button
        onClick={_ => {
          newTodoAfter(-1)
        }}
        className="text-xs rounded h-6 w-6 flex-none mr-2">
        <Icons.Plus />
      </button>
      <button
        className="text-xs rounded h-6 w-6 flex-none"
        onClick={_ =>
          setShowArchive(v =>
            v->Array.includes(project.id)
              ? v->Array.filter(el => el != project.id)
              : v->Array.concat([project.id])
          )}>
        {showArchive ? <Icons.Archive /> : <Icons.ArchiveOff />}
      </button>
    </div>
    <div>
      <div className="flex flex-col divide-y ">
        {todos
        ->Array.filter(todo => showArchive ? true : todo.box != Archive)
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
            newTodoAfter
            getTodos
          />
        )
        ->React.array}
      </div>
    </div>
  </div>
}

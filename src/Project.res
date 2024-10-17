open Types
open Webapi.Dom
module StatusSelect = {
  @react.component @module("./StatusSelect.jsx")
  external make: (~status: status, ~setStatus: status => unit) => React.element = "default"
}

module Todo = {
  let todoClass = "class-list-todo"
  let todoInputClass = "class-list-todo-input"

  @react.component
  let make = (~todo: todo, ~updateTodo, ~isSelected, ~setSelectElement) => {
    let inputRef = React.useRef(Nullable.null)
    let containerRef = React.useRef(Nullable.null)

    <div
      tabIndex={0}
      ref={ReactDOM.Ref.domRef(containerRef)}
      // onBlur={_ => setSelectElement(_ => None)}
      onFocus={_ => setSelectElement(_ => Some(Todo(todo.id)))}
      onKeyDown={e => {
        if isSelected {
          containerRef.current
          ->Nullable.toOption
          ->Option.mapOr((), dom => {
            if e->ReactEvent.Keyboard.key == "ArrowUp" {
              e->ReactEvent.Keyboard.preventDefault
              Common.focusPreviousClass(todoClass, dom)
            }

            if e->ReactEvent.Keyboard.key == "ArrowDown" {
              e->ReactEvent.Keyboard.preventDefault
              Common.focusNextClass(todoClass, dom)
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
          })
        }
      }}
      className={[
        todoClass,
        "flex flex-row justify-start items-center gap-2 px-2",
        // "focus:bg-slate-100 focus:outline focus:outline-1 focus:-outline-offset-1",
        // "focus-within:bg-slate-100 focus-within:outline focus-within:outline-1 focus-within:-outline-offset-1",
        isSelected ? "bg-slate-100 outline outline-1 -outline-offset-1" : "",
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
        ref={ReactDOM.Ref.domRef(inputRef)}
        type_="text"
        className={[
          todoInputClass,
          " flex-1 bg-inherit text-[--foreground] w-full outline-none 
          leading-none padding-none border-none h-5 -my-1 focus:text-blue-500",
        ]->Array.join(" ")}
        placeholder={""}
        value={todo.text}
        // onBlur={_ => setSelectElement(_ => None)}
        onFocus={_ => setSelectElement(_ => Some(Todo(todo.id)))}
        onKeyDown={e => {
          if isSelected {
            if e->ReactEvent.Keyboard.key == "Escape" {
              e->ReactEvent.Keyboard.preventDefault
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
                  Common.focusPreviousClass(todoInputClass, dom)
                }
              }

              if e->ReactEvent.Keyboard.key == "ArrowDown" {
                e->ReactEvent.Keyboard.stopPropagation
                if cursorPosition == inputValueLength {
                  e->ReactEvent.Keyboard.preventDefault
                  Common.focusNextClass(todoInputClass, dom)
                }
              }
            })
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
) => {
  <div className="border-y">
    <div className="flex flex-row justify-between items-center bg-slate-300">
      <div> {project.name->React.string} </div>
      <button
        className="rounded bg-slate-200 w-20 text-xs h-fit"
        onClick={_ =>
          updateProject(project.id, p => {
            ...p,
            isActive: !p.isActive,
          })}>
        {(project.isActive ? "Active" : "Not Active")->React.string}
      </button>
      <button
        className="text-xs rounded h-3 w-10"
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
        ->Array.toSorted((a, b) => a.status->statusToFloat -. b.status->statusToFloat)
        ->Array.map(todo =>
          <Todo
            todo updateTodo isSelected={selectElement == Some(Todo(todo.id))} setSelectElement
          />
        )
        ->React.array}
      </div>
    </div>
  </div>
}

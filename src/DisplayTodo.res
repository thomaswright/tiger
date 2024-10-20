open Types
open Webapi.Dom
open Common

@react.component
let make = (
  ~todo: todo,
  ~setFocusIdNext,
  ~updateTodo,
  ~setTodos: (array<todo> => array<todo>) => unit,
) => {
  let (statusSelectIsOpen, setStatusSelectIsOpen) = React.useState(() => false)

  <div>
    <input
      type_="text"
      id="id-display-title"
      className={[
        "px-2 flex-1 bg-inherit text-[--t10] w-full outline-none 
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
    <button
      onClick={_ => {
        document
        ->Document.getElementById(getTodoId(todo.id))
        ->Option.mapOr((), todoEl => Common.focusPreviousClass(listItemClass, todoEl))

        setTodos(v => v->Array.filter(t => t.id != todo.id))
      }}
      className={["bg-[var(--t2)] px-2 rounded"]->Array.join(" ")}>
      {"Delete Todo"->React.string}
    </button>
    <div>
      <button
        onClick={_ => {
          setTodos(v =>
            v->Array.map(t =>
              t.id == todo.id
                ? {
                    ...t,
                    box: t.box != Pinned ? Pinned : Working,
                  }
                : t
            )
          )
        }}
        className={[
          " px-2 rounded",
          todo.box == Pinned ? "text-blue-600" : "text-[var(--t4)]",
        ]->Array.join(" ")}>
        <Icons.Pin />
      </button>
      <button
        onClick={_ => {
          setTodos(v =>
            v->Array.map(t =>
              t.id == todo.id
                ? {
                    ...t,
                    box: t.box != Archive ? Archive : Working,
                    status: t.status->statusIsResolved ? t.status : ResolveScrap,
                  }
                : t
            )
          )
        }}
        className={[
          " px-2 rounded flex flex-row items-center gap-1",
          todo.box == Archive ? "text-blue-600" : "text-[var(--t4)]",
        ]->Array.join(" ")}>
        <Icons.Archive />
        {!(todo.status->statusIsResolved) && todo.box != Archive
          ? "& Scrap"->React.string
          : React.null}
      </button>
    </div>
    <Common.StatusSelect
      isOpen={statusSelectIsOpen}
      onOpenChange={v => {
        setStatusSelectIsOpen(_ => v)
      }}
      status={todo.status}
      focusTodo={() => ()}
      setStatus={newStatus =>
        updateTodo(todo.id, todo => {
          ...todo,
          status: newStatus,
        })}
    />
  </div>
}

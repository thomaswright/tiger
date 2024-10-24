open Types
open Webapi.Dom
@warning("-33")
open Common

@react.component
let make = (
  ~project: project,
  ~todo: todo,
  ~setFocusIdNext,
  ~updateTodo,
  ~setTodos: (string, array<todo> => array<todo>) => unit,
  ~deleteTodo,
) => {
  let (statusSelectIsOpen, setStatusSelectIsOpen) = React.useState(() => false)

  <div className="w-full">
    <div className="w-full px-2 py-1">
      <Common.TextareaAutosize
        style={{
          resize: "none",
        }}
        id="id-display-title"
        className={[
          "text-lg flex-1 bg-inherit text-[--t10] w-full outline-none 
          focus:ring-0
          font-medium 
           border-none p-0 ",
        ]->Array.join(" ")}
        placeholder={"Todo"}
        value={todo.text}
        onKeyDown={e => {
          if e->ReactEvent.Keyboard.key == "Escape" {
            setFocusIdNext(_ => Some(getTodoId(todo.id)))
          }
        }}
        onChange={e => {
          updateTodo(project.id, todo.id, t => {
            ...t,
            text: ReactEvent.Form.target(e)["value"],
          })
        }}
      />
    </div>
    <div className="flex flex-row border-y items-center gap-3 p-1 px-2">
      <Common.StatusSelect
        isOpen={statusSelectIsOpen}
        isPinned={todo.box == Pinned}
        isArchived={todo.box == Archive}
        onOpenChange={v => {
          setStatusSelectIsOpen(_ => v)
        }}
        status={Some(todo.status)}
        focusTodo={() => ()}
        setStatus={newStatus =>
          updateTodo(project.id, todo.id, t => {
            ...t,
            status: newStatus,
            box: t.box == Archive && !(newStatus->statusIsResolved) ? Working : t.box,
          })}
      />
      <div className={"flex-1"} />
      {todo.status->statusIsResolved
        ? <button
            onClick={_ => {
              setTodos(project.id, v =>
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
              " px-1 h-6 flex flex-row items-center justify-center rounded border-[var(--t3)] gap-1
          hover:text-blue-600
          ",
              todo.box == Archive ? "text-blue-600" : "text-[var(--t4)]",
            ]->Array.join(" ")}>
            // {!(todo.status->statusIsResolved) && todo.box != Archive
            //   ? "Scrap &"->React.string
            //   : React.null}
            <Icons.Archive />
          </button>
        : React.null}
      {todo.status->statusIsResolved
        ? <button
            onClick={_ => {
              setTodos(project.id, v =>
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
              " px-1 h-6 flex flex-row items-center justify-center rounded border-[var(--t3)]
          hover:text-blue-600
          ",
              todo.box == Pinned ? "text-blue-600" : "text-[var(--t4)]",
            ]->Array.join(" ")}>
            <Icons.Pin />
          </button>
        : React.null}
      <button
        onClick={_ => {
          Webapi.Dom.document
          ->Document.getElementById(getTodoId(todo.id))
          ->Option.mapOr((), todoEl => Common.focusPreviousClass(listItemClass, todoEl))
          deleteTodo(project.id, todo)
        }}
        className={[
          "
          text-[var(--t4)] px-1 h-6 flex flex-row items-center justify-center rounded border-[var(--t3)]
          hover:text-blue-600
        ",
        ]->Array.join(" ")}>
        <Icons.Trash />
      </button>
    </div>
  </div>
}

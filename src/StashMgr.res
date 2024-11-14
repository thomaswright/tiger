open Webapi.Dom
open Common
open Types

@react.component
let make = (
  ~stashed: array<string>,
  ~setStashed: (array<string> => array<string>) => unit,
  ~todos: array<todo>,
) => {
  <div>
    <div className="flex flex-row gap-1 p-2">
      <button
        className="px-2 bg-[var(--t2)] rounded text-sm h-5" onClick={_ => setStashed(_ => [])}>
        {"Unstash All"->React.string}
      </button>
      <button
        className="px-2 bg-[var(--t2)] rounded text-sm h-5"
        onClick={_ => setStashed(_ => todos->Array.map(x => x.id))}>
        {"Stash All "->React.string}
      </button>
    </div>
    <div className="flex flex-col p-2 cursor-pointer divide-y">
      {todos
      ->Array.map(todo => {
        let isStashed = stashed->Array.includes(todo.id)

        <div
          className={[
            "text-sm px-2 min-h-6  flex flex-row items-center rounded gap-1 ",
          ]->Array.join(" ")}>
          <div className="flex flex-row gap-1 rounded p-1">
            <div
              onClick={_ => {
                setStashed(v => v->Array.filter(x => x != todo.id))
                setTodoHidden(todo.id, false)
              }}
              className={[
                !isStashed && !todo.hidden ? "bg-[var(--t3)]" : "",
                "w-5 flex flex-row items-center justify-center rounded",
              ]->Array.join(" ")}>
              {"W"->React.string}
            </div>
            <div
              onClick={_ => {
                setStashed(v => v->Array.includes(todo.id) ? v : v->Array.concat([todo.id]))

                setTodoHidden(todo.id, false)
              }}
              className={[
                isStashed && !todo.hidden ? "bg-[var(--t3)]" : "",
                "w-5 flex flex-row items-center justify-center rounded",
              ]->Array.join(" ")}>
              {"S"->React.string}
            </div>
            <div
              onClick={_ => {
                setStashed(v => v->Array.filter(x => x != todo.id))
                setTodoHidden(todo.id, true)
              }}
              className={[
                todo.hidden ? "bg-[var(--t3)]" : "",
                "w-5 flex flex-row items-center justify-center rounded",
              ]->Array.join(" ")}>
              {"A"->React.string}
            </div>
          </div>
          <div className="max-w-80  flex flex-row items-center rounded">
            {todo.text->Nullable.toOption->Option.getOr("")->React.string}
          </div>
        </div>
      })
      ->React.array}
    </div>
  </div>
}

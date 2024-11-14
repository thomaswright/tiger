open Common
open Types

@react.component
let make = (
  // ~stashed: array<string>,
  // ~setStashed: (array<string> => array<string>) => unit,
  ~todo: option<todo>,
  ~todos: array<todo>,
) => {
  <div>
    <div className="flex flex-row gap-1 p-2">
      <button
        className="px-2 bg-[var(--t2)] rounded text-sm h-5"
        onClick={_ =>
          batch(() => {
            todos
            ->Array.filter(x => x.mode == Stashed)
            ->Array.forEach(x => {
              setTodoMode(x.id, Working)
            })
          })}>
        {"Stash to Working"->React.string}
      </button>
      <button
        className="px-2 bg-[var(--t2)] rounded text-sm h-5"
        onClick={_ =>
          batch(() => {
            todos
            ->Array.filter(x => x.mode == Working)
            ->Array.forEach(x => {
              setTodoMode(x.id, Stashed)
            })
          })}>
        {"Working to Stash "->React.string}
      </button>
    </div>
    {todo->Option.mapOr(React.null, todo => {
      <div className="flex flex-row gap-1 rounded p-1">
        <button
          onClick={_ => {
            // setStashed(v => v->Array.filter(x => x != todo.id))
            setTodoShowMode(todo.id, Working)
          }}
          className={[
            todo.show_mode == Working ? "bg-[var(--t3)]" : "",
            "px-2 py-0.5 text-xs flex flex-row items-center justify-center rounded",
          ]->Array.join(" ")}>
          {"W"->React.string}
        </button>
        <button
          onClick={_ => {
            // setStashed(v => v->Array.includes(todo.id) ? v : v->Array.concat([todo.id]))

            setTodoShowMode(todo.id, Stashed)
          }}
          className={[
            todo.show_mode == Stashed ? "bg-[var(--t3)]" : "",
            "px-2 py-0.5 text-xs flex flex-row items-center justify-center rounded",
          ]->Array.join(" ")}>
          {"W+S"->React.string}
        </button>
        <button
          onClick={_ => {
            // setStashed(v => v->Array.filter(x => x != todo.id))
            setTodoShowMode(todo.id, Archive)
          }}
          className={[
            todo.show_mode == Archive ? "bg-[var(--t3)]" : "",
            "px-2 py-0.5 text-xs flex flex-row items-center justify-center rounded",
          ]->Array.join(" ")}>
          {"W+S+A"->React.string}
        </button>
      </div>
    })}
    <div className="flex flex-col p-2 cursor-pointer divide-y">
      {todos
      ->Array.map(todo => {
        <div
          className={[
            "text-sm px-2 min-h-6  flex flex-row items-center rounded gap-1 ",
          ]->Array.join(" ")}>
          <div className="flex flex-row gap-1 rounded p-1">
            <button
              onClick={_ => {
                // setStashed(v => v->Array.filter(x => x != todo.id))
                setTodoMode(todo.id, Working)
              }}
              className={[
                todo.mode == Working ? "bg-[var(--t3)]" : "",
                "w-5 flex flex-row items-center justify-center rounded",
              ]->Array.join(" ")}>
              {"W"->React.string}
            </button>
            <button
              onClick={_ => {
                // setStashed(v => v->Array.includes(todo.id) ? v : v->Array.concat([todo.id]))

                setTodoMode(todo.id, Stashed)
              }}
              className={[
                todo.mode == Stashed ? "bg-[var(--t3)]" : "",
                "w-5 flex flex-row items-center justify-center rounded",
              ]->Array.join(" ")}>
              {"S"->React.string}
            </button>
            <button
              onClick={_ => {
                // setStashed(v => v->Array.filter(x => x != todo.id))
                setTodoMode(todo.id, Archive)
              }}
              className={[
                todo.mode == Archive ? "bg-[var(--t3)]" : "",
                "w-5 flex flex-row items-center justify-center rounded",
              ]->Array.join(" ")}>
              {"A"->React.string}
            </button>
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

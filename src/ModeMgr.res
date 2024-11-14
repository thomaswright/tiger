open Common
open Types

module Select = {
  @react.component
  let make = (~parentTodo, ~todo) => {
    <div className="flex flex-row rounded">
      <button
        onClick={_ => {
          setTodoMode(todo.id, Working)
        }}
        className={[
          todo.mode == Working ? " text-[var(--t9)]" : "text-[var(--t3)]",
          "w-6 h-6 flex flex-row items-center justify-center rounded",
        ]->Array.join(" ")}>
        // {"W"->React.string}
        <Icons.Inbox />
      </button>
      <button
        onClick={_ => {
          setTodoMode(todo.id, Stashed)
        }}
        className={[
          todo.mode == Stashed
            ? parentTodo->Option.mapOr(false, x => x.show_mode == Archive || x.show_mode == Stashed)
                ? " text-[var(--t9)]"
                : "text-[var(--t9)]"
            : "text-[var(--t3)]",
          "w-6 h-6 flex flex-row items-center justify-center rounded ",
        ]->Array.join(" ")}>
        // {"S"->React.string}
        <Icons.Bookmark />
      </button>
      <button
        onClick={_ => {
          setTodoMode(todo.id, Archive)
        }}
        className={[
          todo.mode == Archive
            ? parentTodo->Option.mapOr(false, x => x.show_mode == Archive)
                ? " text-[var(--t9)]"
                : " text-[var(--t9)]"
            : "text-[var(--t3)]",
          "w-6 h-6 flex flex-row items-center justify-center rounded",
        ]->Array.join(" ")}>
        // {"A"->React.string}
        <Icons.Archive />
      </button>
    </div>
  }
}

@react.component
let make = (
  // ~stashed: array<string>,
  // ~setStashed: (array<string> => array<string>) => unit,
  ~todo: option<todo>,
  ~todos: array<todo>,
) => {
  <div>
    // {todo->Option.mapOr(React.null, todo => <Select parentTodo={None} todo={todo} />)}
    <div className="flex flex-row gap-1 p-2">
      <button
        className="px-2 bg-[var(--t2)] rounded text-sm h-5 flex flex-row items-center gap-1"
        onClick={_ =>
          batch(() => {
            todos
            ->Array.filter(x => x.mode == Stashed)
            ->Array.forEach(x => {
              setTodoMode(x.id, Working)
            })
          })}>
        <Icons.Inbox />
        <Icons.ArrowLeft />
        <Icons.Bookmark />
      </button>
      <button
        className="px-2 bg-[var(--t2)] rounded text-sm h-5 flex flex-row items-center gap-1"
        onClick={_ =>
          batch(() => {
            todos
            ->Array.filter(x => x.mode == Working)
            ->Array.forEach(x => {
              setTodoMode(x.id, Stashed)
            })
          })}>
        <Icons.Inbox />
        <Icons.ArrowRight />
        <Icons.Bookmark />
      </button>
    </div>
    {todo->Option.mapOr(React.null, todo => {
      <div className="flex flex-row rounded py-1 px-2 ml-0.5 gap-1">
        <button
          onClick={_ => {
            // setStashed(v => v->Array.filter(x => x != todo.id))
            setTodoShowMode(todo.id, Working)
          }}
          className={[
            todo.show_mode == Working ? "bg-[var(--t2)] text-[var(--t9)]" : "",
            "w-5 h-5 text-xs flex flex-row items-center justify-center rounded",
          ]->Array.join(" ")}>
          <Icons.ChevronLeft />
        </button>
        <button
          onClick={_ => {
            // setStashed(v => v->Array.includes(todo.id) ? v : v->Array.concat([todo.id]))

            setTodoShowMode(todo.id, Stashed)
          }}
          className={[
            todo.show_mode == Stashed ? "bg-[var(--t2)] text-[var(--t9)]" : "",
            "w-5 h-5 text-xs flex flex-row items-center justify-center rounded",
          ]->Array.join(" ")}>
          <Icons.ChevronLeft />
        </button>
        <button
          onClick={_ => {
            // setStashed(v => v->Array.filter(x => x != todo.id))
            setTodoShowMode(todo.id, Archive)
          }}
          className={[
            todo.show_mode == Archive ? "bg-[var(--t2)] text-[var(--t9)]" : "",
            "w-5 h-5 text-xs flex flex-row items-center justify-center rounded",
          ]->Array.join(" ")}>
          <Icons.ChevronLeft />
        </button>
      </div>
    })}
    <div className="flex flex-col px-2 cursor-pointer divide-y">
      {todos
      ->Array.map(t => {
        <div className={["text-sm min-h-6  flex flex-row items-center  gap-1 "]->Array.join(" ")}>
          <Select parentTodo={todo} todo={t} />
          <div className="max-w-80  flex flex-row items-center rounded ">
            {t.text->Nullable.toOption->Option.getOr("")->React.string}
          </div>
        </div>
      })
      ->React.array}
    </div>
  </div>
}

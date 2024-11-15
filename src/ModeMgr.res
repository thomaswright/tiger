open Common
open Types

module Select = {
  @react.component
  let make = (~todo) => {
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
          todo.mode == Stashed ? "text-[var(--t9)]" : "text-[var(--t3)]",
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
          todo.mode == Archive ? " text-[var(--t9)]" : "text-[var(--t3)]",
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
    // <div className="flex flex-row gap-1 p-2">
    //   <button
    //     className="px-2 bg-[var(--t2)] rounded text-sm h-5 flex flex-row items-center gap-1"
    //     onClick={_ =>
    //       batch(() => {
    //         todos
    //         ->Array.filter(x => x.mode == Stashed)
    //         ->Array.forEach(x => {
    //           setTodoMode(x.id, Working)
    //         })
    //       })}>
    //     <Icons.Inbox />
    //     <Icons.ArrowLeft />
    //     <Icons.Bookmark />
    //   </button>
    //   <button
    //     className="px-2 bg-[var(--t2)] rounded text-sm h-5 flex flex-row items-center gap-1"
    //     onClick={_ =>
    //       batch(() => {
    //         todos
    //         ->Array.filter(x => x.mode == Working)
    //         ->Array.forEach(x => {
    //           setTodoMode(x.id, Stashed)
    //         })
    //       })}>
    //     <Icons.Inbox />
    //     <Icons.ArrowRight />
    //     <Icons.Bookmark />
    //   </button>
    // </div>
    {todo->Option.mapOr(React.null, todo => {
      <div className="flex flex-row rounded py-1 px-2 ml-1 gap-2">
        {[Working, Stashed, Archive]
        ->Array.mapWithIndex((v, i) => {
          <input
            key={i->Int.toString}
            type_={"checkbox"}
            checked={todo.modes_shown->Array.includes(v)}
            onChange={_ => {
              setTodoModesShown(todo.id, a => a->arrayToggle(v))
            }}
            className={[
              "border-[var(--t4)] bg-[var(--t0)] rounded text-blue-400 dark:text-blue-800 w-4 h-4 focus:ring-offset-0 focus:ring-blue-500",
            ]->Array.join(" ")}
          />
        })
        ->React.array}
      </div>
    })}
    <div className="flex flex-col px-2 cursor-pointer divide-y">
      {todos
      ->Array.map(t => {
        <div
          key={t.id}
          className={["text-sm min-h-6  flex flex-row items-center  gap-1 "]->Array.join(" ")}>
          <Select todo={t} />
          <div className="max-w-80  flex flex-row items-center rounded ">
            {t.text->Nullable.toOption->Option.getOr("")->React.string}
          </div>
        </div>
      })
      ->React.array}
    </div>
  </div>
}

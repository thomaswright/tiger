open Common
open Types

@react.component
let make = (~todo: option<todo>) => {
  <div className="flex flex-row rounded gap-1">
    <button
      onClick={_ => {
        todo->Option.mapOr((), todo => setTodoModesShown(todo.id, a => a->arrayToggle(Working)))
      }}
      className={[
        todo->Option.mapOr(false, todo => todo.modes_shown->Array.includes(Working))
          ? " text-blue-600"
          : "text-[var(--t3)]",
        "w-6 h-6 flex flex-row items-center justify-center rounded",
      ]->Array.join(" ")}>
      // {"W"->React.string}
      <Icons.Inbox />
    </button>
    <button
      onClick={_ => {
        todo->Option.mapOr((), todo => setTodoModesShown(todo.id, a => a->arrayToggle(Stashed)))
      }}
      className={[
        todo->Option.mapOr(false, todo => todo.modes_shown->Array.includes(Stashed))
          ? "text-blue-600"
          : "text-[var(--t3)]",
        "w-6 h-6 flex flex-row items-center justify-center rounded ",
      ]->Array.join(" ")}>
      // {"S"->React.string}
      <Icons.Bookmark />
    </button>
    <button
      onClick={_ => {
        todo->Option.mapOr((), todo => setTodoModesShown(todo.id, a => a->arrayToggle(Archive)))
      }}
      className={[
        todo->Option.mapOr(false, todo => todo.modes_shown->Array.includes(Archive))
          ? " text-blue-600"
          : "text-[var(--t3)]",
        "w-6 h-6 flex flex-row items-center justify-center rounded",
      ]->Array.join(" ")}>
      // {"A"->React.string}
      <Icons.Archive />
    </button>
  </div>
}

open Types

module StatusSelect = {
  @react.component @module("./StatusSelect.jsx")
  external make: (~status: status, ~setStatus: status => unit) => React.element = "default"
}

module Todo = {
  @react.component
  let make = (~todo: todo, ~updateTodo, ~isSelected, ~setSelectElement) => {
    <div
      onFocus={_ => setSelectElement(_ => Some(Todo(todo.id)))}
      className={[
        "flex flex-row justify-start items-center gap-2 px-2",
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
        type_="text"
        className={"flex-1 bg-inherit text-[--foreground] w-full outline-none leading-none padding-none border-none h-5 -my-1"}
        placeholder={""}
        value={todo.text}
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

open Types

module Todo = {
  @react.component
  let make = (~todo: todo) => {
    <div className="flex flex-row justify-start items-center gap-2 px-2">
      <div className="text-xs w-5 border rounded text-center">
        {todo.status->statusStringShort->React.string}
      </div>
      <div> {todo.text->React.string} </div>
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
        ->Array.map(todo => <Todo todo />)
        ->React.array}
      </div>
    </div>
  </div>
}

open Types
open Webapi.Dom
open Common

@react.component
let make = (
  ~project: project,
  ~updateProject,
  ~setProjects,
  ~setTodos: (array<todo> => array<todo>) => unit,
) => {
  <div>
    <input
      type_="text"
      id="id-display-title"
      className={[
        " flex-1 bg-inherit text-[--t10] w-full outline-none 
           border-none px-2 py-1  focus:text-blue-500",
      ]->Array.join(" ")}
      placeholder={"Project Name"}
      value={project.name}
      onChange={e => {
        updateProject(project.id, p => {
          ...p,
          name: ReactEvent.Form.target(e)["value"],
        })
      }}
    />
    <div className="flex flex-row border-y items-center gap-3 p-1 px-2">
      <button
        className="rounded bg-[var(--t2)] px-2 text-xs h-fit flex-none"
        onClick={_ =>
          updateProject(project.id, p => {
            ...p,
            isActive: !p.isActive,
          })}>
        {(project.isActive ? "Active" : "Inactive")->React.string}
      </button>
      <div className={"flex-1"} />
      <button
        onClick={_ => {
          document
          ->Document.getElementById(getProjectId(project.id))
          ->Option.mapOr((), projectEl => {
            Console.log(projectEl)
            Common.focusPreviousClass(listItemClass, projectEl)
          })

          setProjects(v => v->Array.filter(p => p.id != project.id))
          setTodos(v => v->Array.filter(p => p.project != project.id))
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
    <div className="p-2">
      <button
        className="rounded bg-[var(--t2)] px-2 text-xs h-fit flex-none"
        onClick={_ =>
          setTodos(todos => {
            todos->Array.map(t => {
              if t.project != project.id {
                t
              } else if t.status->statusIsResolved && t.box != Pinned {
                {
                  ...t,
                  box: Archive,
                }
              } else {
                t
              }
            })
          })}>
        {"Archive All Resolved if not Pinned"->React.string}
      </button>
    </div>
  </div>
}

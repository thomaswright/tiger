open Types
open Webapi.Dom
@warning("-33")
open Common

@react.component
let make = (
  ~project: project,
  ~updateProject,
  ~setProjects,
  ~setTodos: (string, array<todo> => array<todo>) => unit,
) => {
  <div>
    <Common.TextareaAutosize
      style={{
        resize: "none",
      }}
      id="id-display-title"
      className={[
        " flex-1 bg-inherit text-[--t10] w-full outline-none font-black tracking-tight focus:ring-0
           border-none px-0 py-0 my-1 mx-2",
      ]->Array.join(" ")}
      placeholder={"Project"}
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
          Webapi.Dom.document
          ->Document.getElementById(getProjectId(project.id))
          ->Option.mapOr((), projectEl => {
            Console.log(projectEl)
            Common.focusPreviousClass(listItemClass, projectEl)
          })

          setProjects(v => v->Array.filter(p => p.id != project.id))
          setTodos(project.id, v => v->Array.filter(p => p.project != project.id))
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
          setTodos(project.id, todos => {
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

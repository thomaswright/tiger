open Types
open Webapi.Dom

@react.component
let make = (
  ~project: project,
  ~updateProject,
  ~setProjects,
  ~setTodos: (string, array<todo> => array<todo>) => unit,
  ~handleHide,
) => {
  let handleHideArchived = _ => updateProject(project.id, p => handleHide(false, None, p))

  <div>
    <div className="w-full px-2 py-1">
      <Common.TextareaAutosize
        style={{
          resize: "none",
        }}
        id="id-display-title"
        className={[
          " flex-1 text-lg bg-inherit text-[--t10] w-full outline-none font-black tracking-tight focus:ring-0
           border-none px-0 py-0",
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
    </div>
    <div className="flex flex-row border-y border-[var(--t3)] items-center gap-3 p-1 px-2">
      <button
        className="rounded bg-[var(--t2)] px-2 text-xs h-fit flex-none"
        onClick={_ =>
          updateProject(project.id, p => {
            ...p,
            isActive: !p.isActive,
          })}>
        {(project.isActive ? "Active" : "Inactive")->React.string}
      </button>
      {project.hideAll
        ? <span className="text-xs "> {"All Hidden"->React.string} </span>
        : <button
            className="rounded bg-[var(--t2)] px-2 text-xs h-fit flex-none flex flex-row justify-center items-center"
            onClick={handleHideArchived}>
            // {project.hideArchived ? <Icons.ArchiveOff /> : <Icons.Archive />}
            {project.hideArchived
              ? <span> {"Hiding Archived"->React.string} </span>
              : <span> {"Showing Archived"->React.string} </span>}
          </button>}
      <div className={"flex-1"} />
      <button
        onClick={_ => {
          Webapi.Dom.document
          ->Document.getElementById(getProjectId(project.id))
          ->Option.mapOr((), projectEl => {
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
    // <button
    //   className="rounded bg-[var(--t2)] px-2 py-1 text-xs h-fit flex-none"
    //   onClick={_ =>
    //     setTodos(project.id, todos => {
    //       todos->Array.map(t => {
    //         if t.project != project.id {
    //           t
    //         } else if t.status->statusIsResolved && t.box != Pinned {
    //           {
    //             ...t,
    //             box: Archive,
    //           }
    //         } else {
    //           t
    //         }
    //       })
    //     })}>
    //   {"Archive All Resolved if not Pinned"->React.string}
    // </button>
    <div className="p-1">
      <Common.TextareaAutosize
        style={{
          resize: "none",
        }}
        id="id-display-title"
        className={[
          "placeholder:text-[var(--t4)] text-sm flex-1 border-none rounded-lg text-[var(--t10)] w-full outline-none bg-[var(--t1)]
          focus:ring-0 font-medium",
        ]->Array.join(" ")}
        placeholder={"Additional Project Details"}
        value={project.additionalText}
        onChange={e => {
          updateProject(project.id, t => {
            ...t,
            additionalText: ReactEvent.Form.target(e)["value"],
          })
        }}
      />
    </div>
  </div>
}

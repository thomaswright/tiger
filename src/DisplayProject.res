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
  let (stagedForDelete, setStagedForDelete) = React.useState(_ => false)

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
    <div
      className="flex flex-row flex-wrap border-y border-[var(--t3)] items-center gap-3 p-1 px-2">
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
      <button
        className="rounded bg-[var(--t2)] px-2 text-xs h-fit flex-none"
        onClick={_ =>
          updateProject(project.id, p => {
            let projectAllHidden = handleHide(true, Some(false), p)
            let orderedPerTodo = {
              ...projectAllHidden,
              hiddenTodos: projectAllHidden.hiddenTodos->SMap.map(todos =>
                todos->Array.toSorted(
                  (a, b) => {
                    switch (a.targetDate, b.targetDate) {
                    | (Some(ad), Some(bd)) =>
                      DateFns.compareAsc(ad->Date.fromString, bd->Date.fromString)->Int.toFloat
                    | (Some(_), None) => -1.
                    | (None, Some(_)) => 1.
                    | _ => 2.
                    }
                  },
                )
              ),
            }
            let newProjects = handleHide(true, Some(true), orderedPerTodo)
            newProjects
          })}>
        {"Sort by Date"->React.string}
      </button>
      <button
        className="rounded bg-[var(--t2)] px-2 text-xs h-fit flex-none"
        onClick={_ =>
          updateProject(project.id, p => {
            let projectAllHidden = handleHide(true, Some(false), p)
            let orderedPerTodo = {
              ...projectAllHidden,
              hiddenTodos: projectAllHidden.hiddenTodos->SMap.map(todos =>
                todos->Array.toSorted(
                  (a, b) => {
                    a.status->Types.statusToFloat -. b.status->Types.statusToFloat
                  },
                )
              ),
            }
            let newProjects = handleHide(true, Some(true), orderedPerTodo)
            newProjects
          })}>
        {"Sort by Status"->React.string}
      </button>
      {stagedForDelete
        ? <span>
            <button
              onClick={_ => {
                setStagedForDelete(_ => false)
              }}
              className="rounded bg-gray-100 px-2 font-medium  text-xs h-fit flex-none mr-2 ">
              {"Cancel"->React.string}
            </button>
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
              className="rounded bg-red-100 text-red-600 font-medium px-2 text-xs h-fit flex-none">
              {"Delete Project"->React.string}
            </button>
          </span>
        : <button
            onClick={_ => setStagedForDelete(_ => true)}
            className={[
              "
          text-[var(--t4)] px-1 h-6 flex flex-row items-center justify-center rounded border-[var(--t3)]
          hover:text-blue-600
        ",
            ]->Array.join(" ")}>
            <Icons.Trash />
          </button>}
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

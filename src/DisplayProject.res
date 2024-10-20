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
          leading-none padding-none border-none h-5 -my-1 focus:text-blue-500",
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
      className={["bg-[var(--t2)] px-2 rounded"]->Array.join(" ")}>
      {"Delete Project"->React.string}
    </button>
    <button
      className="rounded bg-[var(--t2)] px-1 text-xs h-fit flex-none"
      onClick={_ =>
        updateProject(project.id, p => {
          ...p,
          isActive: !p.isActive,
        })}>
      {(project.isActive ? "Active" : "Not Active")->React.string}
    </button>
  </div>
}

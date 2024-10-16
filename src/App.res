open Types

let defaultProjects = [
  {
    id: "1",
    name: "Project Omega",
    isActive: true,
  },
]
let defaultTodos = [
  {
    text: "Do Something",
    project: "1",
    id: "1",
    isDone: false,
    status: Keep(LaterWill),
  },
  {
    text: "Do Something Else",
    project: "1",
    id: "2",
    isDone: false,
    status: Archive(Rejected),
  },
]

// let filterMap = (m, f) => m ->
// Map.entries -> Array.fromIterator -> Array.filter(f) -> Map.fromArray

// let mapToArray = m => m ->
// Map.entries -> Array.fromIterator

@react.component
let make = () => {
  let (projects, setProjects, _) = Common.useLocalStorage("projects", defaultProjects)
  let (todos, setTodos, _) = Common.useLocalStorage("todos", defaultTodos)
  let (showArchive, setShowArchive, _) = Common.useLocalStorage("showArchive", [])
  let (projectsTab, setProjectTab, _) = Common.useLocalStorage("projectsTab", All)
  let updateProject = React.useCallback0((id, f) => {
    setProjects(v => v->Array.map(project => project.id == id ? f(project) : project))
  })

  <div className="p-6">
    <div className="text-xs w-[200px] bg-white p-2 flex flex-col gap-1">
      <div className="bg-white rounded  px-1 border"> {"Urgent"->React.string} </div>
      <div
        className="flex-none px-1 font-bold h-3 leading-none text-2xs flex flex-row items-center justify-center">
        {"Todo"->React.string}
      </div>
      <div className="flex flex-row justify-between gap-1">
        <div className="flex-1 px-1 bg-white rounded border"> {"High"->React.string} </div>
        <div className="flex-1 px-1 bg-white rounded border"> {"Med"->React.string} </div>
        <div className="flex-1 px-1 bg-white rounded border"> {"Low"->React.string} </div>
      </div>
      <div
        className="flex-none px-1 font-bold h-3 leading-none text-2xs flex flex-row items-center justify-center">
        {"Later"->React.string}
      </div>
      <div className="flex flex-row justify-between gap-1">
        <div className="flex-1 px-1 bg-white rounded border"> {"Will"->React.string} </div>
        <div className="flex-1 px-1 bg-white rounded border"> {"Mabye"->React.string} </div>
        <div className="flex-1 px-1 bg-white rounded border"> {"Unlikely"->React.string} </div>
      </div>
      <div className="flex flex-row justify-between gap-1">
        <div className="flex flex-row gap-1 flex-1  px-1">
          <div
            className="flex-none px-1 font-bold w-2 leading-none text-2xs flex flex-row items-center justify-center -rotate-90">
            {"Todo"->React.string}
          </div>
          <div className="flex flex-col gap-1 flex-1">
            <div className="flex-1 px-1 bg-white rounded border"> {"High"->React.string} </div>
            <div className="flex-1 px-1 bg-white rounded border"> {"Medium"->React.string} </div>
            <div className="flex-1 px-1 bg-white rounded border"> {"Low"->React.string} </div>
          </div>
        </div>
        <div className="flex flex-row gap-1 flex-1  px-1">
          <div
            className="flex-none px-1 font-bold w-2 leading-none text-2xs flex flex-row items-center justify-center -rotate-90">
            {"Later"->React.string}
          </div>
          <div className="flex flex-col gap-1 flex-1">
            <div className="flex-1 px-1 bg-white rounded border"> {"Will "->React.string} </div>
            <div className="flex-1 px-1 bg-white rounded border"> {"Maybe"->React.string} </div>
            <div className="flex-1 px-1 bg-white rounded border"> {"Unlikely"->React.string} </div>
          </div>
        </div>
      </div>
      <div className="flex flex-row justify-between gap-1">
        <div className="flex flex-row gap-1 flex-1  px-1">
          <div
            className="flex-none px-1 font-bold w-2 leading-none text-2xs flex flex-row items-center justify-center -rotate-90">
            {"Resolve"->React.string}
          </div>
          <div className="flex flex-col gap-1 flex-1">
            <div className="flex-1 px-1 bg-white rounded border"> {"Done"->React.string} </div>
            <div className="flex-1 px-1 bg-white rounded border"> {"Wont Do"->React.string} </div>
            <div className="flex-1 px-1 bg-white rounded border"> {"No Need"->React.string} </div>
          </div>
        </div>
        <div className="flex flex-row gap-1 flex-1 bg-slate-400 px-1">
          <div
            className="flex-none px-1 font-bold w-2 leading-none text-2xs flex flex-row items-center justify-center -rotate-90">
            {"Archive"->React.string}
          </div>
          <div className="flex flex-col gap-1 flex-1">
            <div className="flex-1 px-1 bg-white rounded border"> {"Done"->React.string} </div>
            <div className="flex-1 px-1 bg-white rounded border"> {"Wont Do"->React.string} </div>
            <div className="flex-1 px-1 bg-white rounded border"> {"No Need"->React.string} </div>
          </div>
        </div>
      </div>
      <div className="bg-white rounded  px-1 border"> {"Trash"->React.string} </div>
    </div>
    <div className="flex flex-row gap-2">
      <button
        onClick={_ => setProjectTab(_ => All)}
        className={[
          "w-20 rounded",
          projectsTab == All ? "bg-slate-800 text-white" : "bg-slate-200 text-black",
        ]->Array.join(" ")}>
        {"All"->React.string}
      </button>
      <button
        onClick={_ => setProjectTab(_ => Active)}
        className={[
          "w-20 rounded",
          projectsTab == Active ? "bg-slate-800 text-white" : "bg-slate-200 text-black",
        ]->Array.join(" ")}>
        {"Active"->React.string}
      </button>
    </div>
    <div>
      {projects
      ->Array.filter(project => projectsTab == Active ? project.isActive : true)
      ->Array.map(project =>
        <Project
          showArchive={showArchive->Array.includes(project.id)}
          setShowArchive={setShowArchive}
          project
          todos={todos->Array.filter(todo => todo.project == project.id)}
          updateProject
        />
      )
      ->React.array}
    </div>
  </div>
}

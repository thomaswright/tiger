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
    status: LaterUnsorted,
  },
  {
    text: "Do Something Else",
    project: "1",
    id: "2",
    isDone: false,
    status: ArchiveNoNeed,
  },
]

// let filterMap = (m, f) => m ->
// Map.entries -> Array.fromIterator -> Array.filter(f) -> Map.fromArray

// let mapToArray = m => m ->
// Map.entries -> Array.fromIterator

module StatusSelector = {
  @react.component
  let make = () => {
    <div className="text-xs w-[200px] bg-white p-2 flex flex-col gap-1 border rounded-lg ">
      <div className="flex flex-row justify-between gap-1 py-1">
        <div className="flex flex-row gap-1 flex-1 px-1">
          <div
            className="flex-none px-1 font-bold w-2 leading-none text-2xs flex flex-row items-center justify-center -rotate-90">
            {"Todo"->React.string}
          </div>
          <div className="flex flex-col flex-1 divide-y border rounded overflow-hidden">
            <div className="flex-1 px-1 bg-white "> {"Urgent"->React.string} </div>
            <div className="flex-1 px-1 bg-white "> {"High"->React.string} </div>
            <div className="flex-1 px-1 bg-white "> {"Medium"->React.string} </div>
            <div className="flex-1 px-1 bg-white "> {"Low"->React.string} </div>
          </div>
        </div>
        <div className="flex flex-row gap-1 flex-1 px-1">
          <div
            className="flex-none px-1 font-bold w-2 leading-none text-2xs flex flex-row items-center justify-center -rotate-90">
            {"Later"->React.string}
          </div>
          <div className="flex flex-col flex-1 divide-y border rounded overflow-hidden">
            <div className="flex-1 px-1 bg-white "> {"Will "->React.string} </div>
            <div className="flex-1 px-1 bg-white "> {"Maybe"->React.string} </div>
            <div className="flex-1 px-1 bg-white "> {"Unlikely"->React.string} </div>
            <div className="flex-1 px-1 bg-white "> {"Unsorted"->React.string} </div>
          </div>
        </div>
      </div>
      <div className="flex flex-row justify-between gap-1 py-1">
        <div className="flex flex-row gap-1 flex-1 px-1 ">
          <div
            className="flex-none px-1 font-bold w-2 leading-none text-2xs flex flex-row items-center justify-center -rotate-90">
            {"Resolve"->React.string}
          </div>
          <div className="flex flex-col flex-1 divide-y border rounded overflow-hidden">
            <div className="flex-1 px-1 bg-white "> {"Done"->React.string} </div>
            <div className="flex-1 px-1 bg-white "> {"Wont Do"->React.string} </div>
            <div className="flex-1 px-1 bg-white "> {"No Need"->React.string} </div>
          </div>
        </div>
        <div className=" flex flex-row gap-1 flex-1 px-1 ">
          <div
            className="flex-none px-1 font-bold w-2 leading-none text-2xs flex flex-row items-center justify-center -rotate-90">
            {"Archive"->React.string}
          </div>
          <div className="flex flex-col flex-1 divide-y border rounded overflow-hidden">
            <div className="flex-1 px-1 bg-white "> {"Done"->React.string} </div>
            <div className="flex-1 px-1 bg-white "> {"Wont Do"->React.string} </div>
            <div className="flex-1 px-1 bg-white "> {"No Need"->React.string} </div>
          </div>
        </div>
      </div>
      <div className="flex flex-row justify-between gap-1  pl-4 pr-1">
        <div className="bg-white rounded  px-1 border flex-1"> {"Trash"->React.string} </div>
      </div>
    </div>
  }
}

module Details = {
  @react.component
  let make = () => {
    <div className=" border-l flex-1"> {"Details"->React.string} </div>
  }
}

@react.component
let make = () => {
  let (projects, setProjects, _) = Common.useLocalStorage("projects", defaultProjects)
  let (todos, setTodos, _) = Common.useLocalStorage("todos", defaultTodos)
  let (showArchive, setShowArchive, _) = Common.useLocalStorage("showArchive", [])
  let (projectsTab, setProjectTab, _) = Common.useLocalStorage("projectsTab", All)
  let updateProject = React.useCallback0((id, f) => {
    setProjects(v => v->Array.map(project => project.id == id ? f(project) : project))
  })

  <div className="flex flex-row h-dvh">
    // <StatusSelector />
    <div className="flex-1">
      <div className="flex flex-row gap-2">
        <button
          onClick={_ => setProjectTab(_ => All)}
          className={[
            "w-20  border-b-2",
            projectsTab == All ? "border-red-500 text-red-500" : "border-transparent ",
          ]->Array.join(" ")}>
          {"All"->React.string}
        </button>
        <button
          onClick={_ => setProjectTab(_ => Active)}
          className={[
            "w-20  border-b-2",
            projectsTab == Active ? "border-red-500 text-red-500" : "border-transparent ",
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
    <Details />
  </div>
}

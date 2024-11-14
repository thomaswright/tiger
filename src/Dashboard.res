open Webapi.Dom
open Common
open Types

@react.component
let make = (
  ~todos: array<todoRelation>,
  ~projectsToHide: array<string>,
  ~setProjectsToHide: (array<string> => array<string>) => unit,
  ~allProjects: array<todo>,
  ~logout: unit => unit,
) => {
  let (selectedElement, setSelectedElement, _) = useSessionStorage(
    StorageKeys.selectedElement,
    None,
  )
  let (displayElement, setDisplayElement, _) = useSessionStorage(StorageKeys.displayElement, None)
  let (view, setView, _) = useSessionStorage(StorageKeys.view, Some(Settings))
  let (showCheckboxes, setShowCheckboxes, _) = useSessionStorage(StorageKeys.showCheckboxes, false)

  let (checked, setChecked) = React.useState(() => SSet.empty)

  let (focusClassNext, setFocusClassNext) = React.useState(_ => None)
  let (focusIdNext, setFocusIdNext) = React.useState(_ => None)

  let aaParentRef: React.ref<RescriptCore.Nullable.t<Dom.element>> = React.useRef(Nullable.null)

  let (baseColor, setBaseColor, _) = Common.useLocalStorage(
    StorageKeys.baseColor,
    "var(--blueBase)",
  )

  React.useEffect1(() => {
    Common.setRootStyleProperty("--tBase", baseColor)

    None
  }, [baseColor])

  React.useEffectOnEveryRender(() => {
    focusClassNext
    ->Option.flatMap(x =>
      Webapi.Dom.document
      ->Document.getElementsByClassName(x)
      ->HtmlCollection.toArray
      ->Array.get(0)
    )
    ->Option.mapOr((), element => {
      element->Obj.magic->HtmlElement.focus
      setFocusClassNext(_ => None)
    })

    focusIdNext
    ->Option.flatMap(x => Webapi.Dom.document->Document.getElementById(x))
    ->Option.mapOr((), element => {
      element->Obj.magic->HtmlElement.focus
      setFocusIdNext(_ => None)
    })

    None
  })

  <div
    className="flex flex-col-reverse justify-end sm:justify-start sm:flex-row  text-[var(--t10)] h-dvh">
    <div className="flex-1 flex flex-col overflow-hidden sm:h-full border-t sm:border-t-0">
      <div
        className="flex-none flex flex-row gap-2 justify-between items-center w-full h-10 border-b border-[var(--t3)] px-2">
        // <CheckedSummary checked={checked} projects={projects} setChecked={setChecked} setProjects />
        <button
          className="px-2 bg-[var(--t2)] rounded text-sm h-5"
          onClick={_ => {
            setShowCheckboxes(v => !v)
            if showCheckboxes {
              setChecked(_ => SSet.empty)
            }
          }}>
          {"Show Checkboxes"->React.string}
        </button>
        <div className="flex flex-row items-center justify-center gap-2">
          <button
            className="px-2 bg-[var(--t2)] rounded text-sm h-5"
            onClick={_ => {
              let newId = addTodo(
                "",
                Null,
                todos->Array.get(0)->Option.mapOr(0., t => t.self.position) +. 1.,
              )
              setFocusIdNext(_ => Some(getTodoInputId(newId)))
            }}>
            {"New Project"->React.string}
          </button>
        </div>
      </div>
      <ul className="pb-20 flex-1 overflow-y-scroll" ref={ReactDOM.Ref.domRef(aaParentRef)}>
        {todos
        ->Array.map(todoRelation => {
          <Todo
            key={todoRelation.self.id}
            getTodos={_ => todos}
            todoRelation={todoRelation}
            isSelected={selectedElement == Some(todoRelation.self.id)}
            setSelectedElement
            isDisplayElement={displayElement == Some(todoRelation.self.id)}
            setDisplayElement
            showCheckboxes
            setFocusIdNext
            isChecked={checked->SSet.has(todoRelation.self.id)}
            setChecked
            itemToMoveHandleMouseDown={(_, _) => ()}
            itemToMoveHandleMouseEnter={(_, _, _) => ()}
          />
        })
        ->React.array}
      </ul>
    </div>
    <div
      className=" border-l border-[var(--t3)] flex-none h-60 sticky sm:static sm:flex-1 bg-white top-0 flex flex-col overflow-hidden sm:h-full">
      <div
        className="flex-none flex flex-row gap-2 justify-between items-center w-full h-10 border-b border-[var(--t3)] px-2">
        <button
          className="px-2 bg-[var(--t2)] rounded text-sm h-5"
          onClick={_ => {
            setView(_ => Some(ProjectList))
            setDisplayElement(_ => None)
            setSelectedElement(_ => None)
          }}>
          {"Toggle Projects"->React.string}
        </button>
        <div className="flex-1" />
        <button
          onClick={_ => {
            setView(_ => Some(Settings))
            setDisplayElement(_ => None)
            setSelectedElement(_ => None)
          }}>
          <img src={Common.logoUrl} width={"24"} className="py-0.5 " />
        </button>
      </div>
      {if displayElement->Option.isSome || selectedElement->Option.isSome {
        <React.Fragment>
          {switch displayElement {
          | Some(todoId) =>
            todos
            ->Array.find(t => t.self.id == todoId)
            ->Option.mapOr(React.null, todoRelation => {
              <DisplayTodo todoRelation setFocusIdNext />
            })
          | _ => React.null
          }}
        </React.Fragment>
      } else {
        switch view {
        | Some(Settings) =>
          <Settings onExportJson={_ => ()} onImportJson={_ => ()} setBaseColor logout />
        | Some(ProjectList) =>
          <div>
            <div className="flex flex-row gap-1 p-2">
              <button
                className="px-2 bg-[var(--t2)] rounded text-sm h-5"
                onClick={_ => setProjectsToHide(_ => [])}>
                {"Show All"->React.string}
              </button>
              <button
                className="px-2 bg-[var(--t2)] rounded text-sm h-5"
                onClick={_ => setProjectsToHide(_ => allProjects->Array.map(x => x.id))}>
                {"Hide All"->React.string}
              </button>
            </div>
            <div className="flex flex-col p-2 gap-1 cursor-pointer">
              {allProjects
              ->Array.map(todo => {
                let isHidden = projectsToHide->Array.includes(todo.id)
                <div
                  className={[
                    isHidden ? "" : "bg-[var(--t2)]",
                    "text-sm px-2 min-h-6 max-w-80 flex flex-row items-center rounded",
                  ]->Array.join(" ")}
                  onClick={_ =>
                    setProjectsToHide(v =>
                      v->Array.includes(todo.id)
                        ? v->Array.filter(x => x != todo.id)
                        : v->Array.concat([todo.id])
                    )}>
                  {todo.text->Nullable.toOption->Option.getOr("")->React.string}
                </div>
              })
              ->React.array}
            </div>
          </div>

        | None => React.null
        }
      }}
    </div>
  </div>
}

let make = observer(make)

let default = make

// <button
//   onClick={_ => {
//     let newProjectId = Common.uuid()
//     let newProject = {
//       id: newProjectId,
//       name: "",
//       additionalText: "",
//       isActive: true,
//       todos: [],
//       hiddenTodos: SMap.empty,
//       hideArchived: false,
//       hideAll: false,
//     }
//     setProjects(v => {
//       let relativeProject = switch displayElement {
//       | Some(Project(projectId)) => Some(projectId)
//       | Some(Todo(todoId)) =>
//         v->Array.reduce(None, (a, c) => {
//           a->Option.isSome
//             ? a
//             : c.todos->Array.find(t => t.id == todoId)->Option.isSome
//             ? Some(c.id)
//             : None
//         })
//       | _ => None
//       }
//       relativeProject->Option.mapOr(Array.concat([newProject], v), relativeProject =>
//         v->Array.reduce(
//           [],
//           (a, c) => {
//             c.id == relativeProject
//               ? a->Array.concat([c])->Array.concat([newProject])
//               : a->Array.concat([c])
//           },
//         )
//       )
//     })
//     setSelectedElement(_ => Some(Project(newProjectId)))
//     setDisplayElement(_ => Some(Project(newProjectId)))
//     setFocusIdNext(_ => Some(getProjectInputId(newProjectId)))
//   }}
//   className={[
//     "bg-[var(--t2)] px-2 rounded text-xs flex flex-row items-center gap-1 h-5 ",
//   ]->Array.join(" ")}>
//   <Icons.Plus />
//   {"Project"->React.string}
// </button>
// <button
//   onClick={_ =>
//     setProjects(projects =>
//       projects->Array.map(p => handleHide(true, Some(allProjectsHidden), p))
//     )}
//   className={[
//     "rounded flex flex-row items-center justify-center gap-1 h-5 w-5 text-[var(--t6)] ",
//   ]->Array.join(" ")}>
//   {allProjectsHidden ? <Icons.ChevronDown /> : <Icons.ChevronUp />}
// </button>

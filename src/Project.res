open Types
open Webapi.Dom
open Common

@react.component
let make = (
  ~project: project,
  ~updateProject,
  ~selectedElement,
  ~setSelectedElement,
  ~setDisplayElement,
  ~itemToMoveHandleMouseEnter,
  ~projectToMoveHandleMouseDown,
  ~projectToMoveHandleMouseEnter,
  ~handleHide,
  ~newTodoAfter,
) => {
  let projectRef = React.useRef(Nullable.null)
  let inputRef = React.useRef(Nullable.null)

  let isSelected = selectedElement == Some(Project(project.id))

  let onKeyDownProject = e => {
    if isSelected {
      projectRef.current->mapNullable(dom => {
        if e->ReactEvent.Keyboard.key == "ArrowUp" {
          e->ReactEvent.Keyboard.preventDefault
          Common.focusPreviousClass(listItemClass, dom)
        }

        if e->ReactEvent.Keyboard.key == "ArrowDown" {
          e->ReactEvent.Keyboard.preventDefault
          Common.focusNextClass(listItemClass, dom)
        }

        if e->ReactEvent.Keyboard.key == "Backspace" && e->ReactEvent.Keyboard.metaKey {
          projectRef.current->mapNullable(containerEl => {
            Common.focusPreviousClass(listItemClass, containerEl)
          })
        }

        if e->ReactEvent.Keyboard.key == "Enter" && e->ReactEvent.Keyboard.metaKey {
          newTodoAfter(None, None)
        }

        if e->ReactEvent.Keyboard.key == "Enter" {
          e->ReactEvent.Keyboard.preventDefault
          inputRef.current->mapNullable(inputEl => {
            let inputEl = inputEl->Obj.magic
            inputEl->HtmlElement.focus
            inputEl->HtmlInputElement.setSelectionStart(inputEl->HtmlInputElement.selectionEnd)
          })
        }

        if e->ReactEvent.Keyboard.key == "Escape" {
          // e->ReactEvent.Keyboard.preventDefault // ?
          setSelectedElement(_ => None)
          setDisplayElement(_ => None)

          dom->Obj.magic->HtmlElement.blur
        }
      })
    }
  }

  let onKeyDownInput = e => {
    if isSelected {
      if e->ReactEvent.Keyboard.key == "Escape" {
        // e->ReactEvent.Keyboard.preventDefault // ?
        e->ReactEvent.Keyboard.stopPropagation
        projectRef.current->mapNullable(dom => {
          dom->Obj.magic->HtmlElement.focus
        })
      }

      inputRef.current->mapNullable(dom => {
        let cursorPosition = dom->Obj.magic->HtmlInputElement.selectionStart->Option.getOr(0)
        let inputValueLength = dom->Obj.magic->HtmlInputElement.value->String.length

        if e->ReactEvent.Keyboard.key == "ArrowUp" {
          e->ReactEvent.Keyboard.stopPropagation
          if cursorPosition == 0 {
            e->ReactEvent.Keyboard.preventDefault
            // Common.focusPreviousClass(todoInputClass, dom)
            projectRef.current->mapNullable(dom => {
              dom->Obj.magic->HtmlElement.focus
            })
          }
        }

        if e->ReactEvent.Keyboard.key == "ArrowDown" {
          e->ReactEvent.Keyboard.stopPropagation
          if cursorPosition == inputValueLength {
            e->ReactEvent.Keyboard.preventDefault
            // Common.focusNextClass(todoInputClass, dom)
            projectRef.current->mapNullable(dom => {
              dom->Obj.magic->HtmlElement.focus
            })
          }
        }

        if e->ReactEvent.Keyboard.key == "Enter" && cursorPosition == inputValueLength {
          e->ReactEvent.Keyboard.stopPropagation
          e->ReactEvent.Keyboard.preventDefault
          newTodoAfter(None, None)

          // projectRef.current->mapNullable(dom => {
          //   dom->Obj.magic->HtmlElement.focus
          // })
        }
      })
    }
  }

  let handleHideAll = _ => updateProject(project.id, p => handleHide(true, None, p))
  // let handleHideArchived = _ => updateProject(project.id, p => handleHide(false, None, p))

  <li
    key={getProjectId(project.id)}
    id={getProjectId(project.id)}
    tabIndex={0}
    ref={ReactDOM.Ref.domRef(projectRef)}
    onKeyDown={onKeyDownProject}
    onBlur={_ => setSelectedElement(_ => None)}
    onFocus={_ => {
      setSelectedElement(_ => Some(Project(project.id)))
      setDisplayElement(_ => Some(Project(project.id)))
    }}
    onMouseEnter={e => {
      projectToMoveHandleMouseEnter(project.id, e)
      itemToMoveHandleMouseEnter(true, project.id, e)
    }}
    className={[
      listItemClass,
      "first:mt-1 mt-2",
      "relative group  flex flex-row justify-between items-center bg-[var(--t0)] px-1 text-[var(--t10)]
        gap-1 border-b-[var(--t3)] border-t-[var(--t9)]",
      isSelected
        ? "outline outline-2 -outline-offset-2 outline-purple-500 focus:outline-blue-500"
        : "",
    ]->Array.join(" ")}>
    <Common.TextareaAutosize
      id={getProjectInputId(project.id)}
      style={{resize: "none"}}
      ref={ReactDOM.Ref.domRef(inputRef)}
      className={[
        todoInputClass,
        "ml-1 my-1 block text-lg font-black tracking-tight  w-full border-0 px-0 py-0 focus:ring-0 
               leading-none bg-transparent",
      ]->Array.join(" ")}
      placeholder={""}
      value={project.name}
      onBlur={_ => setSelectedElement(_ => None)}
      onFocus={_ => {
        setSelectedElement(_ => Some(Todo(project.id)))
        setDisplayElement(_ => Some(Todo(project.id)))
      }}
      onKeyDown={onKeyDownInput}
      onChange={e => {
        updateProject(project.id, t => {
          ...t,
          name: ReactEvent.Form.target(e)["value"],
        })
      }}
    />
    <div
      onMouseDown={e => projectToMoveHandleMouseDown(project.id, e)}
      className={[
        project.hideAll ? "right-8" : "right-[72px]",
        "absolute w-4 h-4 text-[var(--t4)] hidden group-hover:block bg-[var(--t0)] rounded-sm ",
      ]->Array.join(" ")}>
      <Icons.DragDrop />
    </div>
    {project.hideAll
      ? React.null
      : <button
          onClick={_ => {
            newTodoAfter(None, None)
          }}
          className="absolute right-10 hidden group-hover:block h-4 w-4 text-sm rounded flex-none text-[var(--t4)] bg-[var(--t0)] ">
          <Icons.Plus />
        </button>}
    // {project.hideAll
    //   ? React.null
    //   : <button
    //       className="text-sm rounded h-4 w-4 flex-none font-mono flex flex-row justify-center items-center text-[var(--t6)] mr-1"
    //       onClick={handleHideArchived}>
    //       {project.hideArchived ? <Icons.ArchiveOff /> : <Icons.Archive />}
    //       // {showArchive
    //       //   ? <span className="line-through"> {"closed"->React.string} </span>
    //       //   : <span> {"closed"->React.string} </span>}
    //     </button>}
    <button
      className="text-sm rounded h-4 w-4 flex-none font-mono flex flex-row justify-center items-center text-[var(--t6)] mr-1"
      onClick={handleHideAll}>
      {project.hideAll ? <Icons.ChevronDown /> : <Icons.ChevronUp />}
    </button>
  </li>
}

open Types
open Webapi.Dom
open Common

@react.component
let make = (
  ~project: project,
  ~todo: todo,
  ~updateTodo: (string, string, Types.todo => Types.todo) => unit,
  ~isSelected: bool,
  ~setSelectedElement: (option<Types.selectElement> => option<Types.selectElement>) => unit,
  ~isDisplayElement: bool,
  ~setDisplayElement: (option<Types.selectElement> => option<Types.selectElement>) => unit,
  ~setTodos: (string, array<Types.todo> => array<Types.todo>) => unit,
  ~setFocusIdNext: (option<string> => option<string>) => unit,
  ~newTodoAfter: (option<string>, option<string>) => unit,
  ~getTodos: unit => array<todo>,
  ~isChecked: bool,
  ~setChecked: (Types.SSet.t => Types.SSet.t) => unit,
  ~deleteTodo: (string, Types.todo) => unit,
  ~hasHiddenTodos: bool,
  ~itemToMoveHandleMouseDown: (string, JsxEventU.Mouse.t) => unit,
  ~itemToMoveHandleMouseEnter: (bool, string, JsxEventU.Mouse.t) => unit,
  ~clearProjectLastRelative: unit => unit,
) => {
  let (statusSelectIsOpen, setStatusSelectIsOpen) = React.useState(() => false)
  let inputRef = React.useRef(Nullable.null)
  let containerRef = React.useRef(Nullable.null)

  let (stagedForDelete, setStagedForDelete) = React.useState(_ => false)
  let focusContainer = () => {
    containerRef.current->mapNullable(dom => {
      dom->Obj.magic->HtmlElement.focus
    })
  }
  // let clickDelayTimeout = React.useRef(None)
  // let onCheckboxMouseDown = e => {
  //   let timeoutId = setTimeout(() => {
  //     focusContainer()
  //     itemToMoveHandleMouseDown(todo.id, e)
  //   }, 500)
  //   clickDelayTimeout.current = timeoutId->Some
  // }

  // let onCheckboxMouseUp = _ => {
  //   clickDelayTimeout.current->Option.mapOr((), timeoutId => clearTimeout(timeoutId))
  // }

  let indentation = e => {
    if e->ReactEvent.Keyboard.key == "Tab" {
      e->ReactEvent.Keyboard.preventDefault
    }

    // Indents
    if (
      ((e->ReactEvent.Keyboard.key == "Tab" && !(e->ReactEvent.Keyboard.shiftKey)) ||
        (e->ReactEvent.Keyboard.key == "]" && e->ReactEvent.Keyboard.metaKey)) &&
        todo.childNumber->Option.mapOr(false, childNumber => childNumber != 0)
    ) {
      e->ReactEvent.Keyboard.preventDefault

      let todos = getTodos()
      let newParent =
        todos->Array.find(t =>
          t.parentTodo == todo.parentTodo &&
            t.childNumber == todo.childNumber->Option.map(c => c - 1)
        )
      setTodos(project.id, todos =>
        todos->Array.map(t => {
          if t.id == todo.id {
            {
              ...t,
              parentTodo: newParent->Option.map(t => t.id),
            }
          } else if t.parentTodo == Some(todo.id) {
            {
              ...t,
              parentTodo: newParent->Option.map(t => t.id),
            }
          } else {
            t
          }
        })
      )
    }

    // De Indents
    if (
      ((e->ReactEvent.Keyboard.key == "Tab" && e->ReactEvent.Keyboard.shiftKey) ||
        (e->ReactEvent.Keyboard.key == "[" && e->ReactEvent.Keyboard.metaKey)) &&
        todo.parentTodo != None
    ) {
      e->ReactEvent.Keyboard.preventDefault

      let todos = getTodos()
      let todoIndex = todos->Array.findIndex(t => t.id == todo.id)
      let todosGoingBack = todos->Array.slice(~start=0, ~end=todoIndex)->Array.toReversed
      let todosGoingForward = todos->Array.sliceToEnd(~start=todoIndex + 1)

      todo.depth->Option.mapOr((), todoDepth => {
        let newChildren = ref([])
        let break = ref(false)
        let i = ref(0)
        while !break.contents && i.contents < todosGoingForward->Array.length {
          let t = todosGoingForward->Array.getUnsafe(i.contents)
          if t.depth->Option.mapOr(false, d => d < todoDepth) {
            break := true
          } else {
            if t.depth->Option.mapOr(false, d => d == todoDepth) {
              newChildren := newChildren.contents->Array.concat([t.id])
            }
            i := i.contents + 1
          }
        }

        let newParent =
          todosGoingBack
          ->Array.find(t => t.depth == Some(todoDepth - 2))
          ->Option.map(t => t.id)

        setTodos(project.id, todos => {
          todos->Array.map(
            t => {
              if t.id == todo.id {
                {
                  ...t,
                  parentTodo: newParent,
                }
              } else if newChildren.contents->Array.includes(t.id) {
                {
                  ...t,
                  parentTodo: Some(todo.id),
                }
              } else {
                t
              }
            },
          )
        })
      })
    }
  }

  let onKeyDownContainer = e => {
    open ReactEvent.Keyboard
    if (
      isSelected &&
      containerRef.current->Nullable.toOption == Webapi.Dom.document->Document.activeElement
    ) {
      containerRef.current->mapNullable(dom => {
        indentation(e)
        if e->key == "s" {
          e->preventDefault
          setStatusSelectIsOpen(_ => true)
        }

        if e->key == "ArrowUp" {
          e->preventDefault
          Common.focusPreviousClass(listItemClass, dom)
        }

        if e->key == "ArrowDown" {
          e->preventDefault
          Common.focusNextClass(listItemClass, dom)
        }

        if e->key == "Backspace" && e->metaKey {
          deleteTodo(project.id, todo)

          containerRef.current->mapNullable(containerEl => {
            Common.focusPreviousClass(listItemClass, containerEl)
          })
        }

        if e->key == "Backspace" && !(e->metaKey) {
          if stagedForDelete {
            deleteTodo(project.id, todo)

            containerRef.current->mapNullable(containerEl => {
              Common.focusPreviousClass(listItemClass, containerEl)
            })
          } else {
            setStagedForDelete(_ => true)
          }
        }

        if e->key == "Enter" && e->metaKey {
          newTodoAfter(Some(todo.id), todo.hasChildren ? Some(todo.id) : todo.parentTodo)
        }

        if e->key == "Enter" {
          e->preventDefault
          inputRef.current->mapNullable(inputEl => {
            let inputEl = inputEl->Obj.magic
            inputEl->HtmlElement.focus
            inputEl->HtmlInputElement.setSelectionStart(inputEl->HtmlInputElement.selectionEnd)
          })
        }

        if e->key == "Escape" {
          if stagedForDelete {
            setStagedForDelete(_ => false)
          } else {
            // e->preventDefault // ?
            setSelectedElement(_ => None)
            setDisplayElement(_ => None)

            dom->Obj.magic->HtmlElement.blur
          }
        }
      })
    }
  }

  let onKeyDownInput = e => {
    open ReactEvent.Keyboard

    setStagedForDelete(_ => false)

    if isSelected {
      if e->key == "Escape" {
        // e->preventDefault // ?
        e->stopPropagation

        focusContainer()
      }

      inputRef.current->mapNullable(dom => {
        indentation(e)

        let cursorPosition = dom->Obj.magic->HtmlInputElement.selectionStart->Option.getOr(0)
        let inputValueLength = dom->Obj.magic->HtmlInputElement.value->String.length

        if e->key == "ArrowUp" {
          e->stopPropagation
          if cursorPosition == 0 {
            e->preventDefault
            // Common.focusPreviousClass(todoInputClass, dom)
            focusContainer()
          }
        }

        if e->key == "ArrowDown" {
          e->stopPropagation
          if cursorPosition == inputValueLength {
            e->preventDefault
            // Common.focusNextClass(todoInputClass, dom)
            focusContainer()
          }
        }

        if e->key == "Backspace" && inputValueLength == 0 {
          if stagedForDelete {
            deleteTodo(project.id, todo)

            containerRef.current->mapNullable(containerEl => {
              Common.focusPreviousClass(listItemClass, containerEl)
            })
          } else {
            setStagedForDelete(_ => true)
          }
        }

        if e->key == "Enter" && cursorPosition == inputValueLength {
          e->preventDefault
          e->stopPropagation
          newTodoAfter(Some(todo.id), todo.hasChildren ? Some(todo.id) : todo.parentTodo)
        }
      })
    }
  }

  <li
    id={getTodoId(todo.id)}
    tabIndex={0}
    ref={ReactDOM.Ref.domRef(containerRef)}
    onBlur={_ => {
      setSelectedElement(_ => None)
      setStagedForDelete(_ => false)
    }}
    onFocus={_ => {
      setSelectedElement(_ => Some(Todo(todo.id)))
      setDisplayElement(_ => Some(Todo(todo.id)))
    }}
    onKeyDown={onKeyDownContainer}
    onMouseEnter={e => {
      clearProjectLastRelative()
      itemToMoveHandleMouseEnter(false, todo.id, e)
    }}
    className={[
      listItemClass,
      "group flex flex-row justify-start items-center outline-none  pl-1",
    ]->Array.join(" ")}>
    {Array.make(~length=todo.depth->Option.getOr(0), false)
    ->Array.mapWithIndex((_, i) => {
      <div key={i->Int.toString} className="self-stretch w-2 border-l ml-2 border-[var(--t3)] " />
    })
    ->React.array}
    <div
      className={[
        "group flex flex-row justify-start items-center h-full flex-1 pl-1 rounded-sm",
        stagedForDelete
          ? "outline-red-700 dark:outline-red-500"
          : "focus-within:outline-purple-500 outline-blue-500 ",
        stagedForDelete
          ? "bg-red-200 dark:bg-red-950"
          : isChecked
          ? "bg-sky-50 dark:bg-sky-950"
          : isDisplayElement && !isSelected
          ? "bg-sky-200 dark:bg-sky-900"
          : "",
        isSelected ? "outline outline-2 -outline-offset-2 " : "",
      ]->Array.join(" ")}>
      <Common.StatusSelect
        isOpen={statusSelectIsOpen}
        onOpenChange={v => {
          if !v {
            setStatusSelectIsOpen(_ => v)
          } else {
            setStatusSelectIsOpen(_ => v)
          }
        }}
        status={Some(todo.status)}
        focusTodo={() => {
          // this isn't set directly because the "Enter"
          // will then fire on the container then focusing
          // the input *shrugs*
          setFocusIdNext(_ => Some(getTodoId(todo.id)))
        }}
        setStatus={newStatus =>
          updateTodo(project.id, todo.id, t => {
            ...t,
            status: newStatus,
            // box: t.box == Archive && !(newStatus->statusIsResolved) ? Working : t.box,
          })}
      />
      <div
        className={[
          "relative flex-1 ml-1 flex flex-row h-full justify-start items-center ",
        ]->Array.join(" ")}>
        {if hasHiddenTodos {
          <div
            className="absolute  text-[var(--darkPurple)] bg-[var(--lightPurple)] 
              text-xs h-3 w-3 -left-3 -top-0 flex flex-row items-center justify-center rounded-full">
            <Icons.Archive />
          </div>
        } else {
          React.null
        }}
        {isSelected || isDisplayElement
          ? React.null
          : <div className="h-px w-full absolute bg-[var(--t2)] -bottom-0" />}
        <Common.TextareaAutosize
          id={getTodoInputId(todo.id)}
          ref={ReactDOM.Ref.domRef(inputRef)}
          className={[
            todoInputClass,
            "mx-1 my-1 block text-sm font-medium  w-full h-5 border-0 pl-0 py-0 focus:ring-0 focus:z-10 text-[var(--t10)]",
            stagedForDelete
              ? "bg-red-200 dark:bg-red-950"
              : isChecked
              ? "bg-sky-50 dark:bg-sky-950"
              : isDisplayElement && !isSelected
              ? "bg-sky-200 dark:bg-sky-900"
              : "bg-[var(--t0)]",
          ]->Array.join(" ")}
          placeholder={""}
          style={{resize: "none"}}
          value={todo.text}
          onBlur={_ => setSelectedElement(_ => None)}
          onFocus={_ => {
            setSelectedElement(_ => Some(Todo(todo.id)))
            setDisplayElement(_ => Some(Todo(todo.id)))
          }}
          onKeyDown={onKeyDownInput}
          // onMouseDown={onInputMouseDown}
          // onMouseUp={onInputMouseUp}
          onChange={e => {
            updateTodo(project.id, todo.id, t => {
              ...t,
              text: ReactEvent.Form.target(e)["value"],
            })
          }}
        />
        <Common.DateSelect
          className="mr-1 ml-1"
          value={todo.targetDate->Option.map(Date.fromString)}
          onClick={newDate =>
            updateTodo(project.id, todo.id, t => {
              ...t,
              targetDate: newDate->Option.map(Date.toString),
            })}
        />
        <div
          className={[
            "cursor-default absolute right-10 flex-row items-center gap-3 pr-2 h-full",
            isChecked ? "flex" : " hidden group-hover:flex",
          ]->Array.join(" ")}>
          <div
            onMouseDown={e => itemToMoveHandleMouseDown(todo.id, e)}
            className={" w-4 h-4 text-[var(--t4)] hidden group-hover:block bg-[var(--t0)] rounded-sm 0 "}>
            <Icons.DragDrop />
          </div>
          // <button
          //   className={[
          //     "w-4 h-4 flex-row items-center justify-center cursor-default
          //     hidden group-hover:flex rounded-sm text-sm text-[var(--t6)]  bg-[var(--t0)] ",
          //   ]->Array.join(" ")}
          //   onClick={_ => {
          //     newTodoAfter(Some(todo.id), Some(todo.id))
          //   }}>
          //   <Icons.Plus />
          // </button>
          <input
            onChange={_ => {
              setChecked(v => v->SSet.has(todo.id) ? v->SSet.remove(todo.id) : v->SSet.add(todo.id))
            }}
            checked={isChecked}
            type_={"checkbox"}
            className={[
              "border-[var(--t4)] bg-[var(--t0)] rounded text-blue-400 dark:text-blue-800 w-4 h-4 focus:ring-offset-0 focus:ring-blue-500",
            ]->Array.join(" ")}
          />
        </div>
      </div>

      // <button
      //   onClick={_ => {
      //     setDatePickerOpen(v => !v)
      //     // datePickerRef.current->mapNullable(datePickerEl => {
      //     //   Console.log("click")
      //     //   datePickerEl->Obj.magic->HtmlFormElement.click
      //     // })
      //   }}
      //   className="w-12 h-6 rounded bg-[var(--t2)]">
      //   {todo.targetDate->Option.mapOr(""->React.string, targetDate => {
      //     targetDate->Date.toDateString->React.string
      //   })}
      // </button>
    </div>
  </li>
}

let make = React.memoCustomCompareProps(make, (a, b) => {
  a.hasHiddenTodos == b.hasHiddenTodos &&
  a.project.id == b.project.id &&
  a.isSelected == b.isSelected &&
  a.isDisplayElement == b.isDisplayElement &&
  a.isChecked == b.isChecked &&
  a.todo.text == b.todo.text &&
  a.todo.additionalText == b.todo.additionalText &&
  a.todo.project == b.todo.project &&
  a.todo.status == b.todo.status &&
  a.todo.parentTodo == b.todo.parentTodo &&
  a.todo.depth == b.todo.depth &&
  a.todo.childNumber == b.todo.childNumber &&
  a.todo.hasArchivedChildren == b.todo.hasArchivedChildren &&
  a.todo.hasChildren == b.todo.hasChildren &&
  a.todo.ancArchived == b.todo.ancArchived &&
  a.todo.targetDate == b.todo.targetDate
})

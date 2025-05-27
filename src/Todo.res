open Webapi.Dom
open Common
open Types

module TopCollapseControls = {
  @react.component
  let make = (~todo, ~todoRelation, ~todos) => {
    let someExpanded = todos->Array.some(v => {
      if v.depth == 1 {
        v.self.modes_shown->Array.length > 0
      } else {
        false
      }
    })
    <div className={"flex flex-row gap-2"}>
      {if todoRelation.hasStashedChildren {
        <button
          onClick={_ => {
            setTodoModesShown(todo.id, a => a->arrayToggle(Stashed))
          }}
          className={[
            todo.modes_shown->Array.includes(Stashed) ? "text-[var(--t7)]" : "text-[var(--t3)]",
            " flex flex-row items-center justify-center rounded ",
          ]->Array.join(" ")}>
          <Icons.Bookmark />
        </button>
      } else {
        React.null
      }}
      {if todoRelation.hasArchivedChildren {
        <button
          onClick={_ => {
            setTodoModesShown(todo.id, a => a->arrayToggle(Archive))
          }}
          className={[
            todo.modes_shown->Array.includes(Archive) ? " text-[var(--t7)]" : "text-[var(--t3)]",
            " flex flex-row items-center justify-center rounded",
          ]->Array.join(" ")}>
          <Icons.Archive />
        </button>
      } else {
        React.null
      }}
      {if !someExpanded {
        <button
          className="mr-4 text-[var(--t5)] text-sm"
          onClick={_ =>
            batch(() => {
              todos->Array.forEach(t => {
                setTodoModesShown(t.self.id, _ => [Working])
              })
            })}>
          <Icons.Minus />
        </button>
      } else {
        <button
          className="mr-4  text-[var(--t5)]  text-sm"
          onClick={_ =>
            batch(() => {
              todos->Array.forEach(t => {
                setTodoModesShown(t.self.id, _ => [])
              })
            })}>
          <Icons.ChevronDown />
        </button>
      }}
    </div>
  }
}

module CollapseControls = {
  @react.component
  let make = (~todo, ~todoRelation) => {
    if todoRelation.children->Array.length > 0 {
      <div className={"flex flex-row gap-2"}>
        {if todo.modes_shown->Array.length == 0 {
          <React.Fragment>
            <button
              className="mr-4 text-[var(--t5)]"
              onClick={_ => setTodoModesShown(todo.id, a => a->arrayToggle(Working))}>
              <Icons.ChevronDown />
            </button>
          </React.Fragment>
        } else {
          <React.Fragment>
            {if todoRelation.hasStashedChildren {
              <button
                onClick={_ => {
                  setTodoModesShown(todo.id, a => a->arrayToggle(Stashed))
                }}
                className={[
                  todo.modes_shown->Array.includes(Stashed)
                    ? "text-[var(--t7)]"
                    : "text-[var(--t3)]",
                  " flex flex-row items-center justify-center rounded ",
                ]->Array.join(" ")}>
                <Icons.Bookmark />
              </button>
            } else {
              React.null
            }}
            {if todoRelation.hasArchivedChildren {
              <button
                onClick={_ => {
                  setTodoModesShown(todo.id, a => a->arrayToggle(Archive))
                }}
                className={[
                  todo.modes_shown->Array.includes(Archive)
                    ? " text-[var(--t7)]"
                    : "text-[var(--t3)]",
                  " flex flex-row items-center justify-center rounded",
                ]->Array.join(" ")}>
                <Icons.Archive />
              </button>
            } else {
              React.null
            }}
            <button
              className="mr-4  text-[var(--t5)]" onClick={_ => setTodoModesShown(todo.id, _ => [])}>
              <Icons.Minus />
            </button>
          </React.Fragment>
        }}
      </div>
    } else {
      React.null
    }
  }
}

@react.component
let make = (
  ~todoRelation: todoRelation,
  ~getTodos as _: unit => array<todoRelation>,
  ~isSelected,
  ~setSelectedElement,
  ~isDisplayElement,
  ~setDisplayElement,
  ~showCheckboxes,
  ~setFocusIdNext,
  ~isChecked,
  ~setChecked,
  ~moveActive,
  // ~itemToMoveHandleMouseDown,
  // ~itemToMoveHandleMouseEnter as _,
  ~setDrag,
) => {
  let todo = todoRelation.self
  let (statusSelectIsOpen, setStatusSelectIsOpen) = React.useState(() => false)
  let (text, setText) = useDebounce(
    ~initialValue=todo.text->Nullable.toOption,
    ~onTrigger=v => v->Option.mapOr((), v_ => setTodoText(todo.id, v_)),
    ~delay=1000,
  )

  let (stagedForDelete, setStagedForDelete) = React.useState(_ => false)
  let inputRef = React.useRef(Nullable.null)
  let containerRef = React.useRef(Nullable.null)

  React.useEffect(() => {
    if inputRef.current->Nullable.toOption != Webapi.Dom.document->Document.activeElement {
      setText(_ => todo.text->Nullable.toOption)
    }

    None
  }, [todo.text])

  let focusContainer = () => {
    containerRef.current->mapNullable(dom => {
      dom->Obj.magic->HtmlElement.focus
    })
  }

  let indentation = e => {
    if e->ReactEvent.Keyboard.key == "Tab" {
      e->ReactEvent.Keyboard.preventDefault
    }

    // Indents
    if (
      (e->ReactEvent.Keyboard.key == "Tab" && !(e->ReactEvent.Keyboard.shiftKey)) ||
        (e->ReactEvent.Keyboard.key == "]" && e->ReactEvent.Keyboard.metaKey)
    ) {
      e->ReactEvent.Keyboard.preventDefault
      batch(() => {
        todoRelation.sibs
        ->Array.get(todoRelation.index - 1)
        ->Option.mapOr((), prevSib => {
          if prevSib.mode != todo.mode {
            ()
          } else {
            setTodoParent(todo.id, prevSib.id)
            setTodoModesShown(
              prevSib.id,
              modes => modes->Array.includes(Working) ? modes : [...modes, Working],
            )
            setTodoOrder(prevSib.id, order => Array.concat(order, [todo.id]))

            // todoRelation.children->Array.forEach(child => setTodoParent(child.id, prevSib.id))
          }
        })
      })
    }

    // De Indents
    if (
      ((e->ReactEvent.Keyboard.key == "Tab" && e->ReactEvent.Keyboard.shiftKey) ||
        (e->ReactEvent.Keyboard.key == "[" && e->ReactEvent.Keyboard.metaKey)) &&
        !(todo.parent_todo->Nullable.isNullable)
    ) {
      e->ReactEvent.Keyboard.preventDefault

      batch(() => {
        todoRelation.parent
        ->Nullable.toOption
        ->Option.mapOr((), parent => {
          parent.parent_todo
          ->Nullable.toOption
          ->Option.mapOr(
            (),
            grandParent => {
              setTodoParent(todo.id, grandParent)
              setTodoOrder(parent.id, order => order->Array.filter(v => v != todo.id))
              setTodoOrder(
                grandParent,
                order =>
                  order->Array.reduce(
                    [],
                    (a, c) => Array.concat(a, c == parent.id ? [c, todo.id] : [c]),
                  ),
              )
            },
          )
        })
      })
    }
  }

  let makeNewTodo = () => {
    if todoRelation.children->Array.length > 0 && todoRelation.self.modes_shown->Array.length > 0 {
      setTodoModesShown(todo.id, a => a->Array.includes(Working) ? a : Array.concat(a, [Working]))

      let newId = addTodo("", todo.id, (order, id) => Array.concat([id], order))
      setFocusIdNext(_ => Some(getTodoInputId(newId)))
    } else {
      todo.parent_todo
      ->Nullable.toOption
      ->Option.mapOr((), parent_todo => {
        let newId = addTodo("", parent_todo, (order, id) => {
          order->Array.reduce([], (a, c) => Array.concat(a, c == todo.id ? [c, id] : [c]))
        })
        setTodoMode(newId, todo.mode)
        setFocusIdNext(_ => Some(getTodoInputId(newId)))
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
        // indentation(e)
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
          deleteTodoAndMoveChildren(todoRelation)

          containerRef.current->mapNullable(containerEl => {
            Common.focusPreviousClass(listItemClass, containerEl)
          })
        }

        if e->key == "Backspace" && !(e->metaKey) {
          if stagedForDelete {
            deleteTodoAndMoveChildren(todoRelation)

            containerRef.current->mapNullable(containerEl => {
              Common.focusPreviousClass(listItemClass, containerEl)
            })
          } else {
            setStagedForDelete(_ => true)
          }
        }

        if e->key == "Enter" && e->metaKey {
          makeNewTodo()
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
          deleteTodoAndMoveChildren(todoRelation)

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
        makeNewTodo()
      }
    })
  }

  let statusSelect =
    <Common.StatusSelect
      hasHidden={todoRelation.hasHiddenChildren}
      isOpen={statusSelectIsOpen}
      onOpenChange={v => {
        setStatusSelectIsOpen(_ => v)
      }}
      // setOpen={v => setStatusSelectIsOpen(_ => v)}
      status={Some(todo.status)}
      mode={todo.mode}
      setMode={m => setTodoMode(todo.id, m)}
      focusTodo={() => {
        // this isn't set directly because the "Enter"
        // will then fire on the container then focusing
        // the input *shrugs*
        setFocusIdNext(_ => Some(getTodoId(todo.id)))
      }}
      setStatus={newStatus => setTodoStatus(todo.id, newStatus)}
      date={todo.target_date->Nullable.toOption->Option.map(Date.fromString)}
      setDate={newDate =>
        setTodoDate(
          todo.id,
          newDate
          ->Option.map(x =>
            x->DateFns.formatISOOpt({
              representation: "date"->Some,
              format: None,
            })
          )
          ->toNullableNull,
        )}
    />

  <React.Fragment>
    {switch todo.is_first_of_mode {
    | Some(Archive) =>
      <li className=" text-[var(--t5)] bg-transparent flex flex-row items-center">
        {Array.make(~length=todoRelation.depth - 1, false)
        ->Array.mapWithIndex((_, i) => {
          <div
            key={i->Int.toString} className="self-stretch w-2 ml-2 border-l border-[var(--t3)] "
          />
        })
        ->React.array}
        <Icons.Archive className={"w-3 ml-1.5"} />
        <span className="text-2xs ml-1.5"> {"Archived"->React.string} </span>
      </li>

    | Some(Stashed) =>
      <li className=" text-[var(--t5)] bg-transparent flex flex-row items-center ">
        {Array.make(~length=todoRelation.depth - 1, false)
        ->Array.mapWithIndex((_, i) => {
          <div
            key={i->Int.toString} className="self-stretch w-2 ml-2 border-l border-[var(--t3)] "
          />
        })
        ->React.array}
        <Icons.Bookmark className={"w-3 ml-1.5"} />
        <span className="text-2xs ml-1.5"> {"Stashed"->React.string} </span>
      </li>

    | _ => React.null
    }}
    <li
      id={getTodoId(todo.id)}
      tabIndex={0}
      ref={ReactDOM.Ref.domRef(containerRef)}
      onBlur={_ => {
        setSelectedElement(_ => None)
        setStagedForDelete(_ => false)
      }}
      onFocus={_ => {
        setSelectedElement(_ => Some(todo.id))
        setDisplayElement(_ => Some(todo.id))
      }}
      onKeyDown={onKeyDownContainer}
      // onMouseEnter={e => {
      //   itemToMoveHandleMouseEnter(false, todo.id, e)
      // }}
      className={[
        listItemClass,
        // todoRelation.depth == 0 ? "" : "pl-1",

        "relative flex flex-row justify-start items-center outline-none ",
      ]->Array.join(" ")}>
      {if moveActive {
        <div
          id={getDragId(todo.id)}
          className={"inset-0 absolute bg-amber-400 opacity-0 cursor-move z-10 drag-mask"}
          onMouseDown={_ => {
            setDrag()
          }}
        />
      } else {
        React.null
      }}
      {Array.make(~length=todoRelation.depth - 1, false)
      ->Array.mapWithIndex((_, i) => {
        <div key={i->Int.toString} className="self-stretch w-2 ml-2 border-l border-[var(--t3)] " />
      })
      ->React.array}
      <div
        className={[
          " flex group flex-row justify-start items-center h-full flex-1 rounded-sm  py-1 pl-1",
          stagedForDelete ? "outline-red-700 dark:outline-red-500" : " outline-blue-500 ",
          stagedForDelete
            ? "bg-red-200 dark:bg-red-950"
            : isChecked
            ? "bg-sky-50 dark:bg-sky-950"
            // : isDisplayElement && !isSelected
            // ? "outline-blue-500"
            : "",
          isSelected || isDisplayElement ? "outline outline-2 -outline-offset-2 " : "",
        ]->Array.join(" ")}>
        statusSelect
        // <div
        //   onMouseDown={e => itemToMoveHandleMouseDown(e, todo.id)}
        //   className={" w-4 h-4 text-[var(--t4)] rounded-sm 0 "}>
        //   <Icons.DragDrop />
        // </div>
        <div
          className={[
            "relative flex-1 flex flex-row h-full justify-start items-center ",
          ]->Array.join(" ")}>
          // <div className="w-4 h-4  -left-4">
          //   <Icons.DragDrop />
          // </div>

          <div
            id={getDropId(todo.id)}
            className="opacity-0 absolute drag-marker -top-[5px] -left-2 z-10 h-0.5 w-full bg-amber-500"
          />
          {if todo.is_last_of_mode->Option.isSome {
            <div
              id={getDropId(todo.id)}
              className="opacity-0 absolute drag-marker drag-marker-bottom top-[18px] -left-2 z-10 h-0.5 w-full bg-amber-500"
            />
          } else {
            React.null
          }}
          {isSelected || isDisplayElement
            ? React.null
            : <div className="h-px w-full absolute bg-[var(--t2)] -bottom-1" />}
          <Common.TextareaAutosize
            id={getTodoInputId(todo.id)}
            ref={ReactDOM.Ref.domRef(inputRef)}
            className={[
              todoInputClass,
              // todoRelation.depth == 0 ? "font-black" : "text-sm",
              "mx-1 block w-full h-5 border-0 pl-0 py-0 focus:ring-0  bg-transparent text-xs font-medium",
            ]->Array.join(" ")}
            placeholder={todoRelation.depth == 0 ? "Untitled Project" : ""}
            style={{resize: "none"}}
            value={text->Option.getOr("")}
            onBlur={_ => setSelectedElement(_ => None)}
            onFocus={_ => {
              setSelectedElement(_ => Some(todo.id))
              setDisplayElement(_ => Some(todo.id))
            }}
            onKeyDown={onKeyDownInput}
            onChange={e => setText(ReactEvent.Form.target(e)["value"])}
          />
          {todo.target_date->Nullable.toOption->Option.isSome
            ? <Common.DateSelect
                className="mr-1 ml-1"
                value={todo.target_date->Nullable.toOption->Option.map(Date.fromString)}
                onClick={newDate =>
                  setTodoDate(
                    todo.id,
                    newDate
                    ->Option.map(x =>
                      x->DateFns.formatISOOpt({
                        representation: "date"->Some,
                        format: None,
                      })
                    )
                    ->toNullableNull,
                  )}
              />
            : React.null}
          <CollapseControls todo todoRelation />
          {showCheckboxes
            ? <div className={[" h-full pr-2 pl-1 flex flex-row items-center"]->Array.join(" ")}>
                <input
                  onChange={_ => {
                    setChecked(v =>
                      v->SSet.has(todo.id) ? v->SSet.remove(todo.id) : v->SSet.add(todo.id)
                    )
                  }}
                  checked={isChecked}
                  type_={"checkbox"}
                  className={[
                    "border-[var(--t4)] bg-[var(--t0)] rounded text-blue-400 dark:text-blue-800 w-4 h-4 focus:ring-offset-0 focus:ring-blue-500",
                  ]->Array.join(" ")}
                />
              </div>
            : React.null}
        </div>
      </div>
    </li>
  </React.Fragment>
}

// if i == todoRelation.depth - 1 {
//   // <div
//   //   key={i->Int.toString} className="self-stretch w-2 ml-2 border-l border-[var(--t3)] "
//   // />
//   switch todo.is_first_of_mode {
//   | Some(Archive) =>
//     <div
//       className=" text-[var(--t5)] bg-transparent flex flex-row items-center justify-center mx-0.5">
//       <Icons.Archive className={"w-3"} />
//     </div>

//   | Some(Stashed) =>
//     <div
//       className=" text-[var(--t5)] bg-transparent flex flex-row items-center justify-center mx-0.5">
//       <Icons.Bookmark className={"w-3"} />
//     </div>

//   | _ =>
//     <div
//       key={i->Int.toString} className="self-stretch w-2 ml-2 border-l border-[var(--t3)] "
//     />
//   }
// } else {
//   <div
//     key={i->Int.toString} className="self-stretch w-2 ml-2 border-l border-[var(--t3)] "
//   />
// }
// {switch todo.is_first_of_mode {
// | Some(Stashed) =>
//   <li className=" text-xs px-4 font-bold  border-b w-full"> {"Stash"->React.string} </li>
// | Some(Archive) =>
//   <li className=" text-xs px-4 font-bold border-b w-full"> {"Archive"->React.string} </li>
// | _ => React.null
// }}

// switch todo.mode {
// | Archive => "text-[#6d8eb2]"
// | Stashed => "text-[#b0832f]"
// | Working => "text-[var(--t10)]"
// },
// switch todo.mode {
// | Archive => "text-[var(--t5)]"
// | Stashed => "text-[var(--t5)]"
// | Working => "text-[var(--t10)]"
// },

// {switch todo.outfit {
// | Project => <div className="w-10 h-5 bg-teal-500 rounded-full" />
// | Group => <div className="" />
// | Todo => <div className="w-10 h-5 bg-blue-200 rounded" />
// }}

// {if todoRelation.hasHiddenChildren {
//   <div
//     className="absolute  text-[var(--darkPurple)] bg-[var(--lightPurple)]
//     text-xs h-3 w-3 -left-3 -top-0 flex flex-row items-center justify-center rounded-full">
//     <Icons.Archive />
//   </div>
// } else {
//   React.null
// }}

// <div className="w-3 flex flex-row justify-center items-center ">
//   <button
//     className={[
//       " w-2 h-2 rounded-full",
//       switch todo.mode {
//       | Archive => "bg-[#f4deb2]"
//       | Stashed => "bg-[#cbe1a8]"
//       | Working => "bg-[var(--t4)]"
//       },
//     ]->Array.join(" ")}
//   />
// </div>
// {"S"->React.string}
// {"A"->React.string}

// stagedForDelete
//   ? "bg-red-200 dark:bg-red-950"
//   : isChecked
//   ? "bg-sky-50 dark:bg-sky-950"
//   : isDisplayElement && !isSelected
//   ? "bg-sky-200 dark:bg-sky-900"
//   : "bg-[var(--t0)]",

// {todoRelation.depth == 0 ? statusSelect : React.null}
// {todoRelation.depth == 0 ? <div className="w-2" /> : React.null}
// isChecked ? "flex" : " hidden group-hover:flex",

// <div
//   onMouseDown={e => itemToMoveHandleMouseDown(todo.id, e)}
//   className={" w-4 h-4 text-[var(--t4)] hidden group-hover:block bg-[var(--t0)] rounded-sm 0 "}>
//   <Icons.DragDrop />
// </div>

// {todoRelation.depth > 0 ? statusSelect : React.null}

// <div className="w-5 flex flex-row justify-center items-center ">
//   <button
//     className={[
//       " w-4 h-4 rounded-full",
//       switch todo.mode {
//       | Archive => "bg-[#f4deb2]"
//       | Stashed => "bg-[#cbe1a8]"
//       | Working => "bg-[var(--t2)]"
//       },
//     ]->Array.join(" ")}
//   />
// </div>
// {switch todo.mode {
// | Archive =>
//   <div
//     className=" text-[var(--t6)] bg-transparent flex flex-row items-center justify-center rounded-full mr-1">
//     <Icons.Archive className={"w-3"} />
//   </div>

// | Stashed =>
//   <div
//     className=" text-[var(--t6)] bg-transparent flex flex-row items-center justify-center rounded-full mr-1">
//     <Icons.Bookmark className={"w-3"} />
//   </div>

// | Working => React.null
// }}

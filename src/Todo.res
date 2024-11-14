open Webapi.Dom
open Common
open Types

@react.component
let make = (
  ~todoRelation: todoRelation,
  ~getTodos: unit => array<todoRelation>,
  ~isSelected,
  ~setSelectedElement,
  ~isDisplayElement,
  ~setDisplayElement,
  ~showCheckboxes,
  ~setFocusIdNext,
  ~isChecked,
  ~setChecked,
  ~itemToMoveHandleMouseDown,
  ~itemToMoveHandleMouseEnter,
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
        ->Option.mapOr((), x => {
          getTodos()
          ->Array.find(t => t.self.id == x.id)
          ->Option.mapOr(
            (),
            prevSib => {
              prevSib.children
              ->Array.get(prevSib.children->Array.length - 1)
              ->Option.mapOr(
                {
                  setTodoPosition(todo.id, Value(x.id), 1.)
                },
                prevSibLastChild => {
                  setTodoPosition(todo.id, Value(x.id), prevSibLastChild.position +. 1.)
                },
              )
            },
          )
        })
        // children don't follow
        todoRelation.children->Array.forEach(v => {
          setTodoPosition(v.id, todo.parent_todo, todo.position +. v.position)
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
        let newTodoParent =
          todoRelation.parent
          ->Nullable.toOption
          ->Option.flatMap(x => x.parent_todo->Nullable.toOption)
          ->toNullableNull

        let newTodoPosition = switch (
          todoRelation.parent->Nullable.toOption,
          todoRelation.tios->Array.get(todoRelation.parentIndex + 1),
        ) {
        | (Some(parent), Some(parentsNextSib)) => (parent.position +. parentsNextSib.position) /. 2.
        | (Some(parent), _) => parent.position +. 1.
        | (_, Some(parentsNextSib)) => parentsNextSib.position /. 2.
        | _ => 1.
        }
        setTodoPosition(todo.id, newTodoParent, newTodoPosition)

        todoRelation.sibs
        ->Array.sliceToEnd(~start=todoRelation.index + 1)
        ->Array.forEach(v => {
          let newPosition =
            todoRelation.children
            ->Array.get(todoRelation.children->Array.length - 1)
            ->Option.mapOr(0., c => c.position) +. v.position

          setTodoPosition(v.id, todo.id->Value, newPosition)
        })
      })
    }
  }

  let makeNewTodo = () => {
    let newPosition =
      todoRelation.depth == 0 || todoRelation.children->Array.length > 0
        ? todoRelation.children->Array.get(0)->Option.mapOr(0., x => x.position /. 2.)
        : todoRelation.sibs
          ->Array.get(todoRelation.index + 1)
          ->Option.mapOr(todo.position +. 1., nextSib => (nextSib.position +. todo.position) /. 2.)

    let newParent =
      todoRelation.depth == 0 || todoRelation.children->Array.length > 0
        ? todo.id->Nullable.Value
        : todo.parent_todo

    let newId = addTodo("", newParent, newPosition)
    setFocusIdNext(_ => Some(getTodoInputId(newId)))
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
          deleteTodo(todo.id)

          containerRef.current->mapNullable(containerEl => {
            Common.focusPreviousClass(listItemClass, containerEl)
          })
        }

        if e->key == "Backspace" && !(e->metaKey) {
          if stagedForDelete {
            deleteTodo(todo.id)

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
          deleteTodo(todo.id)

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
    onMouseEnter={e => {
      itemToMoveHandleMouseEnter(false, todo.id, e)
    }}
    className={[
      listItemClass,
      todoRelation.depth == 0 ? "" : "pl-1",
      "group flex flex-row justify-start items-center outline-none",
    ]->Array.join(" ")}>
    {Array.make(~length=todoRelation.depth - 1, false)
    ->Array.mapWithIndex((_, i) => {
      <div key={i->Int.toString} className="self-stretch w-2 border-l ml-2 border-[var(--t3)] " />
    })
    ->React.array}
    <div
      className={[
        "pl-1 group flex flex-row justify-start items-center h-full flex-1 rounded-sm",
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
      // {switch todo.outfit {
      // | Project => <div className="w-10 h-5 bg-teal-500 rounded-full" />
      // | Group => <div className="" />
      // | Todo => <div className="w-10 h-5 bg-blue-200 rounded" />
      // }}
      {todoRelation.depth > 0
        ? <Common.StatusSelect
            hasHidden={todoRelation.hasHiddenChildren}
            isOpen={statusSelectIsOpen}
            onOpenChange={v => {
              if !v {
                setStatusSelectIsOpen(_ => v)
              } else {
                setStatusSelectIsOpen(_ => v)
              }
            }}
            status={Some(todo.status)}
            mode={todo.mode}
            focusTodo={() => {
              // this isn't set directly because the "Enter"
              // will then fire on the container then focusing
              // the input *shrugs*
              setFocusIdNext(_ => Some(getTodoId(todo.id)))
            }}
            setStatus={newStatus => setTodoStatus(todo.id, newStatus)}
          />
        : React.null}
      <div
        className={[
          "relative flex-1 ml-1 flex flex-row h-full justify-start items-center ",
        ]->Array.join(" ")}>
        // {if todoRelation.hasHiddenChildren {
        //   <div
        //     className="absolute  text-[var(--darkPurple)] bg-[var(--lightPurple)]
        //     text-xs h-3 w-3 -left-3 -top-0 flex flex-row items-center justify-center rounded-full">
        //     <Icons.Archive />
        //   </div>
        // } else {
        //   React.null
        // }}
        {isSelected || isDisplayElement
          ? React.null
          : <div className="h-px w-full absolute bg-[var(--t2)] -bottom-0" />}
        <Common.TextareaAutosize
          id={getTodoInputId(todo.id)}
          ref={ReactDOM.Ref.domRef(inputRef)}
          className={[
            todoInputClass,
            todoRelation.depth == 0 ? "font-black" : "text-sm",
            "mx-1 my-1 block w-full h-5 border-0 pl-0 py-0 focus:ring-0 text-[var(--t10)] bg-transparent",
            // stagedForDelete
            //   ? "bg-red-200 dark:bg-red-950"
            //   : isChecked
            //   ? "bg-sky-50 dark:bg-sky-950"
            //   : isDisplayElement && !isSelected
            //   ? "bg-sky-200 dark:bg-sky-900"
            //   : "bg-[var(--t0)]",
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
        {todoRelation.depth == 0
          ? <Common.StatusSelect
              hasHidden={todoRelation.hasHiddenChildren}
              isOpen={statusSelectIsOpen}
              onOpenChange={v => {
                if !v {
                  setStatusSelectIsOpen(_ => v)
                } else {
                  setStatusSelectIsOpen(_ => v)
                }
              }}
              mode={todo.mode}
              status={Some(todo.status)}
              focusTodo={() => {
                // this isn't set directly because the "Enter"
                // will then fire on the container then focusing
                // the input *shrugs*
                setFocusIdNext(_ => Some(getTodoId(todo.id)))
              }}
              setStatus={newStatus => setTodoStatus(todo.id, newStatus)}
            />
          : React.null}
        {todoRelation.depth == 0 ? <div className="w-2" /> : React.null}
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
        {showCheckboxes
          ? <div
              className={[
                " h-full pr-2 pl-1 flex flex-row items-center",
                // isChecked ? "flex" : " hidden group-hover:flex",
              ]->Array.join(" ")}>
              // <div
              //   onMouseDown={e => itemToMoveHandleMouseDown(todo.id, e)}
              //   className={" w-4 h-4 text-[var(--t4)] hidden group-hover:block bg-[var(--t0)] rounded-sm 0 "}>
              //   <Icons.DragDrop />
              // </div>
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
}

open Types
open Webapi.Dom
@warning("-33")
open Common

@react.component
let make = (~todoRelation: todoRelation, ~setFocusIdNext) => {
  // ~setTodos: (string, array<todo> => array<todo>) => unit,
  let todo = todoRelation.self
  let textRef = React.useRef(Nullable.null)
  let additionalTextRef = React.useRef(Nullable.null)

  let (text, setText) = useDebounce(
    ~initialValue=todo.text->Nullable.toOption,
    ~onTrigger=v => v->Option.mapOr((), v_ => setTodoText(todo.id, v_)),
    ~delay=1000,
  )
  let (additionalText, setAdditionalText) = useDebounce(
    ~initialValue=todo.additional_text->Nullable.toOption,
    ~onTrigger=v => v->Option.mapOr((), v_ => setTodoAdditionalText(todo.id, v_)),
    ~delay=1000,
  )

  // let (statusSelectIsOpen, setStatusSelectIsOpen) = React.useState(() => false)

  // React.useEffect(() => {
  //   setText(_ => todo.text->Nullable.toOption)
  //   None
  // }, [todo.id])

  React.useEffect(() => {
    if additionalTextRef.current->Nullable.toOption != Webapi.Dom.document->Document.activeElement {
      setAdditionalText(_ => todo.additional_text->Nullable.toOption)
    }

    None
  }, [todo.additional_text])

  React.useEffect(() => {
    if textRef.current->Nullable.toOption != Webapi.Dom.document->Document.activeElement {
      setText(_ => todo.text->Nullable.toOption)
    }

    None
  }, [todo.text])

  <div className="w-full flex-1 overflow-y-scroll">
    <div className=" w-full px-2 py-1">
      <Common.TextareaAutosize
        ref={ReactDOM.Ref.domRef(textRef)}
        style={{
          resize: "none",
        }}
        id="id-display-title"
        className={[
          todoRelation.depth == 0 ? "font-black" : "font-medium",
          "text-lg flex-1 bg-inherit text-[var(--t10)] w-full outline-none 
          focus:ring-0
           border-none p-0 ",
        ]->Array.join(" ")}
        placeholder={"Todo"}
        value={text->Option.getOr("")}
        onKeyDown={e => {
          if e->ReactEvent.Keyboard.key == "Escape" {
            setFocusIdNext(_ => Some(getTodoId(todo.id)))
          }
        }}
        onChange={e => setText(ReactEvent.Form.target(e)["value"])}
      />
    </div>
    <div
      className="flex flex-row flex-wrap border-y border-[var(--t3)] items-center gap-2 p-1 px-2">
      // <Common.StatusSelect
      //   isOpen={statusSelectIsOpen}
      //   hasHidden={todoRelation.hasHiddenChildren}
      //   onOpenChange={v => {
      //     setStatusSelectIsOpen(_ => v)
      //   }}
      //   status={Some(todo.status)}
      //   mode={todo.mode}
      //   setMode={m => setTodoMode(todo.id, m)}
      //   focusTodo={() => ()}
      //   setStatus={newStatus => setTodoStatus(todo.id, newStatus)}
      // />
      {switch todo.mode {
      | Archive =>
        <div className=" text-[var(--t6)] bg-transparent flex flex-row items-center justify-center">
          <Icons.Archive className={"w-4"} />
        </div>

      | Stashed =>
        <div
          className=" text-[var(--t6)] bg-transparent flex flex-row items-center justify-center ">
          <Icons.Bookmark className={"w-4"} />
        </div>

      | Working =>
        <div className=" text-[var(--t6)] bg-transparent flex flex-row items-center justify-center">
          <Icons.Inbox className={"w-4"} />
        </div>
      }}
      <Common.DateSelect
        className=""
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
      // {todoRelation.depth > 0
      //   ? <button
      //       className="px-2 bg-[var(--t2)] rounded text-sm h-5"
      //       onClick={_ => {
      //         setTodoHidden(todo.id, !todo.hidden)
      //       }}>
      //       {(todo.hidden ? "Show" : "Hide")->React.string}
      //     </button>
      //   : React.null}
      // {todoRelation.children->Array.length > 0
      //   ? <button
      //       className="px-2 bg-[var(--t2)] rounded text-sm h-5"
      //       onClick={_ => {
      //         batch(() => {
      //           todoRelation.children->Array.forEach(child => {
      //             setTodoHidden(child.id, true)
      //           })
      //         })
      //       }}>
      //       {"Hide Subs"->React.string}
      //     </button>
      //   : React.null}
      // {todoRelation.hasHiddenChildren
      //   ? <button
      //       className="px-2 bg-[var(--t2)] rounded text-sm h-5"
      //       onClick={_ => {
      //         batch(() => {
      //           todoRelation.children->Array.forEach(child => {
      //             setTodoHidden(child.id, false)
      //           })
      //         })
      //       }}>
      //       {"Show Subs"->React.string}
      //     </button>
      //   : React.null}
      // {todoRelation.depth >= 0
      //   ? <div className="flex flex-row gap-1">
      //       <button
      //         className="px-2 text-sm bg-gray-200" onClick={_ => setTodoOutfit(todo.id, Project)}>
      //         {"Make Project"->React.string}
      //       </button>
      //       <button
      //         className="px-2 text-sm bg-gray-200" onClick={_ => setTodoOutfit(todo.id, Group)}>
      //         {"Make Group"->React.string}
      //       </button>
      //       <button
      //         className="px-2 text-sm bg-gray-200" onClick={_ => setTodoOutfit(todo.id, Todo)}>
      //         {"Make Todo"->React.string}
      //       </button>
      //     </div>
      //   : React.null}
      <div className="flex flex-row items-center border-l border-[var(--t3)] pl-1">
        // <div className="text-sm px-2"> {"Show "->React.string} </div>
        {todoRelation.children->Array.length > 0 ? <ModeMgr todo={todo->Some} /> : React.null}
      </div>
      <div className={"flex-1"} />
      <button
        onClick={_ => {
          Webapi.Dom.document
          ->Document.getElementById(getTodoId(todo.id))
          ->Option.mapOr((), todoEl => Common.focusPreviousClass(listItemClass, todoEl))
          deleteTodoAndMoveChildren(todoRelation)
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
    <div className="p-2">
      <Common.TextareaAutosize
        ref={ReactDOM.Ref.domRef(additionalTextRef)}
        style={{
          resize: "none",
        }}
        id="id-display-title"
        className={[
          "placeholder:text-[var(--t5)] text-sm flex-1 border-none rounded-lg text-[var(--t10)] w-full outline-none bg-[var(--t2)]
          focus:ring-0 font-medium",
        ]->Array.join(" ")}
        placeholder={"Additional Details"}
        value={additionalText->Option.getOr("")}
        onChange={e => {
          setAdditionalText(_ => ReactEvent.Form.target(e)["value"]->Some)
        }}
      />
    </div>
  </div>
}

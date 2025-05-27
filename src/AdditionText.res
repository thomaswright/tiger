open Types
open Webapi.Dom
@warning("-33")
open Common

let truncateString = s => {
  let limit = 30
  if s->String.length > limit {
    s->String.slice(~start=0, ~end=limit - 3)->String.trimEnd ++ "..."
  } else {
    s
  }
}

@react.component
let make = (~todoRelation: todoRelation) => {
  let todo = todoRelation.self
  let additionalTextRef = React.useRef(Nullable.null)

  let (additionalText, setAdditionalText) = useDebounce(
    ~initialValue=todo.additional_text->Nullable.toOption,
    ~onTrigger=v => v->Option.mapOr((), v_ => setTodoAdditionalText(todo.id, v_)),
    ~delay=1000,
  )

  React.useEffect(() => {
    if additionalTextRef.current->Nullable.toOption != Webapi.Dom.document->Document.activeElement {
      setAdditionalText(_ => todo.additional_text->Nullable.toOption)
    }

    None
  }, [todo.additional_text])

  <div className="w-full flex-1 overflow-y-scroll h-full">
    <Common.TextareaAutosize
      ref={ReactDOM.Ref.domRef(additionalTextRef)}
      style={{
        resize: "none",
      }}
      id="id-display-title"
      className={[
        "bg-[var(--t0)] placeholder:text-[var(--t5)] text-sm flex-1 border-none text-[var(--t10)] w-full outline-none 
          focus:ring-0 font-medium",
      ]->Array.join(" ")}
      placeholder={"Additional details for \"" ++
      todoRelation.self.text->Nullable.toOption->Option.getOr("")->truncateString ++ "\""}
      value={additionalText->Option.getOr("")}
      onChange={e => {
        setAdditionalText(_ => ReactEvent.Form.target(e)["value"]->Some)
      }}
    />
  </div>
}

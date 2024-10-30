let getFirstSome = arr => {
  arr->Array.reduce(None, (a, c) => a->Option.isSome ? a : c->Option.isSome ? c : a)
}

let isFirstInstanceOfDay = date => {
  let firstDayOfMonth = DateFns.startOfMonth(date)
  let daysInFirstWeek = DateFns.eachDayOfInterval({
    start: firstDayOfMonth,
    end_: DateFns.addDays(firstDayOfMonth, 6),
  })

  daysInFirstWeek->Array.some(day => DateFns.isSameDay(day, date))
}

let isFirstDayOfMonth = date => {
  DateFns.isSameDay(DateFns.startOfMonth(date), date)
}

// Todo: focusTodo on escape

@react.component
let make = (~onClick, ~value: option<Js.Date.t>) => {
  let now = Date.make()
  let defaultStartAdj = 1
  let defaultEndAdj = 3
  let defaultWindowAdj = defaultStartAdj + defaultEndAdj
  let ((startAdj, endAdj), setMonthAdj) = React.useState(() => (
    defaultStartAdj * -1,
    defaultEndAdj,
  ))

  let centerDate = value->Option.mapOr(Js.Date.make(), v => {
    v->DateFns.isAfter(DateFns.startOfMonth(DateFns.addMonths(Js.Date.make(), startAdj))) ||
      v->DateFns.isBefore(DateFns.endOfMonth(DateFns.addMonths(Js.Date.make(), endAdj)))
      ? v
      : Js.Date.make()
  })

  let start = DateFns.startOfMonth(DateFns.addMonths(centerDate, startAdj))
  let end_ = DateFns.endOfMonth(DateFns.addMonths(centerDate, endAdj))

  let allDays =
    DateFns.eachDayOfInterval({start, end_})
    ->Array.reduce(([], [], start->DateFns.getWeek), ((a, weekBuild, weekCheck), c) => {
      let currentWeek = c->DateFns.getWeek

      currentWeek == weekCheck
        ? (a, weekBuild->Array.concat([c->Some]), weekCheck)
        : (a->Array.concat([weekBuild]), [c->Some], currentWeek)
    })
    ->(
      ((a, weekBuild, _)) =>
        a
        ->Array.concat([weekBuild])
        ->{
          a => {
            let lastIndex = a->Array.length - 1
            a->Array.mapWithIndex((w: array<option<Js.Date.t>>, i) => {
              i == 0
                ? w
                  ->Array.get(0)
                  ->Option.flatMap(d => d)
                  ->Option.mapOr(w, d => {
                    Array.concat(Array.make(~length=d->DateFns.getDay, None), w)
                  })
                : w
                  ->Array.get(lastIndex)
                  ->Option.flatMap(d => d)
                  ->Option.mapOr(w, d => {
                    Array.concat(w, Array.make(~length=6 - d->DateFns.getDay, None))
                  })
            })
          }
        }
    )

  let shifter =
    <div className={"text-2xs font-bold w-full flex items-center justify-around py-1"}>
      <button
        onClick={_ => setMonthAdj(((s, e)) => (s - defaultWindowAdj, e - defaultWindowAdj))}
        className={""}>
        <Icons.ArrowLeft />
      </button>
      {`${start->DateFns.format("MMM yyyy")} - ${end_->DateFns.format("MMM yyyy")}`->React.string}
      <button
        onClick={_ => setMonthAdj(((s, e)) => (s + defaultWindowAdj, e + defaultWindowAdj))}
        className={""}>
        <Icons.ArrowRight />
      </button>
    </div>

  <div className={"h-64 w-64 overflow-y-scroll p-3 border rounded border-plain-300 "}>
    {shifter}
    <div className={"py-2"}>
      {allDays
      ->Array.mapWithIndex((week, i) => {
        <div
          key={week
          ->getFirstSome
          ->Option.mapOr("noMatch", date_ => date_->DateFns.formatISO)}
          className="grid grid-cols-7 relative pl-4 ">
          {week
          ->Array.map(day => {
            switch day {
            | None => <div className=""> {""->React.string} </div>
            | Some(day_) =>
              let isValue = value->Option.mapOr(false, value => DateFns.isSameDay(day_, value))
              let className =
                [
                  " text-2xs flex items-center justify-center hover:bg-blue-100 cursor-default border-r first:border-l h-7 ",
                  DateFns.isSameDay(day_, now) ? "text-red-500 font-bold" : "",
                  isValue ? "bg-blue-200" : "",
                  mod(day_->DateFns.getMonth, 2) == 0 ? "" : "",
                  day_->DateFns.getDate > day_->DateFns.getDaysInMonth - 7
                    ? "border-b border-b-black"
                    : "border-b",
                  day_->DateFns.getDate == day_->DateFns.getDaysInMonth &&
                    !(day_->DateFns.getDay == 6)
                    ? "border-r-black"
                    : "",
                  (i == 0 || i == 1) && day_->DateFns.getDate <= 7 ? "border-t border-t-black" : "",
                  i == 0 && day_->DateFns.getDate == 1 && day_->DateFns.getDay > 0
                    ? "border-l border-l-black"
                    : "",
                ]->Array.join(" ")

              <React.Fragment>
                <div key={day_->DateFns.formatISO ++ "day"} onClick={_ => onClick(day_)} className>
                  {day_->DateFns.format("d")->React.string}
                </div>
                {day_->DateFns.getDate == 15
                  ? <div
                      key={day_->DateFns.formatISO ++ "month"}
                      className="-translate-x-1/2 translate-y-1/2 text-2xs font-bold flex gap-1 text-center absolute top-0 left-1 -rotate-90">
                      <span> {day_->DateFns.format("MMM")->React.string} </span>
                    </div>
                  : React.null}
              </React.Fragment>
            }
          })
          ->React.array}
        </div>
      })
      ->React.array}
    </div>
    {shifter}
  </div>
}

let default = make

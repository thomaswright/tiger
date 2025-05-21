@react.component
let make = (~setBaseColor, ~logout) => {
  let (theme, setTheme) = Theme.useTheme()

  <div className="flex-1 overflow-y-scroll px-3 py-2 flex flex-col gap-2 items-start pb-2">
    <div className="flex flex-row gap-3 ml-0.5">
      <img src={Common.logoUrl} width={"40"} className="py-0.5 " />
      <div className="font-black text-5xl tracking-tighter"> {"Tiger Todo"->React.string} </div>
    </div>
    <div className="font-normal text-sm">
      <div className=" mb-4 mt-2">
        {"Tiger is a todo app with one special feature: it is designed exclusively for my girlfriend.
            You can use it too if you like it.
            "->React.string}
      </div>
    </div>
    <div className="flex flex-row justify-end w-full">
      <button className="text-sm px-2 bg-[var(--t2)] rounded" onClick={_ => logout()}>
        {"Logout"->React.string}
      </button>
    </div>
    <div className="font-black text-xl"> {"Settings"->React.string} </div>
    <div className="">
      <div className="font-bold pb-1"> {"Color Theme"->React.string} </div>
      <div className="flex flex-row gap-2 py-1">
        {[
          "var(--redBase)",
          "var(--orangeBase)",
          "var(--yellowBase)",
          "var(--greenBase)",
          "var(--tealBase)",
          "var(--blueBase)",
          "var(--purpleBase)",
          "var(--pinkBase)",
        ]
        ->Array.map(v => {
          <button
            key={v}
            onClick={_ => setBaseColor(_ => v)}
            style={{
              backgroundColor: theme == Dark
                ? `oklch(from ${v} 0.4 0.2 h)`
                : `oklch(from ${v} 0.8 0.2 h)`,
            }}
            className="h-6 w-6 rounded-full"
          />
        })
        ->React.array}
      </div>
      <div className="flex flex-row gap-2 py-2">
        <button className="text-sm px-2 bg-[var(--t2)] rounded" onClick={_ => setTheme(_ => Dark)}>
          {"Dark Mode"->React.string}
        </button>
        <button className="text-sm px-2 bg-[var(--t2)] rounded" onClick={_ => setTheme(_ => Light)}>
          {"Light Mode"->React.string}
        </button>
      </div>
    </div>
    <div className="font-bold"> {"Backup"->React.string} </div>
    <div className="flex flex-row gap-2 mb-2">
      // <button
      //   onClick={_ => onExportJson()}
      //   className={[
      //     "bg-[var(--t2)] px-2 rounded text-sm flex flex-row items-center gap-1 h-5 ",
      //   ]->Array.join(" ")}>
      //   {"Export"->React.string}
      // </button>
      // <Common.ImportButton onImportJson />
    </div>
    <div className="text-xs text-right w-full py-3 px-2 font-bold ">
      {"Made by "->React.string}
      <a
        style={{
          color: theme == Dark
            ? "oklch(from var(--tBase) 0.7 0.2 h)"
            : "oklch(from var(--tBase) 0.5 0.2 h)",
        }}
        href={"https://github.com/thomaswright/tiger"}>
        {"Thomas Wright"->React.string}
      </a>
    </div>
  </div>
}

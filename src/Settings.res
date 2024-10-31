@react.component
let make = (~onExportJson, ~onImportJson, ~setBaseColor) => {
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
      <div className="mb-2"> {"Here are the features:"->React.string} </div>
      <ul className="list-disc ml-4">
        <li> {"By design it has only one page. There are no \"views\"."->React.string} </li>
        <li> {"Todos are grouped by project."->React.string} </li>
        <li> {"Meaningful statuses"->React.string} </li>
        <li>
          {"Make sub-todos by indenting with tab or cmd + ] deindent with shift + tab or cmd + [."->React.string}
        </li>
        <li>
          {"Drag by the drag handle to reorder. Click the clickbox to drag multiple."->React.string}
        </li>
        <li> {"Click the clickbox to change the status of multiple."->React.string} </li>
        <li>
          {"Navigate with arrow keys. Hit enter to change the text. Escape to go back to nav mode. \"s\" opens the status picker."->React.string}
        </li>
        <li>
          {"Hit enter from in a todo to make a new todo or click the plus on the project."->React.string}
        </li>
        <li>
          {"Delete a todo by either deleting all text and then hitting Backspace twice, hitting cmd + Backspace, or click the trash icon on the details panel."->React.string}
        </li>
        <li> {"Add a date."->React.string} </li>
        <li> {"Add additional details per todo."->React.string} </li>
        <li>
          {"Order by date or status in the project details. Can also hide archived todos here."->React.string}
        </li>
        <li> {"Collapse all projects."->React.string} </li>
        <li>
          {"The todos are stored locally, not in the cloud. The import will override all data."->React.string}
        </li>
        <li>
          {"It has light and dark mode and multiple color options for each. It is cute when you want to be cute and serious when you need to be serious."->React.string}
        </li>
      </ul>
    </div>
    <div className="font-black text-lg"> {"Settings"->React.string} </div>
    <div className="font-bold text-sm"> {"Backup"->React.string} </div>
    <div className="flex flex-row gap-2">
      <button
        onClick={_ => onExportJson()}
        className={[
          "bg-[var(--t2)] px-2 rounded text-sm flex flex-row items-center gap-1 h-5 ",
        ]->Array.join(" ")}>
        {"Export"->React.string}
      </button>
      <Common.ImportButton onImportJson />
    </div>
    <div className="pt-2">
      <div className="font-bold text-sm"> {"Color"->React.string} </div>
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
    <div className="text-xs text-right w-full py-3 font-bold ">
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

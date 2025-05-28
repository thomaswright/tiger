@react.component
let make = (~logout, ~backToTodos) => {
  // let (theme, setTheme) = Theme.useTheme()

  <div className="flex-1 overflow-y-scroll px-3 py-2 gap-4 flex flex-col items-start">
    <button className={"p-1"} onClick={_ => backToTodos()}>
      <Icons.ArrowLeft className={"w-5 h-5"} />
    </button>
    <div className="flex flex-row gap-2 items-center">
      <img src={Common.logoUrl} width={"24"} className="" />
      <div className="font-bold text-2xl"> {"Tiger Todo"->React.string} </div>
    </div>
    <div className="font-normal text-sm">
      <div className="max-w-md">
        {"This todo app has one special feature: it is designed exclusively for my girlfriend.
            You can use it too if you like it.
            "->React.string}
      </div>
    </div>
    <div className="text-xs w-full font-bold text-[var(--t8)]">
      {"Made by "->React.string}
      <a className="text-blue-500" href={"https://github.com/thomaswright/tiger"}>
        {"Thomas Wright"->React.string}
      </a>
    </div>
    <div className="flex flex-row justify-start">
      <button className="text-sm px-3 py-0.5 bg-[var(--t2)] rounded" onClick={_ => logout()}>
        {"Logout"->React.string}
      </button>
    </div>
  </div>
}

//  <div className="flex flex-col gap-3  py-3">
//       <div className="font-bold leading-none"> {"Theme"->React.string} </div>
//       <div className="flex flex-row gap-2 ">
//         <button
//           className="text-sm px-3 py-0.5 bg-[var(--t2)] rounded" onClick={_ => setTheme(_ => Dark)}>
//           {"Dark"->React.string}
//         </button>
//         <button
//           className="text-sm px-3 py-0.5 bg-[var(--t2)] rounded"
//           onClick={_ => setTheme(_ => Light)}>
//           {"Light"->React.string}
//         </button>
//       </div>
//       <div className="flex flex-row gap-2">
//         {[
//           "var(--redBase)",
//           "var(--orangeBase)",
//           "var(--yellowBase)",
//           "var(--greenBase)",
//           "var(--tealBase)",
//           "var(--blueBase)",
//           "var(--purpleBase)",
//           "var(--pinkBase)",
//         ]
//         ->Array.map(v => {
//           <button
//             key={v}
//             onClick={_ => setBaseColor(_ => v)}
//             style={{
//               backgroundColor: theme == Dark
//                 ? `oklch(from ${v} 0.4 0.2 h)`
//                 : `oklch(from ${v} 0.8 0.2 h)`,
//             }}
//             className="h-6 w-6 rounded-full"
//           />
//         })
//         ->React.array}
//       </div>
//     </div>

// <div className="font-bold"> {"Backup"->React.string} </div>
// <div className="flex flex-row gap-2 mb-2">
// <button
//   onClick={_ => onExportJson()}
//   className={[
//     "bg-[var(--t2)] px-2 rounded text-sm flex flex-row items-center gap-1 h-5 ",
//   ]->Array.join(" ")}>
//   {"Export"->React.string}
// </button>
// <Common.ImportButton onImportJson />
// </div>

type theme =
  | @as("dark") Dark
  | @as("light") Light

@val @scope(("document", "documentElement", "classList"))
external addClassToHtmlElement: string => unit = "add"

@val @scope(("document", "documentElement", "classList"))
external removeClassToHtmlElement: string => unit = "remove"

let useTheme = () => {
  let (theme, setTheme, _getTheme) = Common.useLocalStorage(StorageKeys.theme, Light)

  React.useEffect1(() => {
    let (remove, add) = theme == Dark ? ("light", "dark") : ("dark", "light")

    removeClassToHtmlElement(remove)
    addClassToHtmlElement(add)

    None
  }, [theme])

  (theme, setTheme)
}

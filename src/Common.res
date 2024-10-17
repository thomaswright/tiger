@module("./useLocalStorage.js")
external useLocalStorage: (string, 'a) => ('a, ('a => 'a) => unit, unit => 'a) = "default"

@module("./useLocalStorage.js")
external useLocalStorageListener: (string, 'a) => 'a = "useLocalStorageListener"

@module("./other.js")
external focusPreviousClass: (string, Dom.element) => unit = "focusPreviousClass"

@module("./other.js")
external focusNextClass: (string, Dom.element) => unit = "focusNextClass"

@module("uuid") external uuid: unit => string = "v4"

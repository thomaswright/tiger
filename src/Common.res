@module("./useLocalStorage.js")
external useLocalStorage: (string, 'a) => ('a, ('a => 'a) => unit, unit => 'a) = "default"

@module("./useLocalStorage.js")
external useLocalStorageListener: (string, 'a) => 'a = "useLocalStorageListener"

@module("./other.js")
external focusPreviousClass: string => unit = "focusPreviousClass"

@module("./other.js")
external focusNextClass: string => unit = "focusNextClass"

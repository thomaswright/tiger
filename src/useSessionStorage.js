import React from "react";

function dispatchStorageEvent(key, newValue) {
  window.dispatchEvent(new StorageEvent("storage", { key, newValue }));
}

const setSessionStorageItem = (key, value) => {
  const stringifiedValue = JSON.stringify(value);
  window.sessionStorage.setItem(key, stringifiedValue);
  dispatchStorageEvent(key, stringifiedValue);
};

const removeSessionStorageItem = (key) => {
  window.sessionStorage.removeItem(key);
  dispatchStorageEvent(key, null);
};

const getSessionStorageItem = (key) => {
  return window.sessionStorage.getItem(key);
};

const useSessionStorageSubscribe = (callback) => {
  window.addEventListener("storage", callback);
  return () => window.removeEventListener("storage", callback);
};

const getSessionStorageServerSnapshot = () => {
  throw Error("useSessionStorage is a client-only hook");
};

export default function useSessionStorage(key, initialValue) {
  const getSnapshot = React.useCallback(
    () => getSessionStorageItem(key),
    [key]
  );

  const getCurrentValue = React.useCallback(() => {
    let val = getSessionStorageItem(key);

    if (Boolean(val)) {
      return JSON.parse(val);
    } else {
      return initialValue;
    }
  }, [key]);

  const store = React.useSyncExternalStore(
    useSessionStorageSubscribe,
    getSnapshot,
    getSessionStorageServerSnapshot
  );

  const currentValue = React.useMemo(() => {
    return store ? JSON.parse(store) : initialValue;
  }, [store, initialValue]);

  const setState = React.useCallback(
    (v) => {
      try {
        const nextState =
          typeof v === "function" ? v(JSON.parse(getSnapshot())) : v;

        if (nextState === undefined || nextState === null) {
          removeSessionStorageItem(key);
        } else {
          setSessionStorageItem(key, nextState);
        }
      } catch (e) {
        console.warn(e);
      }
    },
    [key, getSnapshot]
  );

  React.useEffect(() => {
    if (
      getSessionStorageItem(key) === null &&
      typeof initialValue !== "undefined"
    ) {
      setSessionStorageItem(key, initialValue);
    }
  }, [key, initialValue]);

  return [currentValue, setState, getCurrentValue];
}

export function useSessionStorageListener(key, defaultValue) {
  const getSnapshot = React.useCallback(
    () => getSessionStorageItem(key),
    [key]
  );

  const store = React.useSyncExternalStore(
    useSessionStorageSubscribe,
    getSnapshot,
    getSessionStorageServerSnapshot
  );

  const currentValue = React.useMemo(() => {
    return store ? JSON.parse(store) : defaultValue;
  }, [store, defaultValue]);

  return currentValue;
}

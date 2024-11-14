import { useState, useEffect } from "react";
import { observer, useEffectOnce } from "@legendapp/state/react";
import { batch } from "@legendapp/state";
import {
  supabase,
  todos$ as _todos$,
  uid$,
  setTodoMode,
  setTodoShowMode,
} from "./utils/SupaLegend.ts";
import { Auth } from "@supabase/auth-ui-react";
import { ThemeSupa } from "@supabase/auth-ui-shared";
import Dashboard from "./Dashboard.res.mjs";
import { groupByAndSort } from "./other.js";
import useSessionStorage from "./useSessionStorage.js";
import { jwtDecode } from "jwt-decode";
import logoUrl from "./assets/tiger.svg";

const DashboardWrapper = observer(({ session }) => {
  let [stashed, setStashed] = useState([]);
  // useEffectOnce(() => {
  //   let todos = Object.entries(_todos$.get() || {}).map(([k, v]) => {
  //     return { ...v, id: k };
  //   });
  //   batch(() => {
  //     todos.forEach((todo) => setTodoShowMode(todo.id, "Working"));
  //   });
  // });
  const todos = groupByAndSort(
    Object.entries(_todos$.get() || {}).map(([k, v]) => {
      return { ...v, id: k };
    }),
    "parent_todo",
    "position"
  );
  // console.log(_todos$.get());
  let rec = (t, depth, parent, tios, parentIndex) =>
    Boolean(t)
      ? t.reduce((a, c, i) => {
          let children = Boolean(todos[c.id])
            ? rec(
                todos[c.id].filter((x) => {
                  if (c.show_mode === "Working") {
                    return x.mode === "Working";
                  } else if (c.show_mode === "Stashed") {
                    return x.mode === "Working" || x.mode === "Stashed";
                  } else {
                    return true;
                  }
                }),
                depth + 1,
                c,
                t,
                i
              )
            : [];
          let newItem = {
            self: c,
            depth: depth,
            parent: parent,
            parentIndex: parentIndex,
            hasHiddenChildren: Boolean(todos[c.id])
              ? todos[c.id].some((x) => {
                  if (c.show_mode === "Working") {
                    return x.mode === "Stashed" || x.mode === "Archived";
                  } else if (c.show_mode === "Stashed") {
                    return x.mode === "Archive";
                  } else {
                    return false;
                  }
                })
              : false,
            tios: tios,
            index: i,
            sibs: t,
            children: Boolean(todos[c.id]) ? todos[c.id] : [],
          };
          return [...a, newItem, ...children];
        }, [])
      : [];
  let todosToDisplay = !Boolean(todos["root"])
    ? []
    : rec(
        todos["root"].filter((x) => x.mode === "Working"),
        0,
        null,
        [],
        0
      );
  // console.log(Object.entries(_todos$.get() || {}));

  return (
    <Dashboard
      todos={todosToDisplay || []}
      stashed={stashed}
      setStashed={setStashed}
      allProjects={todos["root"] || []}
      logout={() => supabase.auth.signOut()}
    />
  );
});

function App() {
  const [session, setSession] = useSessionStorage(null);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      uid$.set(session ? session.user.id : "");
    });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      uid$.set(session ? session.user.id : "");
    });

    return () => subscription.unsubscribe();
  }, []);

  if (!session) {
    return (
      <div className="max-w-lg p-6">
        <Auth
          supabaseClient={supabase}
          appearance={{ theme: ThemeSupa }}
          providers={[]}
        />
      </div>
    );
  } else {
    let jwt = jwtDecode(session.access_token);
    if (jwt.app_metadata.tiger_plan !== "FOREVER") {
      return (
        <div className="p-6 max-w-lg">
          <div className="flex flex-row gap-3 ml-0.5">
            <img src={logoUrl} width={"40"} className="py-0.5 " />
            <div className="font-black text-5xl tracking-tighter">
              {"Tiger Todo"}
            </div>
          </div>
          <div className="pt-2">
            <div>We're currently under limited release.</div>
            <div>Stay apprised for coming details.</div>
          </div>
          <div>
            <button
              className="text-sm px-2 bg-[var(--t2)] rounded"
              onClick={(_) => supabase.auth.signOut()}
            >
              {"Logout"}
            </button>
          </div>
        </div>
      );
    } else {
      return <DashboardWrapper session={session} />;
    }
  }
}

export default App;

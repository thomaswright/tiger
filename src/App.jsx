import { useState, useEffect } from "react";
import { observer, useEffectOnce } from "@legendapp/state/react";
import { batch } from "@legendapp/state";
import {
  supabase,
  todos$ as _todos$,
  uid$,
  setTodoModesShown,
} from "./utils/SupaLegend.ts";
import { Auth } from "@supabase/auth-ui-react";
import { ThemeSupa } from "@supabase/auth-ui-shared";
import Entry from "./Entry.res.mjs";
import useSessionStorage from "./useSessionStorage.js";
import { jwtDecode } from "jwt-decode";
import logoUrl from "./assets/tiger.svg";

const DashboardWrapper = observer(({ session }) => {
  // useEffectOnce(() => {
  //   let todos = Object.entries(_todos$.get() || {}).map(([k, v]) => {
  //     return { ...v, id: k };
  //   });

  //   batch(() => {
  //     todos.forEach((todo) => {
  //       setTodoModesShown(todo.id, (v) => ["Working"]);
  //     });
  //   });
  // });
  // return null;

  const todos = Object.entries(_todos$.get() || {}).map(([k, v]) => {
    return { ...v, id: k };
  });

  return (
    <Entry
      input={todos}
      logout={() => {
        supabase.auth.signOut();
        localStorage.clear();
      }}
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
    // let jwt = jwtDecode(session.access_token);
    // if (jwt.app_metadata.tiger_plan !== "FOREVER") {
    //   return (
    //     <div className="p-6 max-w-lg">
    //       <div className="flex flex-row gap-3 ml-0.5">
    //         <img src={logoUrl} width={"40"} className="py-0.5 " />
    //         <div className="font-black text-5xl tracking-tighter">
    //           {"Tiger Todo"}
    //         </div>
    //       </div>
    //       <div className="pt-2">
    //         <div>We're currently under limited release.</div>
    //         <div>Stay apprised for coming details.</div>
    //       </div>
    //       <div>
    //         <button
    //           className="text-sm px-2 bg-[var(--t2)] rounded"
    //           onClick={(_) => supabase.auth.signOut()}
    //         >
    //           {"Logout"}
    //         </button>
    //       </div>
    //     </div>
    //   );
    // } else {
    return <DashboardWrapper session={session} />;
    // }
  }
}

export default App;

import { useEffect } from "react";
import { observer } from "@legendapp/state/react";
import { supabase, todos$ as _todos$, uid$ } from "./SupaLegend.ts";
import { Auth } from "@supabase/auth-ui-react";
import { ThemeSupa } from "@supabase/auth-ui-shared";
import Entry from "./Entry.res.mjs";
import useSessionStorage from "./useSessionStorage.js";
import { jwtDecode } from "jwt-decode";
import logoUrl from "./assets/tiger.svg";

const EntryWrapper = observer(({ session }) => {
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
        <div className="flex flex-row gap-2 items-center justify-center">
          <img src={logoUrl} width={"24"} className="" />
          <div className="font-bold text-2xl"> {"Tiger Todo"} </div>
        </div>
        <Auth
          supabaseClient={supabase}
          appearance={{
            theme: ThemeSupa,
            variables: {
              default: {
                colors: {
                  brand: "#ff9400",
                  brandAccent: "#FF8000",
                },
                radii: {
                  borderRadiusButton: "8px",
                  buttonBorderRadius: "8px",
                  inputBorderRadius: "8px",
                },
                fontSizes: {
                  baseBodySize: "13px",
                  baseInputSize: "14px",
                  baseLabelSize: "14px",
                  baseButtonSize: "14px",
                },
                space: {
                  buttonPadding: "6px 10px",
                  inputPadding: "6px 10px",
                },
              },
            },
          }}
          providers={[]}
        />
      </div>
    );
  } else {
    return <EntryWrapper session={session} />;
  }
}

export default App;

alter table "public"."todos" drop column "done";

alter table "public"."todos" drop column "hidden";

alter table "public"."todos" drop column "outfit";

alter table "public"."todos" drop column "position";

alter table "public"."todos" drop column "show_mode";

alter table "public"."todos" add column "root_for" uuid;

CREATE INDEX idx_root_for ON public.todos USING btree (root_for);

alter table "public"."todos" add constraint "fk_root_for" FOREIGN KEY (root_for) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "public"."todos" validate constraint "fk_root_for";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_todo_for_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO public.todos (root_for, mode, modes_shown, status)
    VALUES (NEW.id, 'Working', ARRAY['Working'], 'Unsorted');
    RETURN NEW;
END;
$function$
;



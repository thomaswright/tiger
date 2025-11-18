set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_todo_for_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$BEGIN
    INSERT INTO public.todos (root_for, mode, modes_shown, status, user_id)
    VALUES (NEW.id, 'Working', ARRAY['Working'], 'Unsorted', NEW.id);
    RETURN NEW;
END;$function$
;



drop policy "forever plans can make todos" on "public"."todos";

alter table "public"."todos" add column "hidden" boolean not null default false;

create policy "Authenticated users can delete their own todos"
on "public"."todos"
as permissive
for delete
to authenticated
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "Authenticated users can insert their own todos"
on "public"."todos"
as permissive
for insert
to authenticated
with check ((( SELECT auth.uid() AS uid) = user_id));


create policy "Authenticated users can select their own todos"
on "public"."todos"
as permissive
for select
to authenticated
using ((( SELECT auth.uid() AS uid) = user_id));


create policy "Authenticated users can update their own todos"
on "public"."todos"
as permissive
for update
to authenticated
using ((( SELECT auth.uid() AS uid) = user_id))
with check ((( SELECT auth.uid() AS uid) = user_id));




alter table "public"."todos" alter column "order" set default ARRAY[]::text[];

alter table "public"."todos" alter column "order" set not null;



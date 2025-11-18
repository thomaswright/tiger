alter table "public"."todos" drop column "showmode";

alter table "public"."todos" add column "show_mode" mode not null default 'Working'::mode;



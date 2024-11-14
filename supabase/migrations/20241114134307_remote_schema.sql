create type "public"."mode" as enum ('Archive', 'Stashed', 'Working');

alter table "public"."todos" add column "mode" mode not null default 'Working'::mode;



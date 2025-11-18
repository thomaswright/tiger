alter table "public"."todos" add column "modes_shown" mode[] not null default ARRAY[]::mode[];



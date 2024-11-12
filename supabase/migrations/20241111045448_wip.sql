drop trigger handle_times_projects on projects;

alter table todos drop column project;

drop table projects;

create type outfit_type as enum ('Todo', 'Project', 'Group');

alter table todos add column outfit outfit_type not null default 'Todo';

create type status_type as enum (
    'Unsorted',
    'Future',
    'NowIfTime',
    'NowMustDo',
    'Underway',
    'Paused',
    'ResolveDone',
    'ResolveNo',
    'ArchiveDone',
    'ArchiveNo'
);

alter table todos add column status status_type not null default 'Unsorted';

-- Resource-Devta: Supabase schema (Postgres + PostGIS)
-- Run this in Supabase SQL Editor.

create extension if not exists "uuid-ossp";
create extension if not exists postgis;

-- Roles
do $$
begin
  if not exists (select 1 from pg_type where typname = 'app_role') then
    create type public.app_role as enum ('volunteer', 'ngo_admin');
  end if;
end $$;

-- Helper: timestamps
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

-- Profiles (RBAC source of truth)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text not null default '',
  role public.app_role not null default 'volunteer',
  volunteer_skills text[] not null default '{}'::text[],
  is_available boolean not null default false,
  last_lat double precision,
  last_lng double precision,
  last_location geography(point, 4326),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.sync_profile_geog()
returns trigger language plpgsql as $$
begin
  if new.last_lat is null or new.last_lng is null then
    new.last_location = null;
  else
    new.last_location = st_setsrid(st_makepoint(new.last_lng, new.last_lat), 4326)::geography;
  end if;
  return new;
end $$;

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists trg_profiles_sync_geog on public.profiles;
create trigger trg_profiles_sync_geog
before insert or update of last_lat, last_lng on public.profiles
for each row execute function public.sync_profile_geog();

-- Reports (survey submissions)
create table if not exists public.reports (
  id uuid primary key default uuid_generate_v4(),
  created_by uuid not null references public.profiles(id) on delete restrict,
  title text not null default 'Report',
  payload jsonb not null default '{}'::jsonb,
  severity_score int not null default 1 check (severity_score between 1 and 10),
  major_problem_tag text,
  lat double precision,
  lng double precision,
  location geography(point, 4326),
  created_at timestamptz not null default now()
);

create or replace function public.sync_report_geog()
returns trigger language plpgsql as $$
begin
  if new.lat is null or new.lng is null then
    new.location = null;
  else
    new.location = st_setsrid(st_makepoint(new.lng, new.lat), 4326)::geography;
  end if;
  return new;
end $$;

drop trigger if exists trg_reports_sync_geog on public.reports;
create trigger trg_reports_sync_geog
before insert or update of lat, lng on public.reports
for each row execute function public.sync_report_geog();

create index if not exists idx_reports_created_by on public.reports(created_by);
create index if not exists idx_reports_created_at on public.reports(created_at desc);
create index if not exists idx_reports_location on public.reports using gist(location);
create index if not exists idx_reports_major_problem on public.reports(major_problem_tag);

-- Tasks (needs / actionable work)
do $$
begin
  if not exists (select 1 from pg_type where typname = 'task_status') then
    create type public.task_status as enum ('pending', 'in_progress', 'completed');
  end if;
end $$;

create table if not exists public.tasks (
  id uuid primary key default uuid_generate_v4(),
  created_by_ngo uuid not null references public.profiles(id) on delete restrict,
  title text not null,
  description text not null default '',
  priority int not null default 0,
  required_skills text[] not null default '{}'::text[],
  status public.task_status not null default 'pending',
  lat double precision,
  lng double precision,
  location geography(point, 4326),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.sync_task_geog()
returns trigger language plpgsql as $$
begin
  if new.lat is null or new.lng is null then
    new.location = null;
  else
    new.location = st_setsrid(st_makepoint(new.lng, new.lat), 4326)::geography;
  end if;
  return new;
end $$;

drop trigger if exists trg_tasks_sync_geog on public.tasks;
create trigger trg_tasks_sync_geog
before insert or update of lat, lng on public.tasks
for each row execute function public.sync_task_geog();

drop trigger if exists trg_tasks_updated_at on public.tasks;
create trigger trg_tasks_updated_at
before update on public.tasks
for each row execute function public.set_updated_at();

create index if not exists idx_tasks_status on public.tasks(status);
create index if not exists idx_tasks_priority on public.tasks(priority desc);
create index if not exists idx_tasks_location on public.tasks using gist(location);

-- Assignments (volunteer dispatch)
create table if not exists public.assignments (
  id uuid primary key default uuid_generate_v4(),
  task_id uuid not null references public.tasks(id) on delete cascade,
  volunteer_id uuid not null references public.profiles(id) on delete restrict,
  assigned_by uuid not null references public.profiles(id) on delete restrict,
  status public.task_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (task_id, volunteer_id)
);

drop trigger if exists trg_assignments_updated_at on public.assignments;
create trigger trg_assignments_updated_at
before update on public.assignments
for each row execute function public.set_updated_at();

create index if not exists idx_assignments_volunteer on public.assignments(volunteer_id);
create index if not exists idx_assignments_task on public.assignments(task_id);

-- Views: flatten geo for easier mobile consumption
create or replace view public.v_profiles_public as
select
  p.id,
  p.email,
  p.full_name,
  p.role,
  p.volunteer_skills,
  p.is_available,
  p.last_lat as lat,
  p.last_lng as lng,
  p.created_at,
  p.updated_at
from public.profiles p;

create or replace view public.v_reports_public as
select
  r.id,
  r.created_by,
  r.title,
  r.payload,
  r.severity_score,
  r.major_problem_tag,
  r.lat,
  r.lng,
  r.created_at
from public.reports r;

create or replace view public.v_tasks_public as
select
  t.id,
  t.created_by_ngo,
  t.title,
  t.description,
  t.priority,
  t.required_skills,
  t.status,
  t.lat,
  t.lng,
  t.created_at,
  t.updated_at
from public.tasks t;

-- Enable RLS
alter table public.profiles enable row level security;
alter table public.reports enable row level security;
alter table public.tasks enable row level security;
alter table public.assignments enable row level security;

-- Policies
-- Profiles: user can read/update own profile; admins can read all
drop policy if exists "profiles_read_own_or_admin" on public.profiles;
create policy "profiles_read_own_or_admin"
on public.profiles for select
using (
  auth.uid() = id
  or exists (
    select 1 from public.profiles p2
    where p2.id = auth.uid() and p2.role = 'ngo_admin'
  )
);

drop policy if exists "profiles_upsert_self" on public.profiles;
create policy "profiles_upsert_self"
on public.profiles for insert
with check (auth.uid() = id);

drop policy if exists "profiles_update_self" on public.profiles;
create policy "profiles_update_self"
on public.profiles for update
using (auth.uid() = id)
with check (auth.uid() = id);

-- Reports: any authed user can insert; admins can read all; submitter can read own
drop policy if exists "reports_insert_authed" on public.reports;
create policy "reports_insert_authed"
on public.reports for insert
with check (auth.uid() = created_by);

drop policy if exists "reports_read_own_or_admin" on public.reports;
create policy "reports_read_own_or_admin"
on public.reports for select
using (
  auth.uid() = created_by
  or exists (
    select 1 from public.profiles p2
    where p2.id = auth.uid() and p2.role = 'ngo_admin'
  )
);

-- Tasks: admins can create/update; volunteers can read
drop policy if exists "tasks_read_authed" on public.tasks;
create policy "tasks_read_authed"
on public.tasks for select
using (auth.role() = 'authenticated');

drop policy if exists "tasks_admin_write" on public.tasks;
create policy "tasks_admin_write"
on public.tasks for insert
with check (
  exists (select 1 from public.profiles p2 where p2.id = auth.uid() and p2.role = 'ngo_admin')
);

drop policy if exists "tasks_admin_update" on public.tasks;
create policy "tasks_admin_update"
on public.tasks for update
using (
  exists (select 1 from public.profiles p2 where p2.id = auth.uid() and p2.role = 'ngo_admin')
)
with check (
  exists (select 1 from public.profiles p2 where p2.id = auth.uid() and p2.role = 'ngo_admin')
);

-- Assignments: admins can write; assigned volunteer can read own assignments
drop policy if exists "assignments_read_volunteer_or_admin" on public.assignments;
create policy "assignments_read_volunteer_or_admin"
on public.assignments for select
using (
  auth.uid() = volunteer_id
  or exists (select 1 from public.profiles p2 where p2.id = auth.uid() and p2.role = 'ngo_admin')
);

drop policy if exists "assignments_admin_write" on public.assignments;
create policy "assignments_admin_write"
on public.assignments for insert
with check (
  exists (select 1 from public.profiles p2 where p2.id = auth.uid() and p2.role = 'ngo_admin')
);

drop policy if exists "assignments_admin_update" on public.assignments;
create policy "assignments_admin_update"
on public.assignments for update
using (
  exists (select 1 from public.profiles p2 where p2.id = auth.uid() and p2.role = 'ngo_admin')
)
with check (
  exists (select 1 from public.profiles p2 where p2.id = auth.uid() and p2.role = 'ngo_admin')
);

-- Realtime: make sure to enable replication in Supabase UI for:
-- profiles, reports, tasks, assignments


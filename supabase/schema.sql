-- AUTO LOG 1.0 — run in Supabase SQL Editor
create extension if not exists pgcrypto;
create table if not exists public.cars(
 id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 make text not null, model text not null, year int, plate text, vin text, color text, engine text, fuel_type text, engine_volume numeric(5,2), odometer int not null default 0 check(odometer>=0), photo_url text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.entries(
 id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 car_id uuid not null references public.cars(id) on delete cascade, kind text not null check(kind in ('Обслуживание','Заправка','Расход')),
 title text not null, category text not null, date date not null default current_date, odometer int check(odometer>=0), amount numeric(12,2) not null default 0 check(amount>=0),
 vendor text, comment text, liters numeric(10,2), price_per_liter numeric(10,2), attachment_path text, created_at timestamptz not null default now()
);
create table if not exists public.reminders(
 id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
 car_id uuid not null references public.cars(id) on delete cascade, title text not null, kind text, due_date date, due_odometer int, completed boolean not null default false, created_at timestamptz not null default now()
);
create index if not exists entries_car_date_idx on public.entries(car_id,date desc);
create index if not exists reminders_car_date_idx on public.reminders(car_id,due_date);
alter table public.cars enable row level security; alter table public.entries enable row level security; alter table public.reminders enable row level security;
drop policy if exists "cars own rows" on public.cars;
create policy "cars own rows" on public.cars for all using(user_id=auth.uid()) with check(user_id=auth.uid());
drop policy if exists "entries own rows" on public.entries;
create policy "entries own rows" on public.entries for all using(user_id=auth.uid() and exists(select 1 from public.cars c where c.id=car_id and c.user_id=auth.uid())) with check(user_id=auth.uid() and exists(select 1 from public.cars c where c.id=car_id and c.user_id=auth.uid()));
drop policy if exists "reminders own rows" on public.reminders;
create policy "reminders own rows" on public.reminders for all using(user_id=auth.uid() and exists(select 1 from public.cars c where c.id=car_id and c.user_id=auth.uid())) with check(user_id=auth.uid() and exists(select 1 from public.cars c where c.id=car_id and c.user_id=auth.uid()));
-- Private storage bucket for user documents. Create bucket "auto-files" as PRIVATE in Storage UI.
-- Storage policies: allow authenticated users to manage objects whose first folder is auth.uid().

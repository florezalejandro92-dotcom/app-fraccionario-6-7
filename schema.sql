-- Fracciones 6º y 7º - Esquema Supabase (para version original con Supabase)
create extension if not exists "uuid-ossp";
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  full_name text not null,
  grade text,
  group_name text,
  role text not null default 'student' check (role in ('student','teacher')),
  created_at timestamptz default now()
);
create table if not exists public.progress (
  id uuid primary key default uuid_generate_v4(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  module_id int not null,
  completed boolean default false,
  best_score int default 0,
  last_score int default 0,
  updated_at timestamptz default now(),
  unique(student_id, module_id)
);
create table if not exists public.attempts (
  id uuid primary key default uuid_generate_v4(),
  student_id uuid not null references public.profiles(id) on delete cascade,
  module_id int not null,
  module_title text not null,
  score int not null check (score >=0 and score <=100),
  correct_count int not null,
  total_count int not null,
  missed_questions text[],
  difficulty_note text,
  created_at timestamptz default now()
);
alter table public.profiles enable row level security;
alter table public.progress enable row level security;
alter table public.attempts enable row level security;
drop policy if exists "Perfiles visibles" on public.profiles;
create policy "Perfiles visibles" on public.profiles for select using (auth.role()='authenticated');
drop policy if exists "insert perfil" on public.profiles;
create policy "insert perfil" on public.profiles for insert with check (auth.uid()=id);
drop policy if exists "update perfil" on public.profiles;
create policy "update perfil" on public.profiles for update using (auth.uid()=id);
drop policy if exists "progreso propio" on public.progress;
create policy "progreso propio" on public.progress for all using (auth.uid()=student_id) with check (auth.uid()=student_id);
drop policy if exists "docente ve progreso" on public.progress;
create policy "docente ve progreso" on public.progress for select using (exists(select 1 from public.profiles where id=auth.uid() and role='teacher'));
drop policy if exists "intentos propios" on public.attempts;
create policy "intentos propios" on public.attempts for all using (auth.uid()=student_id) with check (auth.uid()=student_id);
drop policy if exists "docente ve intentos" on public.attempts;
create policy "docente ve intentos" on public.attempts for select using (exists(select 1 from public.profiles where id=auth.uid() and role='teacher'));

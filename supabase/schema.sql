-- Bio 61: synchronizacja postępów, notatek i zdjęć.
-- Wklej całość w Supabase → SQL Editor → Run. Można uruchomić ponownie.

create table if not exists public.progress (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.progress enable row level security;

drop policy if exists "own progress select" on public.progress;
drop policy if exists "own progress insert" on public.progress;
drop policy if exists "own progress update" on public.progress;
create policy "own progress select" on public.progress for select to authenticated using (auth.uid() = user_id);
create policy "own progress insert" on public.progress for insert to authenticated with check (auth.uid() = user_id);
create policy "own progress update" on public.progress for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- prywatny bucket na zdjęcia; każdy widzi tylko swój folder <user_id>/...
insert into storage.buckets (id, name, public)
values ('photos', 'photos', false)
on conflict (id) do nothing;

drop policy if exists "own photos select" on storage.objects;
drop policy if exists "own photos insert" on storage.objects;
drop policy if exists "own photos update" on storage.objects;
drop policy if exists "own photos delete" on storage.objects;
create policy "own photos select" on storage.objects for select to authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "own photos insert" on storage.objects for insert to authenticated
  with check (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "own photos update" on storage.objects for update to authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "own photos delete" on storage.objects for delete to authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = auth.uid()::text);

-- prywatne materiały z podręcznika (przepisane strony); widzi je tylko właściciel konta
create table if not exists public.book (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

alter table public.book enable row level security;

drop policy if exists "own book select" on public.book;
drop policy if exists "own book insert" on public.book;
drop policy if exists "own book update" on public.book;
drop policy if exists "own book delete" on public.book;
create policy "own book select" on public.book for select to authenticated using (auth.uid() = user_id);
create policy "own book insert" on public.book for insert to authenticated with check (auth.uid() = user_id);
create policy "own book update" on public.book for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own book delete" on public.book for delete to authenticated using (auth.uid() = user_id);

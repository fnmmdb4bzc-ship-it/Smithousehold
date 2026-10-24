-- The Smit Household: database setup (already applied to the Supabase project on 24 October 2026).
-- Kept here as a record, and so it can be re-created in a new project if ever needed.
-- To change who has access, edit the allowed_emails table in Supabase (Table Editor).

create table if not exists public.allowed_emails (
  email text primary key check (email = lower(email)),
  added_at timestamptz not null default now()
);
alter table public.allowed_emails enable row level security;   -- no policies: the web page cannot read or change it
-- insert into public.allowed_emails (email) values ('first@gmail.com'), ('second@gmail.com');

create schema if not exists private;
revoke all on schema private from public, anon;
grant usage on schema private to authenticated;

create or replace function private.is_household()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.allowed_emails a
                 where a.email = lower(coalesce(auth.jwt() ->> 'email', '')));
$$;
revoke all on function private.is_household() from public, anon;
grant execute on function private.is_household() to authenticated;

create table if not exists public.docs (
  collection text not null,
  id         text not null,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (collection, id)
);
alter table public.docs enable row level security;
create policy "household can read"   on public.docs for select to authenticated using ((select private.is_household()));
create policy "household can add"    on public.docs for insert to authenticated with check ((select private.is_household()));
create policy "household can change" on public.docs for update to authenticated using ((select private.is_household())) with check ((select private.is_household()));
create policy "household can delete" on public.docs for delete to authenticated using ((select private.is_household()));

do $$ begin alter publication supabase_realtime add table public.docs; exception when duplicate_object then null; end $$;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', false, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;
create policy "household photos read"   on storage.objects for select to authenticated using (bucket_id = 'photos' and (select private.is_household()));
create policy "household photos add"    on storage.objects for insert to authenticated with check (bucket_id = 'photos' and (select private.is_household()));
create policy "household photos change" on storage.objects for update to authenticated using (bucket_id = 'photos' and (select private.is_household())) with check (bucket_id = 'photos' and (select private.is_household()));
create policy "household photos delete" on storage.objects for delete to authenticated using (bucket_id = 'photos' and (select private.is_household()));

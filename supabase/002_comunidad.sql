-- =====================================================================
--  OpositaYa · 002 · Ajustes para la comunidad (perfiles con nombre)
--  Ejecutar en Supabase → SQL Editor después de schema.sql.
--  Es idempotente: se puede volver a ejecutar sin problema.
-- =====================================================================

-- Permitir que cada usuario cree su propio perfil (además del trigger)
drop policy if exists "perfil insert propio" on public.profiles;
create policy "perfil insert propio" on public.profiles
  for insert with check (auth.uid() = id);

-- Trigger mejorado: coge el nombre de 'full_name' o, si no, de 'name' (Google)
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name'))
  on conflict (id) do nothing;
  return new;
end;
$$;

-- Backfill: crear/completar perfil para usuarios ya existentes
insert into public.profiles (id, full_name)
select u.id,
       coalesce(u.raw_user_meta_data->>'full_name', u.raw_user_meta_data->>'name')
from auth.users u
left join public.profiles p on p.id = u.id
where p.id is null;

-- Rellenar nombre en perfiles existentes que lo tengan vacío
update public.profiles p
set full_name = coalesce(u.raw_user_meta_data->>'full_name', u.raw_user_meta_data->>'name')
from auth.users u
where u.id = p.id
  and (p.full_name is null or p.full_name = '')
  and coalesce(u.raw_user_meta_data->>'full_name', u.raw_user_meta_data->>'name') is not null;

-- =====================================================================
--  OpositaYa · Esquema inicial de base de datos (v1)
--  Ejecutar en Supabase → SQL Editor → New query → pegar → Run.
--  Diseño genérico multi-oposición (foco actual: Auxiliar Administrativo AGE).
-- =====================================================================

-- ---------- Catálogo de contenido ----------

-- Oposiciones disponibles
create table if not exists public.oposiciones (
  id         uuid primary key default gen_random_uuid(),
  slug       text unique not null,
  nombre     text not null,
  grupo      text,                       -- p.ej. 'C2'
  activa     boolean default true,
  created_at timestamptz default now()
);

-- Bloques del temario (agrupan temas)
create table if not exists public.bloques (
  id            uuid primary key default gen_random_uuid(),
  oposicion_id  uuid not null references public.oposiciones on delete cascade,
  nombre        text not null,
  orden         int default 0
);

-- Temas del temario
create table if not exists public.temas (
  id         uuid primary key default gen_random_uuid(),
  bloque_id  uuid not null references public.bloques on delete cascade,
  numero     int,
  titulo     text not null,
  contenido  text,                       -- texto del tema (desde BOE)
  ley_boe_id text,                        -- p.ej. 'BOE-A-2015-10565' para actualizar
  created_at timestamptz default now()
);

-- Banco de preguntas
create table if not exists public.preguntas (
  id               uuid primary key default gen_random_uuid(),
  tema_id          uuid references public.temas on delete set null,
  oposicion_id     uuid references public.oposiciones on delete cascade,
  enunciado        text not null,
  opciones         jsonb not null,        -- ["opción A","opción B","opción C","opción D"]
  indice_correcta  int not null,          -- 0-based
  explicacion      text,
  dificultad       text default 'media',  -- facil | media | dificil
  fuente           text,                  -- 'oficial-2022' | 'ia' | ...
  created_at       timestamptz default now()
);

-- Tests curados (opcional; también se pueden generar dinámicamente)
create table if not exists public.tests (
  id            uuid primary key default gen_random_uuid(),
  oposicion_id  uuid not null references public.oposiciones on delete cascade,
  tema_id       uuid references public.temas on delete set null,
  titulo        text not null,
  descripcion   text,
  num_preguntas int default 20,
  es_simulacro  boolean default false,
  created_at    timestamptz default now()
);

-- ---------- Usuarios y progreso ----------

-- Perfil (1:1 con auth.users)
create table if not exists public.profiles (
  id           uuid primary key references auth.users on delete cascade,
  username     text unique,
  full_name    text,
  oposicion_id uuid references public.oposiciones on delete set null,
  created_at   timestamptz default now()
);

-- Intentos de test (una sesión de test)
create table if not exists public.intentos (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users on delete cascade default auth.uid(),
  test_id     uuid references public.tests on delete set null,
  started_at  timestamptz default now(),
  finished_at timestamptz,
  aciertos    int default 0,
  fallos      int default 0,
  total       int default 0
);

-- Respuestas concretas de cada intento (alimenta "puntos débiles")
create table if not exists public.respuestas (
  id             uuid primary key default gen_random_uuid(),
  intento_id     uuid not null references public.intentos on delete cascade,
  pregunta_id    uuid references public.preguntas on delete set null,
  opcion_elegida int,
  es_correcta    boolean
);

-- ---------- Comunidad ----------

create table if not exists public.posts (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users on delete cascade default auth.uid(),
  oposicion_id uuid references public.oposiciones on delete set null,
  titulo       text not null,
  cuerpo       text,
  votos        int default 0,             -- contador cacheado
  created_at   timestamptz default now()
);

create table if not exists public.comentarios (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid not null references public.posts on delete cascade,
  user_id    uuid not null references auth.users on delete cascade default auth.uid(),
  cuerpo     text not null,
  created_at timestamptz default now()
);

create table if not exists public.votos (
  post_id uuid not null references public.posts on delete cascade,
  user_id uuid not null references auth.users on delete cascade default auth.uid(),
  valor   int not null default 1,         -- 1 = arriba, -1 = abajo
  primary key (post_id, user_id)
);

-- =====================================================================
--  Crear el perfil automáticamente al registrarse
-- =====================================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data->>'full_name')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =====================================================================
--  RLS (Row Level Security)
-- =====================================================================
alter table public.oposiciones enable row level security;
alter table public.bloques     enable row level security;
alter table public.temas       enable row level security;
alter table public.preguntas   enable row level security;
alter table public.tests       enable row level security;
alter table public.profiles    enable row level security;
alter table public.intentos    enable row level security;
alter table public.respuestas  enable row level security;
alter table public.posts       enable row level security;
alter table public.comentarios enable row level security;
alter table public.votos       enable row level security;

-- Contenido de catálogo: lectura pública; escritura solo con service_role (admin)
create policy "catalogo lectura" on public.oposiciones for select using (true);
create policy "catalogo lectura" on public.bloques     for select using (true);
create policy "catalogo lectura" on public.temas       for select using (true);
create policy "catalogo lectura" on public.tests       for select using (true);
-- Preguntas: solo usuarios autenticados (para no exponer respuestas correctas al público)
create policy "preguntas auth" on public.preguntas for select to authenticated using (true);

-- Perfiles: lectura por autenticados (para mostrar autor en comunidad); edición solo el propio
create policy "perfil lectura" on public.profiles for select to authenticated using (true);
create policy "perfil update propio" on public.profiles for update using (auth.uid() = id);

-- Intentos y respuestas: solo del propio usuario
create policy "intentos propios" on public.intentos
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "respuestas propias" on public.respuestas
  for all using (exists (select 1 from public.intentos i where i.id = intento_id and i.user_id = auth.uid()))
  with check (exists (select 1 from public.intentos i where i.id = intento_id and i.user_id = auth.uid()));

-- Comunidad: lectura por autenticados; escritura solo el autor
create policy "posts lectura" on public.posts for select to authenticated using (true);
create policy "posts propios" on public.posts for insert with check (auth.uid() = user_id);
create policy "posts editar" on public.posts for update using (auth.uid() = user_id);
create policy "posts borrar" on public.posts for delete using (auth.uid() = user_id);

create policy "coment lectura" on public.comentarios for select to authenticated using (true);
create policy "coment propios" on public.comentarios for insert with check (auth.uid() = user_id);
create policy "coment borrar"  on public.comentarios for delete using (auth.uid() = user_id);

create policy "votos lectura" on public.votos for select to authenticated using (true);
create policy "votos propios" on public.votos
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- =====================================================================
--  Semilla mínima
-- =====================================================================
insert into public.oposiciones (slug, nombre, grupo)
values ('auxiliar-age', 'Auxiliar Administrativo del Estado', 'C2')
on conflict (slug) do nothing;

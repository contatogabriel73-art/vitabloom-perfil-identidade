-- =====================================================================
-- VITABLOOM · Configuração do banco (Supabase)
-- Cole este arquivo inteiro no SQL Editor do Supabase e clique em RUN.
--
-- E-mail da administradora: contatogabriel73@gmail.com (no fim do arquivo).
-- Se for entrar no painel com outro e-mail, troque-o antes de rodar.
-- Pode rodar de novo sem problemas (o script é idempotente).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Tabelas
-- ---------------------------------------------------------------------

create table if not exists public.visits (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  session_id  text not null check (char_length(session_id) <= 100),
  referrer    text check (char_length(referrer) <= 500),
  utm_source  text check (char_length(utm_source) <= 100)
);

create table if not exists public.bookings (
  id             uuid primary key default gen_random_uuid(),
  created_at     timestamptz not null default now(),
  tipo           text not null check (tipo in ('estetica', 'auto')),
  "date"         date not null,
  "time"         text not null check (char_length("time") <= 10),
  avulsos        text[] not null default '{}' check (coalesce(array_length(avulsos, 1), 0) <= 20),
  ritual         text check (char_length(ritual) <= 60),
  services_label text not null check (char_length(services_label) <= 500),
  total          numeric(10,2) not null default 0 check (total >= 0 and total <= 100000),
  name           text not null check (char_length(name) between 1 and 120),
  phone          text not null check (char_length(phone) between 1 and 40),
  email          text not null check (char_length(email) between 1 and 160),
  status         text not null default 'novo'
                 check (status in ('novo', 'confirmado', 'concluido', 'cancelado')),
  paid           boolean not null default false,
  paid_amount    numeric(10,2) check (paid_amount is null or paid_amount >= 0),
  paid_at        timestamptz,
  notes          text check (char_length(notes) <= 2000)
);

create index if not exists bookings_created_at_idx on public.bookings (created_at desc);
create index if not exists visits_created_at_idx   on public.visits (created_at desc);

-- Só existe 1 sala de atendimento: nunca pode haver dois agendamentos
-- ativos (não cancelados) na mesma data+horário, não importa a
-- profissional/tipo. Isso impede o duplo agendamento mesmo se duas
-- pessoas confirmarem ao mesmo tempo.
drop index if exists public.bookings_unique_slot_idx;
create unique index bookings_unique_slot_idx
  on public.bookings ("date", "time")
  where status <> 'cancelado';

-- ---------------------------------------------------------------------
-- 2. Quem é administradora
--    Só e-mails que estão nesta tabela enxergam/alteram os dados.
--    (Assim, mesmo que alguém consiga criar uma conta no seu projeto,
--    não vê nada.)
-- ---------------------------------------------------------------------

create table if not exists public.admins (
  email text primary key
);

alter table public.admins enable row level security;
-- Sem nenhuma policy e sem GRANT: ninguém lê esta tabela pela API.
revoke all on public.admins from anon, authenticated;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.admins
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

-- Deixa o site perguntar "esse horário está livre?" sem expor nenhum
-- dado de quem já agendou (só devolve verdadeiro/falso).
create or replace function public.slot_available(p_date date, p_time text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select not exists (
    select 1 from public.bookings
    where "date" = p_date and "time" = p_time and status <> 'cancelado'
  );
$$;

revoke all on function public.slot_available(date, text) from public;
grant execute on function public.slot_available(date, text) to anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. Segurança (RLS)
-- ---------------------------------------------------------------------

alter table public.visits   enable row level security;
alter table public.bookings enable row level security;

-- Permissões de tabela (RLS decide quais linhas valem)
revoke all on public.visits, public.bookings from anon, authenticated;
grant insert on public.visits, public.bookings to anon;
grant select, insert, update, delete on public.visits, public.bookings to authenticated;

-- Limpa policies antigas (para poder rodar de novo)
drop policy if exists "visits_insert_public"    on public.visits;
drop policy if exists "visits_select_admin"     on public.visits;
drop policy if exists "visits_update_admin"     on public.visits;
drop policy if exists "visits_delete_admin"     on public.visits;
drop policy if exists "bookings_insert_public"  on public.bookings;
drop policy if exists "bookings_select_admin"   on public.bookings;
drop policy if exists "bookings_update_admin"   on public.bookings;
drop policy if exists "bookings_delete_admin"   on public.bookings;

-- VISITS: qualquer visitante pode registrar visita; só a admin lê/altera/apaga.
create policy "visits_insert_public" on public.visits
  for insert to anon, authenticated
  with check (true);

create policy "visits_select_admin" on public.visits
  for select to authenticated using (public.is_admin());

create policy "visits_update_admin" on public.visits
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "visits_delete_admin" on public.visits
  for delete to authenticated using (public.is_admin());

-- BOOKINGS: visitante só cria agendamento "novo", não pago e sem dados de pagamento.
create policy "bookings_insert_public" on public.bookings
  for insert to anon, authenticated
  with check (
    status = 'novo'
    and paid = false
    and paid_amount is null
    and paid_at is null
    and notes is null
  );

create policy "bookings_select_admin" on public.bookings
  for select to authenticated using (public.is_admin());

create policy "bookings_update_admin" on public.bookings
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "bookings_delete_admin" on public.bookings
  for delete to authenticated using (public.is_admin());

-- ---------------------------------------------------------------------
-- 4. Cadastre o SEU e-mail como administradora  (TROQUE ABAIXO!)
-- ---------------------------------------------------------------------

insert into public.admins (email)
values ('contatogabriel73@gmail.com')
on conflict (email) do nothing;

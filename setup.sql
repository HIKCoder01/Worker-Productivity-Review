do $cols$
begin
  if to_regclass('public.import_batches') is not null then
    execute 'alter table public.import_batches add column if not exists type text';
    execute 'alter table public.import_batches add column if not exists kin text';
    execute 'alter table public.import_batches add column if not exists kind text';
    execute 'alter table public.import_batches add column if not exists source text';
    execute 'alter table public.import_batches add column if not exists timezone text';
    execute 'alter table public.import_batches add column if not exists row_count integer default 0';
    execute 'alter table public.import_batches add column if not exists bad_rows integer default 0';
  end if;
  if to_regclass('public.batches') is not null then
    execute 'alter table public.batches add column if not exists type text';
    execute 'alter table public.batches add column if not exists kin text';
    execute 'alter table public.batches add column if not exists kind text';
    execute 'alter table public.batches add column if not exists source text';
    execute 'alter table public.batches add column if not exists timezone text';
    execute 'alter table public.batches add column if not exists row_count integer default 0';
    execute 'alter table public.batches add column if not exists bad_rows integer default 0';
  end if;
end
$cols$;

do $runs_cols$
begin
  if to_regclass('public.runs') is not null then
    execute 'alter table public.runs add column if not exists name text';
    execute 'alter table public.runs add column if not exists date_from date';
    execute 'alter table public.runs add column if not exists date_to date';
    execute 'alter table public.runs add column if not exists ts_batch_id uuid';
    execute 'alter table public.runs add column if not exists cl_batch_ids text';
    execute 'alter table public.runs add column if not exists threshold integer';
    execute 'alter table public.runs add column if not exists critical_pct integer';
    execute 'alter table public.runs add column if not exists status text';
    execute 'alter table public.runs add column if not exists discrepancy_count integer default 0';
  end if;
end
$runs_cols$;

grant usage on schema public to authenticated;

grant select on public.discrepancies to authenticated;
grant select on public.runs to authenticated;
grant insert, update on public.discrepancies to authenticated;
grant insert, update on public.runs to authenticated;

alter table public.discrepancies enable row level security;
alter table public.runs enable row level security;

drop policy if exists "discrepancies_select_auth" on public.discrepancies;
create policy "discrepancies_select_auth"
on public.discrepancies for select to authenticated
using (true);

drop policy if exists "runs_select_auth" on public.runs;
create policy "runs_select_auth"
on public.runs for select to authenticated
using (true);

drop policy if exists "discrepancies_insert_admin" on public.discrepancies;
create policy "discrepancies_insert_admin"
on public.discrepancies for insert to authenticated
with check (public.is_admin());

drop policy if exists "discrepancies_update_admin" on public.discrepancies;
create policy "discrepancies_update_admin"
on public.discrepancies for update to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "runs_insert_admin" on public.runs;
create policy "runs_insert_admin"
on public.runs for insert to authenticated
with check (public.is_admin());

drop policy if exists "runs_update_admin" on public.runs;
create policy "runs_update_admin"
on public.runs for update to authenticated
using (public.is_admin())
with check (public.is_admin());

do $ib$
begin
  if to_regclass('public.import_batches') is not null then
    execute 'grant select, insert, delete on public.import_batches to authenticated';
    execute 'alter table public.import_batches enable row level security';
    execute $p$
      drop policy if exists "import_batches_select_auth" on public.import_batches;
      create policy "import_batches_select_auth"
      on public.import_batches for select to authenticated using (true);
      drop policy if exists "import_batches_insert_admin" on public.import_batches;
      create policy "import_batches_insert_admin"
      on public.import_batches for insert to authenticated
      with check (public.is_admin());
      drop policy if exists "import_batches_delete_admin" on public.import_batches;
      create policy "import_batches_delete_admin"
      on public.import_batches for delete to authenticated
      using (public.is_admin());
    $p$;
  end if;
end
$ib$;

do $b$
begin
  if to_regclass('public.batches') is not null then
    execute 'grant select, insert, delete on public.batches to authenticated';
    execute 'alter table public.batches enable row level security';
    execute $p$
      drop policy if exists "batches_select_auth" on public.batches;
      create policy "batches_select_auth"
      on public.batches for select to authenticated using (true);
      drop policy if exists "batches_insert_admin" on public.batches;
      create policy "batches_insert_admin"
      on public.batches for insert to authenticated
      with check (public.is_admin());
      drop policy if exists "batches_delete_admin" on public.batches;
      create policy "batches_delete_admin"
      on public.batches for delete to authenticated
      using (public.is_admin());
    $p$;
  end if;
end
$b$;

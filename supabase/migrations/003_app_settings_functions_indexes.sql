-- ============================================================
-- Migration 003: App settings, helper functions, indexes,
--               groups, prize distribution RPC
-- ============================================================

-- ── app_settings ─────────────────────────────────────────────────────────────
create table if not exists public.app_settings (
  id                    int primary key default 1,  -- singleton row
  maintenance_mode      boolean not null default false,
  allow_registrations   boolean not null default true,
  realtime_updates      boolean not null default true,
  push_notifications    boolean not null default true,
  email_notifications   boolean not null default true,
  auto_approve_deposits boolean not null default false,
  min_deposit           numeric(10,2) not null default 10,
  min_withdrawal        numeric(10,2) not null default 100,
  max_withdrawal        numeric(10,2) not null default 100000,
  support_upi_id        text not null default '7259293140@ybl',
  support_phone         text not null default '7259293140',
  updated_at            timestamptz not null default now(),
  check (id = 1)  -- enforce singleton
);
alter table public.app_settings enable row level security;
create policy "settings_read_all"  on public.app_settings for select to authenticated using (true);
create policy "admin_all_settings" on public.app_settings for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);
-- Seed default settings
insert into public.app_settings (id) values (1) on conflict (id) do nothing;

-- ── groups ────────────────────────────────────────────────────────────────────
create table if not exists public.groups (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  description text,
  created_by  uuid not null references public.users(id) on delete cascade,
  invite_code text unique default upper(substring(md5(random()::text), 1, 8)),
  max_members int  not null default 20,
  created_at  timestamptz not null default now()
);
create table if not exists public.group_members (
  id         uuid primary key default uuid_generate_v4(),
  group_id   uuid not null references public.groups(id) on delete cascade,
  user_id    uuid not null references public.users(id) on delete cascade,
  role       text not null default 'member', -- admin|member
  joined_at  timestamptz not null default now(),
  unique (group_id, user_id)
);
alter table public.groups        enable row level security;
alter table public.group_members enable row level security;
create policy "groups_read_member" on public.groups for select using (
  exists (select 1 from public.group_members gm where gm.group_id = id and gm.user_id = auth.uid())
);
create policy "groups_insert" on public.groups for insert with check (auth.uid() = created_by);
create policy "gm_read_own"   on public.group_members for select using (auth.uid() = user_id);
create policy "gm_insert_own" on public.group_members for insert with check (auth.uid() = user_id);
create policy "gm_delete_own" on public.group_members for delete using (auth.uid() = user_id);

-- ── Helper: increment_joined_teams RPC ───────────────────────────────────────
create or replace function public.increment_joined_teams(contest_id_param uuid)
returns void language plpgsql security definer as $$
begin
  update public.contests
  set joined_teams = joined_teams + 1
  where id = contest_id_param;
end;
$$;

-- ── Helper: distribute_match_prizes RPC ──────────────────────────────────────
create or replace function public.distribute_match_prizes(p_match_id uuid)
returns void language plpgsql security definer as $$
declare
  v_contest    record;
  v_entries    record;
  v_rank       int;
  v_prize      numeric;
  v_pool       numeric;
  v_count      int;
  v_current_w  numeric;
begin
  -- Loop through all open contests for the match
  for v_contest in
    select id, prize_pool, max_winners
    from public.contests
    where match_id = p_match_id and status = 'open'
  loop
    v_pool  := v_contest.prize_pool;
    -- Count participants
    select count(*) into v_count from public.leaderboard where contest_id = v_contest.id;

    -- Update ranks based on points
    with ranked as (
      select id, row_number() over (order by points desc) as rn
      from public.leaderboard
      where contest_id = v_contest.id
    )
    update public.leaderboard l
    set rank = r.rn
    from ranked r
    where l.id = r.id;

    -- Distribute prizes to top max_winners
    for v_entries in
      select l.id, l.user_id, l.rank
      from public.leaderboard l
      where l.contest_id = v_contest.id
        and l.rank <= v_contest.max_winners
      order by l.rank
    loop
      -- Simple split: rank1=50%, rank2=30%, rank3=20% of top-3 share
      v_prize := case
        when v_entries.rank = 1 then v_pool * 0.50
        when v_entries.rank = 2 then v_pool * 0.30
        when v_entries.rank = 3 then v_pool * 0.20
        else v_pool * 0.10 / greatest(v_contest.max_winners - 3, 1)
      end;

      -- Update prize_won
      update public.leaderboard set prize_won = v_prize
      where id = v_entries.id;

      -- Credit winnings
      select winnings into v_current_w from public.wallets where user_id = v_entries.user_id;
      update public.wallets set winnings = coalesce(v_current_w, 0) + v_prize
      where user_id = v_entries.user_id;

      -- Transaction record
      insert into public.transactions (user_id, type, amount, status, description, reference_id)
      values (v_entries.user_id, 'winning', v_prize, 'completed',
              'Contest prize - rank #' || v_entries.rank, v_contest.id::text);

      -- Winner notification
      insert into public.notifications (user_id, title, message, type)
      values (v_entries.user_id,
              '🏆 You Won ₹' || v_prize::int || '!',
              'Congratulations! Rank #' || v_entries.rank || '. ₹' || v_prize::int || ' added to your wallet.',
              'winning');
    end loop;

    -- Close contest
    update public.contests set status = 'completed' where id = v_contest.id;
  end loop;
end;
$$;

-- ── Indexes for performance ───────────────────────────────────────────────────
create index if not exists idx_matches_status       on public.matches(status);
create index if not exists idx_matches_date_time    on public.matches(date_time);
create index if not exists idx_contests_match_id    on public.contests(match_id);
create index if not exists idx_leaderboard_contest  on public.leaderboard(contest_id);
create index if not exists idx_leaderboard_user     on public.leaderboard(user_id);
create index if not exists idx_ce_contest           on public.contest_entries(contest_id);
create index if not exists idx_fantasy_teams_match  on public.fantasy_teams(match_id);
create index if not exists idx_fantasy_teams_user   on public.fantasy_teams(user_id);
create index if not exists idx_transactions_user    on public.transactions(user_id);
create index if not exists idx_notifications_user   on public.notifications(user_id, is_read);
create index if not exists idx_scoreboard_match     on public.scoreboard(match_id);
create index if not exists idx_player_stats_match   on public.player_stats(match_id);
create index if not exists idx_match_players_match  on public.match_players(match_id);
create index if not exists idx_fcm_tokens_user      on public.fcm_tokens(user_id);

-- ── Updated_at trigger helper ─────────────────────────────────────────────────
create or replace function public.update_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_users_updated_at
  before update on public.users
  for each row execute function public.update_updated_at();

create trigger trg_wallets_updated_at
  before update on public.wallets
  for each row execute function public.update_updated_at();

create trigger trg_fantasy_teams_updated_at
  before update on public.fantasy_teams
  for each row execute function public.update_updated_at();

-- ── User profile auto-create on signup ───────────────────────────────────────
create or replace function public.handle_new_auth_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.users (id, email, username)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'username',
             split_part(new.email, '@', 1))
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();

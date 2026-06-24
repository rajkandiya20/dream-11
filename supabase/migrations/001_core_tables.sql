-- ============================================================
-- Migration 001: Core tables
-- Covers: users, wallets, tournaments, teams, players,
--         matches, match_players (Playing XI), contests,
--         fantasy_teams, leaderboard, contest_entries
-- ============================================================

-- Extensions
create extension if not exists "uuid-ossp";

-- ── users ────────────────────────────────────────────────────────────────────
create table if not exists public.users (
  id              uuid primary key references auth.users(id) on delete cascade,
  username        text unique,
  email           text,
  avatar_url      text,
  role            text not null default 'user', -- 'user' | 'admin'
  phone           text,
  matches_played  int  not null default 0,
  contests_won    int  not null default 0,
  total_winnings  numeric(12,2) not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
alter table public.users enable row level security;
create policy "users_read_own"    on public.users for select using (auth.uid() = id);
create policy "users_update_own"  on public.users for update using (auth.uid() = id);
create policy "admin_all_users"   on public.users for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- ── wallets ───────────────────────────────────────────────────────────────────
create table if not exists public.wallets (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null unique references public.users(id) on delete cascade,
  balance     numeric(12,2) not null default 0,   -- deposited cash
  winnings    numeric(12,2) not null default 0,   -- contest winnings (withdrawable)
  bonus       numeric(12,2) not null default 0,   -- cash bonus (non-withdrawable)
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
alter table public.wallets enable row level security;
create policy "wallets_read_own"  on public.wallets for select using (auth.uid() = user_id);
create policy "wallets_update_own" on public.wallets for update using (auth.uid() = user_id);
create policy "admin_all_wallets" on public.wallets for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- Auto-create wallet on new user
create or replace function public.handle_new_user_wallet()
returns trigger language plpgsql security definer as $$
begin
  insert into public.wallets (user_id) values (new.id) on conflict do nothing;
  return new;
end;
$$;
drop trigger if exists on_user_created_wallet on public.users;
create trigger on_user_created_wallet
  after insert on public.users
  for each row execute function public.handle_new_user_wallet();

-- ── tournaments ───────────────────────────────────────────────────────────────
create table if not exists public.tournaments (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,
  description text,
  logo        text,
  start_date  date,
  end_date    date,
  status      text not null default 'active',
  created_at  timestamptz not null default now()
);
alter table public.tournaments enable row level security;
create policy "tournaments_read_all" on public.tournaments for select to authenticated using (true);
create policy "admin_all_tournaments" on public.tournaments for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- ── teams ─────────────────────────────────────────────────────────────────────
create table if not exists public.teams (
  id            uuid primary key default uuid_generate_v4(),
  tournament_id uuid references public.tournaments(id) on delete set null,
  name          text not null,
  code          text,          -- Short code e.g. 'MI', 'CSK'
  logo          text,
  created_at    timestamptz not null default now()
);
alter table public.teams enable row level security;
create policy "teams_read_all"  on public.teams for select to authenticated using (true);
create policy "admin_all_teams" on public.teams for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- ── players ───────────────────────────────────────────────────────────────────
create table if not exists public.players (
  id          uuid primary key default uuid_generate_v4(),
  team_id     uuid references public.teams(id) on delete set null,
  name        text not null,
  role        text not null default 'Batsman', -- WK|Batsman|All-rounder|Bowler
  image       text,
  credits     numeric(4,1) not null default 8.0,
  points      numeric(8,2) not null default 0,
  is_playing  boolean not null default false,
  created_at  timestamptz not null default now()
);
alter table public.players enable row level security;
create policy "players_read_all"  on public.players for select to authenticated using (true);
create policy "admin_all_players" on public.players for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- ── matches ───────────────────────────────────────────────────────────────────
create table if not exists public.matches (
  id              uuid primary key default uuid_generate_v4(),
  tournament_id   uuid references public.tournaments(id) on delete set null,
  team_a_id       uuid references public.teams(id) on delete set null,
  team_b_id       uuid references public.teams(id) on delete set null,
  team_a_name     text not null default 'Team A',
  team_b_name     text not null default 'Team B',
  team_a_code     text,
  team_b_code     text,
  team_a_flag     text,  -- URL to team logo
  team_b_flag     text,
  date_time       timestamptz,
  venue           text,
  overs           int  not null default 20,
  status          text not null default 'upcoming', -- upcoming|live|completed
  live            boolean not null default false,
  team_a_score    text,
  team_b_score    text,
  current_score_a text,
  current_score_b text,
  current_over    numeric(4,1),
  result          text,
  winner_team_id  uuid references public.teams(id),
  created_at      timestamptz not null default now()
);
alter table public.matches enable row level security;
create policy "matches_read_all"  on public.matches for select to authenticated using (true);
create policy "admin_all_matches" on public.matches for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- ── match_players (Playing XI) ────────────────────────────────────────────────
create table if not exists public.match_players (
  id          uuid primary key default uuid_generate_v4(),
  match_id    uuid not null references public.matches(id) on delete cascade,
  player_id   uuid not null references public.players(id) on delete cascade,
  team_id     uuid not null references public.teams(id) on delete cascade,
  created_at  timestamptz not null default now(),
  unique (match_id, player_id)
);
alter table public.match_players enable row level security;
create policy "match_players_read_all"  on public.match_players for select to authenticated using (true);
create policy "admin_all_match_players" on public.match_players for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- ── contests ──────────────────────────────────────────────────────────────────
create table if not exists public.contests (
  id              uuid primary key default uuid_generate_v4(),
  match_id        uuid not null references public.matches(id) on delete cascade,
  name            text not null,
  contest_type    text not null default 'paid', -- paid|free|practice
  entry_fee       numeric(10,2) not null default 0,
  prize_pool      numeric(12,2) not null default 0,
  max_teams       int  not null default 100,
  joined_teams    int  not null default 0,
  max_winners     int  not null default 3,
  prize_breakdown jsonb,
  status          text not null default 'open', -- open|closed|completed
  created_at      timestamptz not null default now()
);
alter table public.contests enable row level security;
create policy "contests_read_all"  on public.contests for select to authenticated using (true);
create policy "admin_all_contests" on public.contests for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- ── fantasy_teams ─────────────────────────────────────────────────────────────
create table if not exists public.fantasy_teams (
  id              uuid primary key default uuid_generate_v4(),
  user_id         uuid not null references public.users(id) on delete cascade,
  match_id        uuid not null references public.matches(id) on delete cascade,
  team_name       text not null default 'My Team 1',
  captain_id      uuid,
  vice_captain_id uuid,
  total_points    numeric(8,2) not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
alter table public.fantasy_teams enable row level security;
create policy "fantasy_teams_own"   on public.fantasy_teams for select using (auth.uid() = user_id);
create policy "fantasy_teams_insert" on public.fantasy_teams for insert with check (auth.uid() = user_id);
create policy "fantasy_teams_update" on public.fantasy_teams for update using (auth.uid() = user_id);
create policy "admin_all_ft" on public.fantasy_teams for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- ── fantasy_team_players ──────────────────────────────────────────────────────
create table if not exists public.fantasy_team_players (
  id              uuid primary key default uuid_generate_v4(),
  fantasy_team_id uuid not null references public.fantasy_teams(id) on delete cascade,
  player_id       uuid not null references public.players(id) on delete cascade,
  player_name     text not null,
  player_role     text not null,
  is_captain      boolean not null default false,
  is_vice_captain boolean not null default false,
  unique (fantasy_team_id, player_id)
);
alter table public.fantasy_team_players enable row level security;
create policy "ftp_read_own" on public.fantasy_team_players for select using (
  exists (select 1 from public.fantasy_teams ft where ft.id = fantasy_team_id and ft.user_id = auth.uid())
);
create policy "ftp_insert_own" on public.fantasy_team_players for insert with check (
  exists (select 1 from public.fantasy_teams ft where ft.id = fantasy_team_id and ft.user_id = auth.uid())
);

-- ── leaderboard ───────────────────────────────────────────────────────────────
create table if not exists public.leaderboard (
  id              uuid primary key default uuid_generate_v4(),
  contest_id      uuid not null references public.contests(id) on delete cascade,
  user_id         uuid not null references public.users(id) on delete cascade,
  fantasy_team_id uuid references public.fantasy_teams(id) on delete set null,
  points          numeric(8,2) not null default 0,
  rank            int  not null default 0,
  prize_won       numeric(10,2) not null default 0,
  created_at      timestamptz not null default now()
);
alter table public.leaderboard enable row level security;
create policy "leaderboard_read_all"  on public.leaderboard for select to authenticated using (true);
create policy "leaderboard_insert_own" on public.leaderboard for insert with check (auth.uid() = user_id);

-- ── contest_entries ───────────────────────────────────────────────────────────
-- Used by live ranking subscription
create table if not exists public.contest_entries (
  id              uuid primary key default uuid_generate_v4(),
  contest_id      uuid not null references public.contests(id) on delete cascade,
  user_id         uuid not null references public.users(id) on delete cascade,
  fantasy_team_id uuid references public.fantasy_teams(id) on delete set null,
  total_points    numeric(8,2) not null default 0,
  prize_won       numeric(10,2) not null default 0,
  created_at      timestamptz not null default now()
);
alter table public.contest_entries enable row level security;
create policy "ce_read_all"   on public.contest_entries for select to authenticated using (true);
create policy "ce_insert_own" on public.contest_entries for insert with check (auth.uid() = user_id);

-- ── Realtime publications ─────────────────────────────────────────────────────
alter publication supabase_realtime add table public.matches;
alter publication supabase_realtime add table public.leaderboard;
alter publication supabase_realtime add table public.contest_entries;
alter publication supabase_realtime add table public.notifications;

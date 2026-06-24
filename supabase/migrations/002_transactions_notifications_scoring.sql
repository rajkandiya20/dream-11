-- ============================================================
-- Migration 002: Transactions, Notifications, Scoring,
--               FCM Tokens, App Settings, Notification Queue
-- ============================================================

-- ── transactions ─────────────────────────────────────────────────────────────
create table if not exists public.transactions (
  id             uuid primary key default uuid_generate_v4(),
  user_id        uuid not null references public.users(id) on delete cascade,
  type           text not null, -- deposit|withdrawal|contest_join|winning|bonus|refund
  amount         numeric(12,2) not null,
  status         text not null default 'pending', -- pending|completed|rejected
  payment_method text,
  description    text,
  reference_id   text,  -- UTR for deposits, contest_id for joins, etc.
  notes          text,  -- JSON-like string for extra data (UPI ID, bank details)
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);
alter table public.transactions enable row level security;
create policy "tx_read_own"   on public.transactions for select using (auth.uid() = user_id);
create policy "tx_insert_own" on public.transactions for insert with check (auth.uid() = user_id);
create policy "admin_all_tx"  on public.transactions for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- ── notifications ─────────────────────────────────────────────────────────────
create table if not exists public.notifications (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid not null references public.users(id) on delete cascade,
  title      text not null,
  message    text not null,
  type       text not null default 'general', -- general|match|winning|bonus|lineup
  is_read    boolean not null default false,
  data       jsonb,
  created_at timestamptz not null default now()
);
alter table public.notifications enable row level security;
create policy "notif_read_own"   on public.notifications for select using (auth.uid() = user_id);
create policy "notif_insert"     on public.notifications for insert with check (true);
create policy "notif_update_own" on public.notifications for update using (auth.uid() = user_id);
create policy "notif_delete_own" on public.notifications for delete using (auth.uid() = user_id);

-- ── notification_queue (FCM broadcast queue) ──────────────────────────────────
-- Processed by Supabase Edge Function or cron job to send FCM to all users
create table if not exists public.notification_queue (
  id         uuid primary key default uuid_generate_v4(),
  title      text not null,
  message    text not null,
  type       text not null default 'general',
  data       jsonb,
  status     text not null default 'pending', -- pending|sent|failed
  created_at timestamptz not null default now(),
  sent_at    timestamptz
);
alter table public.notification_queue enable row level security;
create policy "nq_admin_all" on public.notification_queue for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- ── fcm_tokens ────────────────────────────────────────────────────────────────
create table if not exists public.fcm_tokens (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid not null references public.users(id) on delete cascade,
  token      text not null,
  platform   text,  -- android|ios
  updated_at timestamptz not null default now(),
  unique (user_id, token)
);
alter table public.fcm_tokens enable row level security;
create policy "fcm_own"       on public.fcm_tokens for select using (auth.uid() = user_id);
create policy "fcm_upsert"    on public.fcm_tokens for insert with check (auth.uid() = user_id);
create policy "fcm_update"    on public.fcm_tokens for update using (auth.uid() = user_id);
create policy "admin_all_fcm" on public.fcm_tokens for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- ── scoreboard (admin scores per player per match) ───────────────────────────
create table if not exists public.scoreboard (
  id              uuid primary key default uuid_generate_v4(),
  match_id        uuid not null references public.matches(id) on delete cascade,
  player_id       uuid not null references public.players(id) on delete cascade,
  player_name     text,
  runs            int  not null default 0,
  balls_faced     int  not null default 0,
  fours           int  not null default 0,
  sixes           int  not null default 0,
  wickets         int  not null default 0,
  overs_bowled    numeric(4,1) not null default 0,
  runs_conceded   int  not null default 0,
  maidens         int  not null default 0,
  catches         int  not null default 0,
  stumpings       int  not null default 0,
  run_outs        int  not null default 0,
  points          numeric(8,2) not null default 0,  -- fantasy points
  created_at      timestamptz not null default now(),
  unique (match_id, player_id)
);
alter table public.scoreboard enable row level security;
create policy "sb_read_all"   on public.scoreboard for select to authenticated using (true);
create policy "admin_all_sb"  on public.scoreboard for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- ── player_stats (computed from scoreboard for leaderboard) ──────────────────
create table if not exists public.player_stats (
  id            uuid primary key default uuid_generate_v4(),
  match_id      uuid not null references public.matches(id) on delete cascade,
  player_id     uuid not null references public.players(id) on delete cascade,
  runs          int  not null default 0,
  balls_faced   int  not null default 0,
  fours         int  not null default 0,
  sixes         int  not null default 0,
  wickets       int  not null default 0,
  overs_bowled  numeric(4,1) not null default 0,
  runs_conceded int  not null default 0,
  maidens       int  not null default 0,
  catches       int  not null default 0,
  stumpings     int  not null default 0,
  run_outs      int  not null default 0,
  economy       numeric(5,2) not null default 0,
  strike_rate   numeric(6,2) not null default 0,
  fantasy_points numeric(8,2) not null default 0,
  created_at    timestamptz not null default now(),
  unique (match_id, player_id)
);
alter table public.player_stats enable row level security;
create policy "ps_read_all"   on public.player_stats for select to authenticated using (true);
create policy "admin_all_ps"  on public.player_stats for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- ── ball_by_ball commentary ───────────────────────────────────────────────────
create table if not exists public.commentary (
  id           uuid primary key default uuid_generate_v4(),
  match_id     uuid not null references public.matches(id) on delete cascade,
  over_number  int  not null default 0,
  ball_number  int  not null default 0,
  batsman_id   uuid,
  bowler_id    uuid,
  runs         int  not null default 0,
  extras       int  not null default 0,
  event_type   text,  -- normal|four|six|wicket|wide|no_ball
  commentary   text,
  created_at   timestamptz not null default now()
);
alter table public.commentary enable row level security;
create policy "comm_read_all"  on public.commentary for select to authenticated using (true);
create policy "admin_all_comm" on public.commentary for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- ── admin_payment_methods ─────────────────────────────────────────────────────
create table if not exists public.admin_payment_methods (
  id           uuid primary key default uuid_generate_v4(),
  type         text not null default 'upi', -- upi|bank
  upi_id       text,
  account_name text,
  account_no   text,
  ifsc_code    text,
  is_active    boolean not null default true,
  created_at   timestamptz not null default now()
);
alter table public.admin_payment_methods enable row level security;
create policy "apm_read_all"  on public.admin_payment_methods for select to authenticated using (true);
create policy "admin_all_apm" on public.admin_payment_methods for all using (
  exists (select 1 from public.users u where u.id = auth.uid() and u.role = 'admin')
);

-- Seed default payment method
insert into public.admin_payment_methods (upi_id, account_name, type, is_active)
values ('7259293140@ybl', 'Admin', 'upi', true)
on conflict do nothing;

-- ── Realtime ──────────────────────────────────────────────────────────────────
alter publication supabase_realtime add table public.scoreboard;
alter publication supabase_realtime add table public.commentary;
alter publication supabase_realtime add table public.player_stats;
alter publication supabase_realtime add table public.transactions;

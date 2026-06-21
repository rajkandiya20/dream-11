-- ============================================================
-- Part 4: Admin Module Schema Updates
-- Run this after all previous SQL parts have been applied.
-- ============================================================

-- ===== TOURNAMENTS TABLE =====
ALTER TABLE tournaments ADD COLUMN IF NOT EXISTS tournament_type TEXT;
ALTER TABLE tournaments ADD COLUMN IF NOT EXISTS total_teams INTEGER;
ALTER TABLE tournaments ADD COLUMN IF NOT EXISTS total_matches INTEGER;
ALTER TABLE tournaments ADD COLUMN IF NOT EXISTS location TEXT;

-- ===== TEAMS TABLE =====
ALTER TABLE teams ADD COLUMN IF NOT EXISTS captain TEXT;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS vice_captain TEXT;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS max_squad_size INTEGER DEFAULT 16;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS min_squad_size INTEGER DEFAULT 11;

-- ===== PLAYERS TABLE =====
ALTER TABLE players ADD COLUMN IF NOT EXISTS jersey_number INTEGER;
ALTER TABLE players ADD COLUMN IF NOT EXISTS age INTEGER;

-- ===== MATCHES TABLE =====
ALTER TABLE matches ADD COLUMN IF NOT EXISTS overs INTEGER;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS time TIMESTAMPTZ;

-- ===== CONTESTS TABLE =====
ALTER TABLE contests ADD COLUMN IF NOT EXISTS total_spots INTEGER;
ALTER TABLE contests ADD COLUMN IF NOT EXISTS max_teams_per_user INTEGER DEFAULT 1;
ALTER TABLE contests ADD COLUMN IF NOT EXISTS winning_distribution JSONB;

-- ===== ADMIN PAYMENT METHODS TABLE =====
CREATE TABLE IF NOT EXISTS admin_payment_methods (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  method_type TEXT NOT NULL,
  method_name TEXT,
  account_details JSONB,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===== MATCH PLAYERS UNIQUE CONSTRAINT =====
CREATE UNIQUE INDEX IF NOT EXISTS match_players_match_player_unique
  ON match_players(match_id, player_id);

-- ============================================================
-- Supabase Storage Buckets
-- ============================================================
-- Create the following storage buckets via the Supabase Dashboard
-- or using the SQL statements below:
--
-- 1. tournament-logos - For tournament logo images
-- 2. team-logos - For team logo images
-- 3. player-photos - For player profile photos
--
-- Make sure to set the buckets as public so that public URLs work.
-- ============================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('tournament-logos', 'tournament-logos', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('team-logos', 'team-logos', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('player-photos', 'player-photos', true)
ON CONFLICT (id) DO NOTHING;

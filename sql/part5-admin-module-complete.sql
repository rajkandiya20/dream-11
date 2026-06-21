-- Part 5: Admin Module Complete - Additional Schema Updates
-- Ensures all columns needed by the rebuilt admin screens exist.

-- Ensure scoreboard has all needed columns
ALTER TABLE scoreboard ADD COLUMN IF NOT EXISTS extras int DEFAULT 0;
ALTER TABLE scoreboard ADD COLUMN IF NOT EXISTS runs_conceded int DEFAULT 0;

-- Ensure tournaments has tournament_type
ALTER TABLE tournaments ADD COLUMN IF NOT EXISTS tournament_type text DEFAULT 'league';

-- Ensure teams has captain, vice_captain, max/min squad columns
ALTER TABLE teams ADD COLUMN IF NOT EXISTS captain text;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS vice_captain text;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS max_squad_size int DEFAULT 16;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS min_squad_size int DEFAULT 11;

-- Ensure players has jersey_number, age columns
ALTER TABLE players ADD COLUMN IF NOT EXISTS jersey_number int DEFAULT 0;
ALTER TABLE players ADD COLUMN IF NOT EXISTS age int DEFAULT 0;

-- Ensure matches has overs column
ALTER TABLE matches ADD COLUMN IF NOT EXISTS overs int DEFAULT 20;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS time text;

-- Ensure contests has max_teams_per_user, contest_type, total_spots
ALTER TABLE contests ADD COLUMN IF NOT EXISTS max_teams_per_user int DEFAULT 1;
ALTER TABLE contests ADD COLUMN IF NOT EXISTS contest_type text DEFAULT 'mega';
ALTER TABLE contests ADD COLUMN IF NOT EXISTS total_spots int DEFAULT 0;
ALTER TABLE contests ADD COLUMN IF NOT EXISTS winning_distribution text;

-- Ensure match_players table exists
CREATE TABLE IF NOT EXISTS match_players (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  match_id uuid REFERENCES matches(id) ON DELETE CASCADE,
  player_id uuid REFERENCES players(id) ON DELETE CASCADE,
  team_id uuid REFERENCES teams(id) ON DELETE CASCADE,
  is_playing boolean DEFAULT true,
  points numeric DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  UNIQUE(match_id, player_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_match_players_match ON match_players(match_id);
CREATE INDEX IF NOT EXISTS idx_match_players_team ON match_players(team_id);
CREATE INDEX IF NOT EXISTS idx_scoreboard_match ON scoreboard(match_id);
CREATE INDEX IF NOT EXISTS idx_teams_tournament ON teams(tournament_id);
CREATE INDEX IF NOT EXISTS idx_players_team ON players(team_id);
CREATE INDEX IF NOT EXISTS idx_contests_match ON contests(match_id);

-- Storage buckets (run via Supabase dashboard or SQL editor)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('tournament-logos', 'tournament-logos', true) ON CONFLICT DO NOTHING;
-- INSERT INTO storage.buckets (id, name, public) VALUES ('team-logos', 'team-logos', true) ON CONFLICT DO NOTHING;
-- INSERT INTO storage.buckets (id, name, public) VALUES ('player-photos', 'player-photos', true) ON CONFLICT DO NOTHING;

-- RLS policies for storage (if not already created)
-- Allow authenticated users to upload to buckets
-- CREATE POLICY "Allow upload" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id IN ('tournament-logos', 'team-logos', 'player-photos'));
-- CREATE POLICY "Allow public read" ON storage.objects FOR SELECT TO public USING (bucket_id IN ('tournament-logos', 'team-logos', 'player-photos'));

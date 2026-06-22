-- =====================================================
-- PART 7: REALTIME RANKING TABLES + INDEXES + RLS + PUBLICATION
-- Run this AFTER parts 1-6 in Supabase SQL Editor
-- =====================================================

-- =====================================================
-- TABLE 1: ball_by_ball - Ball-by-ball match data
-- =====================================================
CREATE TABLE ball_by_ball (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  over_number INT NOT NULL,
  ball_number INT NOT NULL,
  batsman_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  bowler_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  runs INT NOT NULL DEFAULT 0,
  extras INT NOT NULL DEFAULT 0,
  extras_type TEXT,
  is_wicket BOOLEAN NOT NULL DEFAULT FALSE,
  wicket_type TEXT,
  fielder_id UUID REFERENCES players(id) ON DELETE SET NULL,
  is_boundary BOOLEAN NOT NULL DEFAULT FALSE,
  is_six BOOLEAN NOT NULL DEFAULT FALSE,
  commentary TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE 2: player_stats - Aggregated player statistics per match
-- =====================================================
CREATE TABLE player_stats (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  runs INT DEFAULT 0,
  balls_faced INT DEFAULT 0,
  fours INT DEFAULT 0,
  sixes INT DEFAULT 0,
  wickets INT DEFAULT 0,
  overs_bowled DECIMAL(4,1) DEFAULT 0,
  runs_conceded INT DEFAULT 0,
  maidens INT DEFAULT 0,
  catches INT DEFAULT 0,
  stumpings INT DEFAULT 0,
  run_outs INT DEFAULT 0,
  economy DECIMAL(5,2) DEFAULT 0,
  strike_rate DECIMAL(6,2) DEFAULT 0,
  fantasy_points DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(match_id, player_id)
);

-- =====================================================
-- TABLE 3: fantasy_points - Points breakdown per player per contest
-- =====================================================
CREATE TABLE fantasy_points (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
  contest_id UUID NOT NULL REFERENCES contests(id) ON DELETE CASCADE,
  fantasy_team_id UUID NOT NULL REFERENCES fantasy_teams(id) ON DELETE CASCADE,
  base_points DECIMAL(10,2) DEFAULT 0,
  captain_multiplier DECIMAL(3,1) DEFAULT 1.0,
  vice_captain_multiplier DECIMAL(3,1) DEFAULT 1.0,
  total_points DECIMAL(10,2) DEFAULT 0,
  breakdown JSONB,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE 4: contest_entries - User entries in contests with ranking
-- =====================================================
CREATE TABLE contest_entries (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  contest_id UUID NOT NULL REFERENCES contests(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  fantasy_team_id UUID NOT NULL REFERENCES fantasy_teams(id) ON DELETE CASCADE,
  total_points DECIMAL(10,2) DEFAULT 0,
  rank INT,
  prize_won DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(contest_id, user_id)
);

-- =====================================================
-- INDEXES
-- =====================================================
CREATE INDEX idx_ball_by_ball_match ON ball_by_ball(match_id);
CREATE INDEX idx_player_stats_match ON player_stats(match_id);
CREATE INDEX idx_player_stats_player ON player_stats(player_id);
CREATE INDEX idx_fantasy_points_match ON fantasy_points(match_id);
CREATE INDEX idx_fantasy_points_contest ON fantasy_points(contest_id);
CREATE INDEX idx_contest_entries_contest ON contest_entries(contest_id);
CREATE INDEX idx_contest_entries_user ON contest_entries(user_id);

-- =====================================================
-- ROW LEVEL SECURITY
-- =====================================================
ALTER TABLE ball_by_ball ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE fantasy_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE contest_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "read_all" ON ball_by_ball FOR SELECT USING (true);
CREATE POLICY "write_all" ON ball_by_ball FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON ball_by_ball FOR UPDATE USING (true);
CREATE POLICY "delete_all" ON ball_by_ball FOR DELETE USING (true);

CREATE POLICY "read_all" ON player_stats FOR SELECT USING (true);
CREATE POLICY "write_all" ON player_stats FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON player_stats FOR UPDATE USING (true);
CREATE POLICY "delete_all" ON player_stats FOR DELETE USING (true);

CREATE POLICY "read_all" ON fantasy_points FOR SELECT USING (true);
CREATE POLICY "write_all" ON fantasy_points FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON fantasy_points FOR UPDATE USING (true);
CREATE POLICY "delete_all" ON fantasy_points FOR DELETE USING (true);

CREATE POLICY "read_all" ON contest_entries FOR SELECT USING (true);
CREATE POLICY "write_all" ON contest_entries FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON contest_entries FOR UPDATE USING (true);
CREATE POLICY "delete_all" ON contest_entries FOR DELETE USING (true);

-- =====================================================
-- REALTIME PUBLICATION
-- =====================================================
ALTER PUBLICATION supabase_realtime ADD TABLE ball_by_ball;
ALTER PUBLICATION supabase_realtime ADD TABLE player_stats;
ALTER PUBLICATION supabase_realtime ADD TABLE fantasy_points;
ALTER PUBLICATION supabase_realtime ADD TABLE contest_entries;
ALTER PUBLICATION supabase_realtime ADD TABLE leaderboard;
ALTER PUBLICATION supabase_realtime ADD TABLE fantasy_teams;
ALTER PUBLICATION supabase_realtime ADD TABLE fantasy_team_players;

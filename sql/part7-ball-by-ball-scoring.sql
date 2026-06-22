-- =====================================================
-- PART 7: BALL-BY-BALL SCORING TABLE
-- Run this in Supabase SQL Editor after part6
-- =====================================================

-- Drop if exists for idempotency
DROP TABLE IF EXISTS ball_by_ball CASCADE;

CREATE TABLE ball_by_ball (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE NOT NULL,
  innings INTEGER NOT NULL,
  over_no INTEGER NOT NULL,
  ball_no INTEGER NOT NULL,
  batsman_id UUID REFERENCES players(id) ON DELETE SET NULL NOT NULL,
  non_striker_id UUID REFERENCES players(id) ON DELETE SET NULL NOT NULL,
  bowler_id UUID REFERENCES players(id) ON DELETE SET NULL NOT NULL,
  runs INTEGER NOT NULL DEFAULT 0,
  extras INTEGER DEFAULT 0,
  extras_type TEXT,
  is_wicket BOOLEAN DEFAULT false,
  dismissal_type TEXT,
  dismissed_player_id UUID REFERENCES players(id) ON DELETE SET NULL,
  fielder_id UUID REFERENCES players(id) ON DELETE SET NULL,
  is_legal BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for fast lookups
CREATE INDEX idx_ball_by_ball_match_id ON ball_by_ball(match_id);
CREATE INDEX idx_ball_by_ball_batsman_id ON ball_by_ball(batsman_id);
CREATE INDEX idx_ball_by_ball_bowler_id ON ball_by_ball(bowler_id);
CREATE INDEX idx_ball_by_ball_innings ON ball_by_ball(match_id, innings);

-- Enable realtime for live scoring updates
ALTER PUBLICATION supabase_realtime ADD TABLE ball_by_ball;

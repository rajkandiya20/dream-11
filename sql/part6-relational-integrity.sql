-- ============================================================
-- Part 6: Relational Integrity Constraints, Audit Logging & Indexes
-- Run this AFTER part4-admin-module-updates.sql has been applied.
--
-- This file enforces:
--   1. NOT NULL constraints on foreign key columns
--   2. CHECK constraints for business rules
--   3. Audit log table for tracking all data changes
--   4. Trigger functions and triggers for automatic audit logging
--   5. Indexes on foreign key columns for query performance
-- ============================================================

-- ============================================================
-- 1. NOT NULL CONSTRAINTS ON FOREIGN KEY COLUMNS
-- ============================================================

-- Teams must belong to a tournament
ALTER TABLE teams
  ALTER COLUMN tournament_id SET NOT NULL;

-- Players must belong to a team
ALTER TABLE players
  ALTER COLUMN team_id SET NOT NULL;

-- Matches must reference a tournament and both teams
ALTER TABLE matches
  ALTER COLUMN tournament_id SET NOT NULL;

ALTER TABLE matches
  ALTER COLUMN team_a_id SET NOT NULL;

ALTER TABLE matches
  ALTER COLUMN team_b_id SET NOT NULL;

-- Contests must reference a match
ALTER TABLE contests
  ALTER COLUMN match_id SET NOT NULL;

-- ============================================================
-- 2. CHECK CONSTRAINTS
-- ============================================================

-- A match cannot have the same team on both sides
ALTER TABLE matches
  ADD CONSTRAINT chk_matches_different_teams
  CHECK (team_a_id != team_b_id);

-- Contest entry fee must be non-negative
ALTER TABLE contests
  ADD CONSTRAINT chk_contests_entry_fee_non_negative
  CHECK (entry_fee >= 0);

-- Contest prize pool must be non-negative
ALTER TABLE contests
  ADD CONSTRAINT chk_contests_prize_pool_non_negative
  CHECK (prize_pool >= 0);

-- ============================================================
-- 3. AUDIT LOG TABLE
-- ============================================================

CREATE TABLE IF NOT EXISTS audit_log (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  table_name TEXT NOT NULL,
  operation TEXT NOT NULL,
  record_id TEXT NOT NULL,
  old_data JSONB,
  new_data JSONB,
  performed_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 4. TRIGGER FUNCTIONS AND TRIGGERS FOR AUDIT LOGGING
-- ============================================================

-- Generic audit trigger function that logs INSERT, UPDATE, DELETE
CREATE OR REPLACE FUNCTION fn_audit_log()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO audit_log (id, table_name, operation, record_id, old_data, new_data, performed_at)
    VALUES (uuid_generate_v4(), TG_TABLE_NAME, 'INSERT', NEW.id::TEXT, NULL, to_jsonb(NEW), NOW());
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_log (id, table_name, operation, record_id, old_data, new_data, performed_at)
    VALUES (uuid_generate_v4(), TG_TABLE_NAME, 'UPDATE', NEW.id::TEXT, to_jsonb(OLD), to_jsonb(NEW), NOW());
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO audit_log (id, table_name, operation, record_id, old_data, new_data, performed_at)
    VALUES (uuid_generate_v4(), TG_TABLE_NAME, 'DELETE', OLD.id::TEXT, to_jsonb(OLD), NULL, NOW());
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger on teams table
CREATE TRIGGER trg_teams_audit
  AFTER INSERT OR UPDATE OR DELETE ON teams
  FOR EACH ROW EXECUTE FUNCTION fn_audit_log();

-- Trigger on players table
CREATE TRIGGER trg_players_audit
  AFTER INSERT OR UPDATE OR DELETE ON players
  FOR EACH ROW EXECUTE FUNCTION fn_audit_log();

-- Trigger on matches table
CREATE TRIGGER trg_matches_audit
  AFTER INSERT OR UPDATE OR DELETE ON matches
  FOR EACH ROW EXECUTE FUNCTION fn_audit_log();

-- Trigger on contests table
CREATE TRIGGER trg_contests_audit
  AFTER INSERT OR UPDATE OR DELETE ON contests
  FOR EACH ROW EXECUTE FUNCTION fn_audit_log();

-- ============================================================
-- 5. INDEXES ON FOREIGN KEY COLUMNS
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_teams_tournament_id
  ON teams(tournament_id);

CREATE INDEX IF NOT EXISTS idx_players_team_id
  ON players(team_id);

CREATE INDEX IF NOT EXISTS idx_matches_tournament_id
  ON matches(tournament_id);

CREATE INDEX IF NOT EXISTS idx_matches_team_a_id
  ON matches(team_a_id);

CREATE INDEX IF NOT EXISTS idx_matches_team_b_id
  ON matches(team_b_id);

CREATE INDEX IF NOT EXISTS idx_contests_match_id
  ON contests(match_id);

-- ============================================================
-- End of Part 6
-- ============================================================

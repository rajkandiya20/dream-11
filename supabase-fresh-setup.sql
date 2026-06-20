-- =====================================================
-- DREAM11 LOCAL - FRESH DATABASE SETUP
-- This will DROP all existing tables and recreate them
-- Run this in Supabase SQL Editor
-- =====================================================

-- Step 1: DROP ALL EXISTING TABLES (in reverse dependency order)
DROP TABLE IF EXISTS scoreboard CASCADE;
DROP TABLE IF EXISTS leaderboard CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS wallets CASCADE;
DROP TABLE IF EXISTS group_members CASCADE;
DROP TABLE IF EXISTS groups CASCADE;
DROP TABLE IF EXISTS feed_posts CASCADE;
DROP TABLE IF EXISTS fantasy_team_players CASCADE;
DROP TABLE IF EXISTS fantasy_teams CASCADE;
DROP TABLE IF EXISTS contests CASCADE;
DROP TABLE IF EXISTS match_players CASCADE;
DROP TABLE IF EXISTS matches CASCADE;
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE IF EXISTS teams CASCADE;
DROP TABLE IF EXISTS tournaments CASCADE;
DROP TABLE IF EXISTS admins CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Step 2: Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- Step 3: CREATE ALL TABLES
-- =====================================================

CREATE TABLE users (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  uid TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  username TEXT,
  phone_number TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'user',
  balance DECIMAL(10,2) DEFAULT 0.00,
  total_amount_added DECIMAL(10,2) DEFAULT 0.00,
  total_amount_won DECIMAL(10,2) DEFAULT 0.00,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE admins (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  uid TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  role TEXT DEFAULT 'super_admin',
  permissions TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE tournaments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  logo TEXT,
  description TEXT,
  status TEXT DEFAULT 'upcoming',
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE teams (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  code TEXT NOT NULL,
  logo TEXT,
  flag TEXT,
  tournament_id UUID REFERENCES tournaments(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE players (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
  image TEXT,
  points DECIMAL(10,2) DEFAULT 0,
  credits DECIMAL(4,1) DEFAULT 8.0,
  is_playing BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE matches (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  tournament_id UUID REFERENCES tournaments(id) ON DELETE SET NULL,
  team_a_id UUID REFERENCES teams(id) ON DELETE SET NULL,
  team_b_id UUID REFERENCES teams(id) ON DELETE SET NULL,
  team_a_name TEXT NOT NULL,
  team_b_name TEXT NOT NULL,
  team_a_code TEXT,
  team_b_code TEXT,
  team_a_flag TEXT,
  team_b_flag TEXT,
  date_time TIMESTAMPTZ NOT NULL,
  venue TEXT,
  status TEXT DEFAULT 'upcoming',
  result TEXT,
  winner_team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
  team_a_score TEXT,
  team_b_score TEXT,
  live BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE match_players (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
  is_playing BOOLEAN DEFAULT true,
  points DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE contests (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  entry_fee DECIMAL(10,2) DEFAULT 0,
  prize_pool DECIMAL(10,2) DEFAULT 0,
  max_teams INTEGER DEFAULT 2,
  joined_teams INTEGER DEFAULT 0,
  contest_type TEXT DEFAULT 'paid',
  status TEXT DEFAULT 'open',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE fantasy_teams (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT NOT NULL,
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  contest_id UUID REFERENCES contests(id) ON DELETE SET NULL,
  team_name TEXT,
  captain_id UUID REFERENCES players(id) ON DELETE SET NULL,
  vice_captain_id UUID REFERENCES players(id) ON DELETE SET NULL,
  total_points DECIMAL(10,2) DEFAULT 0,
  rank INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE fantasy_team_players (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  fantasy_team_id UUID REFERENCES fantasy_teams(id) ON DELETE CASCADE,
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  is_captain BOOLEAN DEFAULT false,
  is_vice_captain BOOLEAN DEFAULT false,
  points DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE feed_posts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT NOT NULL,
  author_name TEXT,
  content TEXT NOT NULL,
  image_url TEXT,
  likes INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE groups (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  avatar_url TEXT,
  created_by TEXT NOT NULL,
  member_count INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE group_members (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  role TEXT DEFAULT 'member',
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(group_id, user_id)
);

CREATE TABLE wallets (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT UNIQUE NOT NULL,
  balance DECIMAL(10,2) DEFAULT 0.00,
  bonus DECIMAL(10,2) DEFAULT 0.00,
  winnings DECIMAL(10,2) DEFAULT 0.00,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE transactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT NOT NULL,
  type TEXT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  status TEXT DEFAULT 'pending',
  description TEXT,
  reference_id TEXT,
  payment_method TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'general',
  is_read BOOLEAN DEFAULT false,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE leaderboard (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  contest_id UUID REFERENCES contests(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  fantasy_team_id UUID REFERENCES fantasy_teams(id) ON DELETE SET NULL,
  points DECIMAL(10,2) DEFAULT 0,
  rank INTEGER,
  prize_won DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE scoreboard (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  runs INTEGER DEFAULT 0,
  wickets INTEGER DEFAULT 0,
  catches INTEGER DEFAULT 0,
  stumpings INTEGER DEFAULT 0,
  run_outs INTEGER DEFAULT 0,
  fours INTEGER DEFAULT 0,
  sixes INTEGER DEFAULT 0,
  balls_faced INTEGER DEFAULT 0,
  overs_bowled DECIMAL(4,1) DEFAULT 0,
  economy DECIMAL(5,2) DEFAULT 0,
  strike_rate DECIMAL(6,2) DEFAULT 0,
  points DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- Step 4: INDEXES
-- =====================================================
CREATE INDEX idx_users_uid ON users(uid);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_matches_status ON matches(status);
CREATE INDEX idx_matches_date ON matches(date_time);
CREATE INDEX idx_matches_tournament ON matches(tournament_id);
CREATE INDEX idx_players_team ON players(team_id);
CREATE INDEX idx_contests_match ON contests(match_id);
CREATE INDEX idx_fantasy_teams_user ON fantasy_teams(user_id);
CREATE INDEX idx_fantasy_teams_match ON fantasy_teams(match_id);
CREATE INDEX idx_feed_posts_created ON feed_posts(created_at DESC);
CREATE INDEX idx_group_members_user ON group_members(user_id);
CREATE INDEX idx_group_members_group ON group_members(group_id);
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_leaderboard_contest ON leaderboard(contest_id);
CREATE INDEX idx_scoreboard_match ON scoreboard(match_id);
CREATE INDEX idx_admins_email ON admins(email);

-- =====================================================
-- Step 5: ENABLE ROW LEVEL SECURITY
-- =====================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_players ENABLE ROW LEVEL SECURITY;
ALTER TABLE contests ENABLE ROW LEVEL SECURITY;
ALTER TABLE fantasy_teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE fantasy_team_players ENABLE ROW LEVEL SECURITY;
ALTER TABLE feed_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard ENABLE ROW LEVEL SECURITY;
ALTER TABLE scoreboard ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- Step 6: RLS POLICIES
-- =====================================================

-- Public read for all game data
CREATE POLICY "read_all" ON users FOR SELECT USING (true);
CREATE POLICY "read_all" ON admins FOR SELECT USING (true);
CREATE POLICY "read_all" ON tournaments FOR SELECT USING (true);
CREATE POLICY "read_all" ON teams FOR SELECT USING (true);
CREATE POLICY "read_all" ON players FOR SELECT USING (true);
CREATE POLICY "read_all" ON matches FOR SELECT USING (true);
CREATE POLICY "read_all" ON match_players FOR SELECT USING (true);
CREATE POLICY "read_all" ON contests FOR SELECT USING (true);
CREATE POLICY "read_all" ON fantasy_teams FOR SELECT USING (true);
CREATE POLICY "read_all" ON fantasy_team_players FOR SELECT USING (true);
CREATE POLICY "read_all" ON feed_posts FOR SELECT USING (true);
CREATE POLICY "read_all" ON groups FOR SELECT USING (true);
CREATE POLICY "read_all" ON group_members FOR SELECT USING (true);
CREATE POLICY "read_all" ON wallets FOR SELECT USING (true);
CREATE POLICY "read_all" ON transactions FOR SELECT USING (true);
CREATE POLICY "read_all" ON notifications FOR SELECT USING (true);
CREATE POLICY "read_all" ON leaderboard FOR SELECT USING (true);
CREATE POLICY "read_all" ON scoreboard FOR SELECT USING (true);

-- Write policies
CREATE POLICY "insert_all" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON users FOR UPDATE USING (true);
CREATE POLICY "insert_all" ON admins FOR INSERT WITH CHECK (true);
CREATE POLICY "insert_all" ON tournaments FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON tournaments FOR UPDATE USING (true);
CREATE POLICY "delete_all" ON tournaments FOR DELETE USING (true);
CREATE POLICY "insert_all" ON teams FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON teams FOR UPDATE USING (true);
CREATE POLICY "delete_all" ON teams FOR DELETE USING (true);
CREATE POLICY "insert_all" ON players FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON players FOR UPDATE USING (true);
CREATE POLICY "delete_all" ON players FOR DELETE USING (true);
CREATE POLICY "insert_all" ON matches FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON matches FOR UPDATE USING (true);
CREATE POLICY "delete_all" ON matches FOR DELETE USING (true);
CREATE POLICY "insert_all" ON match_players FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON match_players FOR UPDATE USING (true);
CREATE POLICY "delete_all" ON match_players FOR DELETE USING (true);
CREATE POLICY "insert_all" ON contests FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON contests FOR UPDATE USING (true);
CREATE POLICY "delete_all" ON contests FOR DELETE USING (true);
CREATE POLICY "insert_all" ON fantasy_teams FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON fantasy_teams FOR UPDATE USING (true);
CREATE POLICY "insert_all" ON fantasy_team_players FOR INSERT WITH CHECK (true);
CREATE POLICY "insert_all" ON feed_posts FOR INSERT WITH CHECK (true);
CREATE POLICY "insert_all" ON groups FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON groups FOR UPDATE USING (true);
CREATE POLICY "insert_all" ON group_members FOR INSERT WITH CHECK (true);
CREATE POLICY "delete_all" ON group_members FOR DELETE USING (true);
CREATE POLICY "insert_all" ON wallets FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON wallets FOR UPDATE USING (true);
CREATE POLICY "insert_all" ON transactions FOR INSERT WITH CHECK (true);
CREATE POLICY "insert_all" ON notifications FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON notifications FOR UPDATE USING (true);
CREATE POLICY "insert_all" ON leaderboard FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON leaderboard FOR UPDATE USING (true);
CREATE POLICY "insert_all" ON scoreboard FOR INSERT WITH CHECK (true);
CREATE POLICY "update_all" ON scoreboard FOR UPDATE USING (true);
CREATE POLICY "delete_all" ON scoreboard FOR DELETE USING (true);

-- =====================================================
-- Step 7: ENABLE REALTIME for admin-managed tables
-- =====================================================
ALTER PUBLICATION supabase_realtime ADD TABLE matches;
ALTER PUBLICATION supabase_realtime ADD TABLE tournaments;
ALTER PUBLICATION supabase_realtime ADD TABLE contests;
ALTER PUBLICATION supabase_realtime ADD TABLE players;
ALTER PUBLICATION supabase_realtime ADD TABLE scoreboard;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE teams;

-- =====================================================
-- Step 8: TEST DATA (Real IPL Data)
-- Replace FIREBASE_UID_HERE with your actual Firebase Auth UID
-- =====================================================

-- Admin
INSERT INTO admins (uid, email, role, permissions) VALUES
('FIREBASE_UID_HERE', 'rexoagency.in@gmail.com', 'super_admin', 
  ARRAY['full_access','user_management','tournament_management','match_management','player_management','contest_management','wallet_management','transaction_management','notification_management','database_management']);

-- Test User
INSERT INTO users (uid, email, username, phone_number, role, balance) VALUES
('test_user_001', 'testplayer@dream11.com', 'CricketFan99', '+919876543210', 'user', 500.00);

-- Tournament: IPL 2024
INSERT INTO tournaments (id, name, logo, description, status, start_date, end_date) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'IPL 2024', 'https://www.iplt20.com/assets/images/ipl-logo-new.svg', 'Indian Premier League 2024 Season', 'live', '2024-03-22T00:00:00Z', '2024-05-26T00:00:00Z');

-- Teams
INSERT INTO teams (id, name, code, logo, flag, tournament_id) VALUES
('660e8400-e29b-41d4-a716-446655440001', 'Mumbai Indians', 'MI', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/MI/Logos/Roundbig/MIroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/MI/Logos/Roundbig/MIroundbig.png', '550e8400-e29b-41d4-a716-446655440001'),
('660e8400-e29b-41d4-a716-446655440002', 'Chennai Super Kings', 'CSK', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/CSK/logos/Roundbig/CSKroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/CSK/logos/Roundbig/CSKroundbig.png', '550e8400-e29b-41d4-a716-446655440001'),
('660e8400-e29b-41d4-a716-446655440003', 'Royal Challengers Bengaluru', 'RCB', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/RCB/Logos/Roundbig/RCBroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/RCB/Logos/Roundbig/RCBroundbig.png', '550e8400-e29b-41d4-a716-446655440001'),
('660e8400-e29b-41d4-a716-446655440004', 'Kolkata Knight Riders', 'KKR', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/KKR/Logos/Roundbig/KKRroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/KKR/Logos/Roundbig/KKRroundbig.png', '550e8400-e29b-41d4-a716-446655440001');

-- Players MI
INSERT INTO players (id, name, role, team_id, credits, is_playing) VALUES
('770e8400-e29b-41d4-a716-446655440001', 'Rohit Sharma', 'Batsman', '660e8400-e29b-41d4-a716-446655440001', 10.0, true),
('770e8400-e29b-41d4-a716-446655440002', 'Jasprit Bumrah', 'Bowler', '660e8400-e29b-41d4-a716-446655440001', 9.5, true),
('770e8400-e29b-41d4-a716-446655440003', 'Suryakumar Yadav', 'Batsman', '660e8400-e29b-41d4-a716-446655440001', 9.5, true),
('770e8400-e29b-41d4-a716-446655440004', 'Ishan Kishan', 'WK', '660e8400-e29b-41d4-a716-446655440001', 8.5, true),
('770e8400-e29b-41d4-a716-446655440005', 'Hardik Pandya', 'All-rounder', '660e8400-e29b-41d4-a716-446655440001', 9.0, true);

-- Players CSK
INSERT INTO players (id, name, role, team_id, credits, is_playing) VALUES
('770e8400-e29b-41d4-a716-446655440006', 'MS Dhoni', 'WK', '660e8400-e29b-41d4-a716-446655440002', 8.5, true),
('770e8400-e29b-41d4-a716-446655440007', 'Ruturaj Gaikwad', 'Batsman', '660e8400-e29b-41d4-a716-446655440002', 9.5, true),
('770e8400-e29b-41d4-a716-446655440008', 'Ravindra Jadeja', 'All-rounder', '660e8400-e29b-41d4-a716-446655440002', 9.0, true),
('770e8400-e29b-41d4-a716-446655440009', 'Devon Conway', 'Batsman', '660e8400-e29b-41d4-a716-446655440002', 9.0, true),
('770e8400-e29b-41d4-a716-44665544000a', 'Matheesha Pathirana', 'Bowler', '660e8400-e29b-41d4-a716-446655440002', 8.5, true);

-- Players RCB
INSERT INTO players (id, name, role, team_id, credits, is_playing) VALUES
('770e8400-e29b-41d4-a716-44665544000b', 'Virat Kohli', 'Batsman', '660e8400-e29b-41d4-a716-446655440003', 10.5, true),
('770e8400-e29b-41d4-a716-44665544000c', 'Faf du Plessis', 'Batsman', '660e8400-e29b-41d4-a716-446655440003', 9.0, true),
('770e8400-e29b-41d4-a716-44665544000d', 'Glenn Maxwell', 'All-rounder', '660e8400-e29b-41d4-a716-446655440003', 9.0, true);

-- Players KKR
INSERT INTO players (id, name, role, team_id, credits, is_playing) VALUES
('770e8400-e29b-41d4-a716-44665544000e', 'Shreyas Iyer', 'Batsman', '660e8400-e29b-41d4-a716-446655440004', 9.5, true),
('770e8400-e29b-41d4-a716-44665544000f', 'Andre Russell', 'All-rounder', '660e8400-e29b-41d4-a716-446655440004', 9.5, true),
('770e8400-e29b-41d4-a716-446655440010', 'Sunil Narine', 'All-rounder', '660e8400-e29b-41d4-a716-446655440004', 9.0, true);

-- Matches
INSERT INTO matches (id, tournament_id, team_a_id, team_b_id, team_a_name, team_b_name, team_a_code, team_b_code, team_a_flag, team_b_flag, date_time, venue, status, live) VALUES
('880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440002', 'Mumbai Indians', 'Chennai Super Kings', 'MI', 'CSK', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/MI/Logos/Roundbig/MIroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/CSK/logos/Roundbig/CSKroundbig.png', '2025-07-15T19:30:00Z', 'Wankhede Stadium, Mumbai', 'upcoming', false),
('880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440004', 'Royal Challengers Bengaluru', 'Kolkata Knight Riders', 'RCB', 'KKR', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/RCB/Logos/Roundbig/RCBroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/KKR/Logos/Roundbig/KKRroundbig.png', '2025-07-16T15:30:00Z', 'M. Chinnaswamy Stadium, Bengaluru', 'upcoming', false),
('880e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440004', 'Mumbai Indians', 'Kolkata Knight Riders', 'MI', 'KKR', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/MI/Logos/Roundbig/MIroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/KKR/Logos/Roundbig/KKRroundbig.png', '2025-04-10T19:30:00Z', 'Wankhede Stadium, Mumbai', 'completed', false);

-- Contests
INSERT INTO contests (id, match_id, name, entry_fee, prize_pool, max_teams, joined_teams, contest_type, status) VALUES
('990e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440001', 'Mega Contest', 49.00, 10000.00, 500, 234, 'paid', 'open'),
('990e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440001', 'Head to Head', 25.00, 45.00, 2, 1, 'paid', 'open'),
('990e8400-e29b-41d4-a716-446655440003', '880e8400-e29b-41d4-a716-446655440002', 'Winner Takes All', 99.00, 25000.00, 300, 156, 'paid', 'open');

-- Feed Posts
INSERT INTO feed_posts (user_id, author_name, content, likes, created_at) VALUES
('test_user_001', 'CricketFan99', 'MI vs CSK is going to be epic! Rohit Sharma in great form this season.', 12, NOW() - INTERVAL '2 hours'),
('test_user_001', 'CricketFan99', 'Just won 500 rupees in the KKR vs RCB mega contest! Andre Russell as captain!', 24, NOW() - INTERVAL '1 day'),
('FIREBASE_UID_HERE', 'Admin', 'Welcome to Dream11 Local! Create your fantasy teams and compete with friends.', 45, NOW() - INTERVAL '3 days');

-- Groups
INSERT INTO groups (id, name, description, created_by, member_count) VALUES
('aa0e8400-e29b-41d4-a716-446655440001', 'IPL Fantasy League', 'Share tips, discuss strategies!', 'test_user_001', 3),
('aa0e8400-e29b-41d4-a716-446655440002', 'Mumbai Indians Fans', 'MI Paltan!', 'test_user_001', 2);

-- Group Members
INSERT INTO group_members (group_id, user_id, role) VALUES
('aa0e8400-e29b-41d4-a716-446655440001', 'test_user_001', 'admin'),
('aa0e8400-e29b-41d4-a716-446655440001', 'FIREBASE_UID_HERE', 'member'),
('aa0e8400-e29b-41d4-a716-446655440002', 'test_user_001', 'admin');

-- Wallet
INSERT INTO wallets (user_id, balance, bonus, winnings) VALUES
('test_user_001', 500.00, 50.00, 1200.00);

-- Transactions
INSERT INTO transactions (user_id, type, amount, status, description, payment_method, created_at) VALUES
('test_user_001', 'deposit', 500.00, 'completed', 'Added cash via UPI', 'upi', NOW() - INTERVAL '5 days'),
('test_user_001', 'contest_join', 49.00, 'completed', 'Joined Mega Contest - MI vs CSK', 'wallet', NOW() - INTERVAL '2 days'),
('test_user_001', 'winning', 1200.00, 'completed', 'Won Mega Contest - KKR vs RCB', 'wallet', NOW() - INTERVAL '1 day');

-- Notifications
INSERT INTO notifications (user_id, title, message, type, is_read, created_at) VALUES
('test_user_001', 'Contest Won!', 'You won Rs.1200 in KKR vs RCB Mega Contest. Rank: #3', 'winning', false, NOW() - INTERVAL '1 day'),
('test_user_001', 'Match Starting Soon', 'MI vs CSK starts in 30 minutes. Create your team!', 'match', false, NOW() - INTERVAL '2 hours'),
('test_user_001', 'Welcome Bonus', 'Rs.50 welcome bonus credited!', 'bonus', true, NOW() - INTERVAL '5 days');

-- Scoreboard (completed match)
INSERT INTO scoreboard (match_id, player_id, runs, wickets, catches, fours, sixes, balls_faced, points) VALUES
('880e8400-e29b-41d4-a716-446655440003', '770e8400-e29b-41d4-a716-446655440001', 78, 0, 1, 8, 4, 52, 85.5),
('880e8400-e29b-41d4-a716-446655440003', '770e8400-e29b-41d4-a716-446655440003', 45, 0, 0, 5, 2, 30, 52.0),
('880e8400-e29b-41d4-a716-446655440003', '770e8400-e29b-41d4-a716-446655440002', 2, 3, 0, 0, 0, 6, 78.0),
('880e8400-e29b-41d4-a716-446655440003', '770e8400-e29b-41d4-a716-44665544000e', 62, 0, 2, 6, 3, 44, 71.0),
('880e8400-e29b-41d4-a716-446655440003', '770e8400-e29b-41d4-a716-44665544000f', 35, 1, 1, 2, 3, 18, 65.0);

-- =====================================================
-- DONE! All tables created with test data.
-- Remember to replace FIREBASE_UID_HERE with your actual UID
-- =====================================================

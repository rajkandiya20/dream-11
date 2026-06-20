-- =====================================================
-- DREAM11 LOCAL - SUPABASE DATABASE SCHEMA
-- Run this SQL in Supabase SQL Editor
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABLE: users
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
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

-- =====================================================
-- TABLE: admins
-- =====================================================
CREATE TABLE IF NOT EXISTS admins (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  uid TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  role TEXT DEFAULT 'super_admin',
  permissions TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE: tournaments
-- =====================================================
CREATE TABLE IF NOT EXISTS tournaments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  logo TEXT,
  description TEXT,
  status TEXT DEFAULT 'upcoming',
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE: teams
-- =====================================================
CREATE TABLE IF NOT EXISTS teams (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  code TEXT NOT NULL,
  logo TEXT,
  flag TEXT,
  tournament_id UUID REFERENCES tournaments(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE: players
-- =====================================================
CREATE TABLE IF NOT EXISTS players (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  team_id UUID REFERENCES teams(id),
  image TEXT,
  points DECIMAL(10,2) DEFAULT 0,
  credits DECIMAL(4,1) DEFAULT 8.0,
  is_playing BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE: matches
-- =====================================================
CREATE TABLE IF NOT EXISTS matches (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  tournament_id UUID REFERENCES tournaments(id),
  team_a_id UUID REFERENCES teams(id),
  team_b_id UUID REFERENCES teams(id),
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
  winner_team_id UUID REFERENCES teams(id),
  team_a_score TEXT,
  team_b_score TEXT,
  live BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE: match_players (players selected for a match)
-- =====================================================
CREATE TABLE IF NOT EXISTS match_players (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  player_id UUID REFERENCES players(id),
  team_id UUID REFERENCES teams(id),
  is_playing BOOLEAN DEFAULT true,
  points DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE: contests
-- =====================================================
CREATE TABLE IF NOT EXISTS contests (
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

-- =====================================================
-- TABLE: fantasy_teams
-- =====================================================
CREATE TABLE IF NOT EXISTS fantasy_teams (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT NOT NULL,
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  contest_id UUID REFERENCES contests(id),
  team_name TEXT,
  captain_id UUID REFERENCES players(id),
  vice_captain_id UUID REFERENCES players(id),
  total_points DECIMAL(10,2) DEFAULT 0,
  rank INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE: fantasy_team_players
-- =====================================================
CREATE TABLE IF NOT EXISTS fantasy_team_players (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  fantasy_team_id UUID REFERENCES fantasy_teams(id) ON DELETE CASCADE,
  player_id UUID REFERENCES players(id),
  is_captain BOOLEAN DEFAULT false,
  is_vice_captain BOOLEAN DEFAULT false,
  points DECIMAL(10,2) DEFAULT 0
);

-- =====================================================
-- TABLE: feed_posts
-- =====================================================
CREATE TABLE IF NOT EXISTS feed_posts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT NOT NULL,
  author_name TEXT,
  content TEXT NOT NULL,
  image_url TEXT,
  likes INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE: groups
-- =====================================================
CREATE TABLE IF NOT EXISTS groups (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  avatar_url TEXT,
  created_by TEXT NOT NULL,
  member_count INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE: group_members
-- =====================================================
CREATE TABLE IF NOT EXISTS group_members (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  role TEXT DEFAULT 'member',
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(group_id, user_id)
);

-- =====================================================
-- TABLE: wallets
-- =====================================================
CREATE TABLE IF NOT EXISTS wallets (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT UNIQUE NOT NULL,
  balance DECIMAL(10,2) DEFAULT 0.00,
  bonus DECIMAL(10,2) DEFAULT 0.00,
  winnings DECIMAL(10,2) DEFAULT 0.00,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE: transactions
-- =====================================================
CREATE TABLE IF NOT EXISTS transactions (
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

-- =====================================================
-- TABLE: notifications
-- =====================================================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'general',
  is_read BOOLEAN DEFAULT false,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE: leaderboard
-- =====================================================
CREATE TABLE IF NOT EXISTS leaderboard (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  contest_id UUID REFERENCES contests(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  fantasy_team_id UUID REFERENCES fantasy_teams(id),
  points DECIMAL(10,2) DEFAULT 0,
  rank INTEGER,
  prize_won DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE: scoreboard
-- =====================================================
CREATE TABLE IF NOT EXISTS scoreboard (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  player_id UUID REFERENCES players(id),
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
-- INDEXES
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_users_uid ON users(uid);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_matches_status ON matches(status);
CREATE INDEX IF NOT EXISTS idx_matches_date ON matches(date_time);
CREATE INDEX IF NOT EXISTS idx_matches_tournament ON matches(tournament_id);
CREATE INDEX IF NOT EXISTS idx_players_team ON players(team_id);
CREATE INDEX IF NOT EXISTS idx_contests_match ON contests(match_id);
CREATE INDEX IF NOT EXISTS idx_fantasy_teams_user ON fantasy_teams(user_id);
CREATE INDEX IF NOT EXISTS idx_fantasy_teams_match ON fantasy_teams(match_id);
CREATE INDEX IF NOT EXISTS idx_feed_posts_user ON feed_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_feed_posts_created ON feed_posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_group_members_user ON group_members(user_id);
CREATE INDEX IF NOT EXISTS idx_group_members_group ON group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_created ON transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_leaderboard_contest ON leaderboard(contest_id);
CREATE INDEX IF NOT EXISTS idx_scoreboard_match ON scoreboard(match_id);
CREATE INDEX IF NOT EXISTS idx_admins_email ON admins(email);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
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

-- RLS Policies - Allow public read for game data
CREATE POLICY "Public read tournaments" ON tournaments FOR SELECT USING (true);
CREATE POLICY "Public read teams" ON teams FOR SELECT USING (true);
CREATE POLICY "Public read players" ON players FOR SELECT USING (true);
CREATE POLICY "Public read matches" ON matches FOR SELECT USING (true);
CREATE POLICY "Public read match_players" ON match_players FOR SELECT USING (true);
CREATE POLICY "Public read contests" ON contests FOR SELECT USING (true);
CREATE POLICY "Public read leaderboard" ON leaderboard FOR SELECT USING (true);
CREATE POLICY "Public read scoreboard" ON scoreboard FOR SELECT USING (true);
CREATE POLICY "Public read feed_posts" ON feed_posts FOR SELECT USING (true);
CREATE POLICY "Public read users" ON users FOR SELECT USING (true);
CREATE POLICY "Public read groups" ON groups FOR SELECT USING (true);
CREATE POLICY "Public read group_members" ON group_members FOR SELECT USING (true);
CREATE POLICY "Public read admins" ON admins FOR SELECT USING (true);
CREATE POLICY "Public read fantasy_teams" ON fantasy_teams FOR SELECT USING (true);
CREATE POLICY "Public read fantasy_team_players" ON fantasy_team_players FOR SELECT USING (true);
CREATE POLICY "Public read wallets" ON wallets FOR SELECT USING (true);
CREATE POLICY "Public read transactions" ON transactions FOR SELECT USING (true);
CREATE POLICY "Public read notifications" ON notifications FOR SELECT USING (true);

-- Allow inserts/updates for anon key (for app usage)
CREATE POLICY "Allow insert users" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update users" ON users FOR UPDATE USING (true);
CREATE POLICY "Allow insert feed_posts" ON feed_posts FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow insert fantasy_teams" ON fantasy_teams FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow insert fantasy_team_players" ON fantasy_team_players FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow insert groups" ON groups FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow insert group_members" ON group_members FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update notifications" ON notifications FOR UPDATE USING (true);
CREATE POLICY "Allow insert notifications" ON notifications FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow insert transactions" ON transactions FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow insert wallets" ON wallets FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow update wallets" ON wallets FOR UPDATE USING (true);

-- =====================================================
-- TEST DATA - Real IPL 2024 Data
-- =====================================================

-- Admin entry
INSERT INTO admins (uid, email, role, permissions) VALUES
('FIREBASE_UID_HERE', 'rexoagency.in@gmail.com', 'super_admin', 
  ARRAY['full_access', 'user_management', 'tournament_management', 'match_management', 'player_management', 'contest_management', 'wallet_management', 'transaction_management', 'notification_management', 'database_management']
);

-- Test User
INSERT INTO users (uid, email, username, phone_number, role, balance) VALUES
('test_user_001', 'testplayer@dream11.com', 'CricketFan99', '+919876543210', 'user', 500.00);

-- Tournament
INSERT INTO tournaments (id, name, logo, description, status, start_date, end_date) VALUES
('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'IPL 2024', 'https://www.iplt20.com/assets/images/ipl-logo-new.svg', 'Indian Premier League 2024 Season', 'live', '2024-03-22T00:00:00Z', '2024-05-26T00:00:00Z');

-- Teams
INSERT INTO teams (id, name, code, logo, flag, tournament_id) VALUES
('t001-0000-0000-0000-000000000001', 'Mumbai Indians', 'MI', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/MI/Logos/Roundbig/MIroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/MI/Logos/Roundbig/MIroundbig.png', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'),
('t001-0000-0000-0000-000000000002', 'Chennai Super Kings', 'CSK', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/CSK/logos/Roundbig/CSKroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/CSK/logos/Roundbig/CSKroundbig.png', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'),
('t001-0000-0000-0000-000000000003', 'Royal Challengers Bengaluru', 'RCB', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/RCB/Logos/Roundbig/RCBroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/RCB/Logos/Roundbig/RCBroundbig.png', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'),
('t001-0000-0000-0000-000000000004', 'Kolkata Knight Riders', 'KKR', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/KKR/Logos/Roundbig/KKRroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/KKR/Logos/Roundbig/KKRroundbig.png', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');

-- Players (MI)
INSERT INTO players (id, name, role, team_id, credits, is_playing) VALUES
('p001-0000-0000-0000-000000000001', 'Rohit Sharma', 'Batsman', 't001-0000-0000-0000-000000000001', 10.0, true),
('p001-0000-0000-0000-000000000002', 'Jasprit Bumrah', 'Bowler', 't001-0000-0000-0000-000000000001', 9.5, true),
('p001-0000-0000-0000-000000000003', 'Suryakumar Yadav', 'Batsman', 't001-0000-0000-0000-000000000001', 9.5, true),
('p001-0000-0000-0000-000000000004', 'Ishan Kishan', 'WK', 't001-0000-0000-0000-000000000001', 8.5, true),
('p001-0000-0000-0000-000000000005', 'Hardik Pandya', 'All-rounder', 't001-0000-0000-0000-000000000001', 9.0, true);

-- Players (CSK)
INSERT INTO players (id, name, role, team_id, credits, is_playing) VALUES
('p002-0000-0000-0000-000000000001', 'MS Dhoni', 'WK', 't001-0000-0000-0000-000000000002', 8.5, true),
('p002-0000-0000-0000-000000000002', 'Ruturaj Gaikwad', 'Batsman', 't001-0000-0000-0000-000000000002', 9.5, true),
('p002-0000-0000-0000-000000000003', 'Ravindra Jadeja', 'All-rounder', 't001-0000-0000-0000-000000000002', 9.0, true),
('p002-0000-0000-0000-000000000004', 'Devon Conway', 'Batsman', 't001-0000-0000-0000-000000000002', 9.0, true),
('p002-0000-0000-0000-000000000005', 'Matheesha Pathirana', 'Bowler', 't001-0000-0000-0000-000000000002', 8.5, true);

-- Players (RCB)
INSERT INTO players (id, name, role, team_id, credits, is_playing) VALUES
('p003-0000-0000-0000-000000000001', 'Virat Kohli', 'Batsman', 't001-0000-0000-0000-000000000003', 10.5, true),
('p003-0000-0000-0000-000000000002', 'Faf du Plessis', 'Batsman', 't001-0000-0000-0000-000000000003', 9.0, true),
('p003-0000-0000-0000-000000000003', 'Glenn Maxwell', 'All-rounder', 't001-0000-0000-0000-000000000003', 9.0, true);

-- Players (KKR)
INSERT INTO players (id, name, role, team_id, credits, is_playing) VALUES
('p004-0000-0000-0000-000000000001', 'Shreyas Iyer', 'Batsman', 't001-0000-0000-0000-000000000004', 9.5, true),
('p004-0000-0000-0000-000000000002', 'Andre Russell', 'All-rounder', 't001-0000-0000-0000-000000000004', 9.5, true),
('p004-0000-0000-0000-000000000003', 'Sunil Narine', 'All-rounder', 't001-0000-0000-0000-000000000004', 9.0, true);

-- Matches
INSERT INTO matches (id, tournament_id, team_a_id, team_b_id, team_a_name, team_b_name, team_a_code, team_b_code, team_a_flag, team_b_flag, date_time, venue, status, live) VALUES
('m001-0000-0000-0000-000000000001', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 't001-0000-0000-0000-000000000001', 't001-0000-0000-0000-000000000002', 'Mumbai Indians', 'Chennai Super Kings', 'MI', 'CSK', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/MI/Logos/Roundbig/MIroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/CSK/logos/Roundbig/CSKroundbig.png', '2024-07-15T19:30:00Z', 'Wankhede Stadium, Mumbai', 'upcoming', false),
('m001-0000-0000-0000-000000000002', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 't001-0000-0000-0000-000000000003', 't001-0000-0000-0000-000000000004', 'Royal Challengers Bengaluru', 'Kolkata Knight Riders', 'RCB', 'KKR', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/RCB/Logos/Roundbig/RCBroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/KKR/Logos/Roundbig/KKRroundbig.png', '2024-07-16T15:30:00Z', 'M. Chinnaswamy Stadium, Bengaluru', 'upcoming', false),
('m001-0000-0000-0000-000000000003', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 't001-0000-0000-0000-000000000001', 't001-0000-0000-0000-000000000004', 'Mumbai Indians', 'Kolkata Knight Riders', 'MI', 'KKR', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/MI/Logos/Roundbig/MIroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/KKR/Logos/Roundbig/KKRroundbig.png', '2024-04-10T19:30:00Z', 'Wankhede Stadium, Mumbai', 'completed', false);

-- Contests
INSERT INTO contests (id, match_id, name, entry_fee, prize_pool, max_teams, joined_teams, contest_type, status) VALUES
('c001-0000-0000-0000-000000000001', 'm001-0000-0000-0000-000000000001', 'Mega Contest', 49.00, 10000.00, 500, 234, 'paid', 'open'),
('c001-0000-0000-0000-000000000002', 'm001-0000-0000-0000-000000000001', 'Head to Head', 25.00, 45.00, 2, 1, 'paid', 'open'),
('c001-0000-0000-0000-000000000003', 'm001-0000-0000-0000-000000000002', 'Winner Takes All', 99.00, 25000.00, 300, 156, 'paid', 'open');

-- Feed Posts
INSERT INTO feed_posts (user_id, author_name, content, likes, created_at) VALUES
('test_user_001', 'CricketFan99', 'MI vs CSK is going to be epic! Rohit Sharma in great form this season. Who else is creating teams for this match?', 12, NOW() - INTERVAL '2 hours'),
('test_user_001', 'CricketFan99', 'Just won 500 rupees in the KKR vs RCB mega contest! My strategy of picking Andre Russell as captain paid off big time!', 24, NOW() - INTERVAL '1 day'),
('FIREBASE_UID_HERE', 'Admin', 'Welcome to Dream11 Local! Create your fantasy teams and compete with friends. New contests added daily.', 45, NOW() - INTERVAL '3 days');

-- Groups
INSERT INTO groups (id, name, description, created_by, member_count) VALUES
('g001-0000-0000-0000-000000000001', 'IPL Fantasy League', 'A group for IPL fantasy cricket enthusiasts. Share tips, discuss strategies!', 'test_user_001', 3),
('g001-0000-0000-0000-000000000002', 'Mumbai Indians Fans', 'Official MI supporters group. Paltan!', 'test_user_001', 2);

-- Group Members
INSERT INTO group_members (group_id, user_id, role) VALUES
('g001-0000-0000-0000-000000000001', 'test_user_001', 'admin'),
('g001-0000-0000-0000-000000000001', 'FIREBASE_UID_HERE', 'member'),
('g001-0000-0000-0000-000000000002', 'test_user_001', 'admin');

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
('test_user_001', 'Contest Won!', 'Congratulations! You won Rs.1200 in the KKR vs RCB Mega Contest. Your rank: #3', 'winning', false, NOW() - INTERVAL '1 day'),
('test_user_001', 'Match Starting Soon', 'MI vs CSK match starts in 30 minutes. Create your team now!', 'match', false, NOW() - INTERVAL '2 hours'),
('test_user_001', 'Welcome Bonus', 'You received Rs.50 as welcome bonus! Use it to join contests.', 'bonus', true, NOW() - INTERVAL '5 days');

-- Scoreboard (for completed match)
INSERT INTO scoreboard (match_id, player_id, runs, wickets, catches, fours, sixes, balls_faced, points) VALUES
('m001-0000-0000-0000-000000000003', 'p001-0000-0000-0000-000000000001', 78, 0, 1, 8, 4, 52, 85.5),
('m001-0000-0000-0000-000000000003', 'p001-0000-0000-0000-000000000003', 45, 0, 0, 5, 2, 30, 52.0),
('m001-0000-0000-0000-000000000003', 'p001-0000-0000-0000-000000000002', 2, 3, 0, 0, 0, 6, 78.0),
('m001-0000-0000-0000-000000000003', 'p004-0000-0000-0000-000000000001', 62, 0, 2, 6, 3, 44, 71.0),
('m001-0000-0000-0000-000000000003', 'p004-0000-0000-0000-000000000002', 35, 1, 1, 2, 3, 18, 65.0);

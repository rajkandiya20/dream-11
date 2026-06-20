-- =====================================================
-- PART 3: TEST DATA
-- Run this THIRD in Supabase SQL Editor
-- Replace FIREBASE_UID_HERE with your actual Firebase Auth UID
-- =====================================================

INSERT INTO admins (uid, email, role, permissions) VALUES
('FIREBASE_UID_HERE', 'rexoagency.in@gmail.com', 'super_admin', ARRAY['full_access','user_management','tournament_management','match_management','player_management','contest_management','wallet_management','transaction_management','notification_management','database_management']);

INSERT INTO users (uid, email, username, phone_number, role, balance) VALUES
('test_user_001', 'testplayer@dream11.com', 'CricketFan99', '+919876543210', 'user', 500.00);

INSERT INTO tournaments (id, name, logo, description, status, start_date, end_date) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'IPL 2024', 'https://www.iplt20.com/assets/images/ipl-logo-new.svg', 'Indian Premier League 2024', 'live', '2024-03-22T00:00:00Z', '2024-05-26T00:00:00Z');

INSERT INTO teams (id, name, code, logo, flag, tournament_id) VALUES
('660e8400-e29b-41d4-a716-446655440001', 'Mumbai Indians', 'MI', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/MI/Logos/Roundbig/MIroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/MI/Logos/Roundbig/MIroundbig.png', '550e8400-e29b-41d4-a716-446655440001'),
('660e8400-e29b-41d4-a716-446655440002', 'Chennai Super Kings', 'CSK', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/CSK/logos/Roundbig/CSKroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/CSK/logos/Roundbig/CSKroundbig.png', '550e8400-e29b-41d4-a716-446655440001'),
('660e8400-e29b-41d4-a716-446655440003', 'Royal Challengers Bengaluru', 'RCB', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/RCB/Logos/Roundbig/RCBroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/RCB/Logos/Roundbig/RCBroundbig.png', '550e8400-e29b-41d4-a716-446655440001'),
('660e8400-e29b-41d4-a716-446655440004', 'Kolkata Knight Riders', 'KKR', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/KKR/Logos/Roundbig/KKRroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/KKR/Logos/Roundbig/KKRroundbig.png', '550e8400-e29b-41d4-a716-446655440001');

INSERT INTO players (id, name, role, team_id, credits, is_playing) VALUES
('770e8400-e29b-41d4-a716-446655440001', 'Rohit Sharma', 'Batsman', '660e8400-e29b-41d4-a716-446655440001', 10.0, true),
('770e8400-e29b-41d4-a716-446655440002', 'Jasprit Bumrah', 'Bowler', '660e8400-e29b-41d4-a716-446655440001', 9.5, true),
('770e8400-e29b-41d4-a716-446655440003', 'Suryakumar Yadav', 'Batsman', '660e8400-e29b-41d4-a716-446655440001', 9.5, true),
('770e8400-e29b-41d4-a716-446655440004', 'Ishan Kishan', 'WK', '660e8400-e29b-41d4-a716-446655440001', 8.5, true),
('770e8400-e29b-41d4-a716-446655440005', 'Hardik Pandya', 'All-rounder', '660e8400-e29b-41d4-a716-446655440001', 9.0, true),
('770e8400-e29b-41d4-a716-446655440006', 'MS Dhoni', 'WK', '660e8400-e29b-41d4-a716-446655440002', 8.5, true),
('770e8400-e29b-41d4-a716-446655440007', 'Ruturaj Gaikwad', 'Batsman', '660e8400-e29b-41d4-a716-446655440002', 9.5, true),
('770e8400-e29b-41d4-a716-446655440008', 'Ravindra Jadeja', 'All-rounder', '660e8400-e29b-41d4-a716-446655440002', 9.0, true),
('770e8400-e29b-41d4-a716-446655440009', 'Devon Conway', 'Batsman', '660e8400-e29b-41d4-a716-446655440002', 9.0, true),
('770e8400-e29b-41d4-a716-44665544000a', 'Matheesha Pathirana', 'Bowler', '660e8400-e29b-41d4-a716-446655440002', 8.5, true),
('770e8400-e29b-41d4-a716-44665544000b', 'Virat Kohli', 'Batsman', '660e8400-e29b-41d4-a716-446655440003', 10.5, true),
('770e8400-e29b-41d4-a716-44665544000c', 'Faf du Plessis', 'Batsman', '660e8400-e29b-41d4-a716-446655440003', 9.0, true),
('770e8400-e29b-41d4-a716-44665544000d', 'Glenn Maxwell', 'All-rounder', '660e8400-e29b-41d4-a716-446655440003', 9.0, true),
('770e8400-e29b-41d4-a716-44665544000e', 'Shreyas Iyer', 'Batsman', '660e8400-e29b-41d4-a716-446655440004', 9.5, true),
('770e8400-e29b-41d4-a716-44665544000f', 'Andre Russell', 'All-rounder', '660e8400-e29b-41d4-a716-446655440004', 9.5, true),
('770e8400-e29b-41d4-a716-446655440010', 'Sunil Narine', 'All-rounder', '660e8400-e29b-41d4-a716-446655440004', 9.0, true);

INSERT INTO matches (id, tournament_id, team_a_id, team_b_id, team_a_name, team_b_name, team_a_code, team_b_code, team_a_flag, team_b_flag, date_time, venue, status, live) VALUES
('880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440002', 'Mumbai Indians', 'Chennai Super Kings', 'MI', 'CSK', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/MI/Logos/Roundbig/MIroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/CSK/logos/Roundbig/CSKroundbig.png', '2025-07-15T19:30:00Z', 'Wankhede Stadium, Mumbai', 'upcoming', false),
('880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440004', 'Royal Challengers Bengaluru', 'Kolkata Knight Riders', 'RCB', 'KKR', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/RCB/Logos/Roundbig/RCBroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/KKR/Logos/Roundbig/KKRroundbig.png', '2025-07-16T15:30:00Z', 'M. Chinnaswamy Stadium, Bengaluru', 'upcoming', false),
('880e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440004', 'Mumbai Indians', 'Kolkata Knight Riders', 'MI', 'KKR', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/MI/Logos/Roundbig/MIroundbig.png', 'https://bcciplayerimages.s3.ap-south-1.amazonaws.com/ipl/KKR/Logos/Roundbig/KKRroundbig.png', '2025-04-10T19:30:00Z', 'Wankhede Stadium, Mumbai', 'completed', false);

INSERT INTO contests (id, match_id, name, entry_fee, prize_pool, max_teams, joined_teams, contest_type, status) VALUES
('990e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440001', 'Mega Contest', 49.00, 10000.00, 500, 234, 'paid', 'open'),
('990e8400-e29b-41d4-a716-446655440002', '880e8400-e29b-41d4-a716-446655440001', 'Head to Head', 25.00, 45.00, 2, 1, 'paid', 'open'),
('990e8400-e29b-41d4-a716-446655440003', '880e8400-e29b-41d4-a716-446655440002', 'Winner Takes All', 99.00, 25000.00, 300, 156, 'paid', 'open');

INSERT INTO feed_posts (user_id, author_name, content, likes, created_at) VALUES
('test_user_001', 'CricketFan99', 'MI vs CSK is going to be epic! Rohit Sharma in great form!', 12, NOW() - INTERVAL '2 hours'),
('test_user_001', 'CricketFan99', 'Won 500 rupees! Andre Russell as captain paid off!', 24, NOW() - INTERVAL '1 day'),
('FIREBASE_UID_HERE', 'Admin', 'Welcome to Dream11 Local! New contests added daily.', 45, NOW() - INTERVAL '3 days');

INSERT INTO groups (id, name, description, created_by, member_count) VALUES
('aa0e8400-e29b-41d4-a716-446655440001', 'IPL Fantasy League', 'Share tips, discuss strategies!', 'test_user_001', 3),
('aa0e8400-e29b-41d4-a716-446655440002', 'Mumbai Indians Fans', 'MI Paltan!', 'test_user_001', 2);

INSERT INTO group_members (group_id, user_id, role) VALUES
('aa0e8400-e29b-41d4-a716-446655440001', 'test_user_001', 'admin'),
('aa0e8400-e29b-41d4-a716-446655440001', 'FIREBASE_UID_HERE', 'member'),
('aa0e8400-e29b-41d4-a716-446655440002', 'test_user_001', 'admin');

INSERT INTO wallets (user_id, balance, bonus, winnings) VALUES ('test_user_001', 500.00, 50.00, 1200.00);

INSERT INTO transactions (user_id, type, amount, status, description, payment_method, created_at) VALUES
('test_user_001', 'deposit', 500.00, 'completed', 'Added cash via UPI', 'upi', NOW() - INTERVAL '5 days'),
('test_user_001', 'contest_join', 49.00, 'completed', 'Joined Mega Contest - MI vs CSK', 'wallet', NOW() - INTERVAL '2 days'),
('test_user_001', 'winning', 1200.00, 'completed', 'Won Mega Contest - KKR vs RCB', 'wallet', NOW() - INTERVAL '1 day');

INSERT INTO notifications (user_id, title, message, type, is_read, created_at) VALUES
('test_user_001', 'Contest Won!', 'You won Rs.1200! Rank: #3', 'winning', false, NOW() - INTERVAL '1 day'),
('test_user_001', 'Match Starting', 'MI vs CSK in 30 minutes!', 'match', false, NOW() - INTERVAL '2 hours'),
('test_user_001', 'Welcome Bonus', 'Rs.50 bonus credited!', 'bonus', true, NOW() - INTERVAL '5 days');

INSERT INTO scoreboard (match_id, player_id, runs, wickets, catches, fours, sixes, balls_faced, points) VALUES
('880e8400-e29b-41d4-a716-446655440003', '770e8400-e29b-41d4-a716-446655440001', 78, 0, 1, 8, 4, 52, 85.5),
('880e8400-e29b-41d4-a716-446655440003', '770e8400-e29b-41d4-a716-446655440003', 45, 0, 0, 5, 2, 30, 52.0),
('880e8400-e29b-41d4-a716-446655440003', '770e8400-e29b-41d4-a716-446655440002', 2, 3, 0, 0, 0, 6, 78.0),
('880e8400-e29b-41d4-a716-446655440003', '770e8400-e29b-41d4-a716-44665544000e', 62, 0, 2, 6, 3, 44, 71.0),
('880e8400-e29b-41d4-a716-446655440003', '770e8400-e29b-41d4-a716-44665544000f', 35, 1, 1, 2, 3, 18, 65.0);

INSERT INTO commentary (match_id, over_number, ball_number, runs, event_type, description, batsman, bowler) VALUES
('880e8400-e29b-41d4-a716-446655440003', 1.1, 1, 0, 'normal', 'Good length delivery, defended back to the bowler', 'Rohit Sharma', 'Sunil Narine'),
('880e8400-e29b-41d4-a716-446655440003', 1.2, 2, 4, 'four', 'Short and wide, cut away through point for FOUR!', 'Rohit Sharma', 'Sunil Narine'),
('880e8400-e29b-41d4-a716-446655440003', 1.3, 3, 1, 'normal', 'Pushed to mid-on for a single', 'Rohit Sharma', 'Sunil Narine'),
('880e8400-e29b-41d4-a716-446655440003', 1.4, 4, 6, 'six', 'Flighted delivery, smashed over long-on for a massive SIX!', 'Suryakumar Yadav', 'Sunil Narine'),
('880e8400-e29b-41d4-a716-446655440003', 1.5, 5, 0, 'wicket', 'BOWLED! Clean bowled through the gate!', 'Suryakumar Yadav', 'Sunil Narine'),
('880e8400-e29b-41d4-a716-446655440003', 1.6, 6, 1, 'normal', 'Tapped to short fine leg for a single', 'Ishan Kishan', 'Sunil Narine');

INSERT INTO payment_methods (user_id, method_type, details, is_default) VALUES
('test_user_001', 'upi', '{"upi_id": "cricketfan99@paytm", "name": "CricketFan99"}', true),
('test_user_001', 'bank_account', '{"account_number": "XXXX1234", "ifsc": "SBIN0001234", "name": "Test User", "bank_name": "SBI"}', false),
('test_user_001', 'phonepe', '{"phone": "+919876543210", "name": "CricketFan99"}', false);

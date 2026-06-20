/**
 * Supabase Database Service Layer
 * Replaces Firestore for all database operations.
 * Firebase Auth remains for authentication.
 */

import supabase from '../supabase';

// ============ MATCHES ============

export const getMatches = async (status) => {
  try {
    let query = supabase.from('matches').select('*, tournament:tournaments(name, logo)');
    if (status) {
      query = query.eq('status', status);
    }
    query = query.order('date_time', { ascending: false });
    const { data, error } = await query;
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [matches]:', error.message);
    return [];
  }
};

export const getMatchById = async (id) => {
  try {
    const { data, error } = await supabase
      .from('matches')
      .select('*, tournament:tournaments(name, logo), team_a_details:teams!matches_team_a_id_fkey(*), team_b_details:teams!matches_team_b_id_fkey(*)')
      .eq('id', id)
      .single();
    if (error) throw error;
    return data;
  } catch (error) {
    console.error('DB Error [match by id]:', error.message);
    return null;
  }
};

export const getUpcomingMatches = async () => {
  try {
    const { data, error } = await supabase
      .from('matches')
      .select('*, tournament:tournaments(name, logo)')
      .in('status', ['upcoming', 'scheduled'])
      .order('date_time', { ascending: true });
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [upcoming matches]:', error.message);
    return [];
  }
};

export const getLiveMatches = async () => {
  try {
    const { data, error } = await supabase
      .from('matches')
      .select('*, tournament:tournaments(name, logo)')
      .eq('status', 'live')
      .order('date_time', { ascending: false });
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [live matches]:', error.message);
    return [];
  }
};

export const getCompletedMatches = async () => {
  try {
    const { data, error } = await supabase
      .from('matches')
      .select('*, tournament:tournaments(name, logo)')
      .eq('status', 'completed')
      .order('date_time', { ascending: false })
      .limit(20);
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [completed matches]:', error.message);
    return [];
  }
};

// ============ TOURNAMENTS ============

export const getTournaments = async (status) => {
  try {
    let query = supabase.from('tournaments').select('*');
    if (status) {
      query = query.eq('status', status);
    }
    query = query.order('start_date', { ascending: false });
    const { data, error } = await query;
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [tournaments]:', error.message);
    return [];
  }
};

export const getTournamentById = async (id) => {
  try {
    const { data, error } = await supabase
      .from('tournaments')
      .select('*')
      .eq('id', id)
      .single();
    if (error) throw error;
    return data;
  } catch (error) {
    console.error('DB Error [tournament by id]:', error.message);
    return null;
  }
};

// ============ TEAMS ============

export const getTeams = async () => {
  try {
    const { data, error } = await supabase
      .from('teams')
      .select('*')
      .order('name', { ascending: true });
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [teams]:', error.message);
    return [];
  }
};

export const getTeamById = async (id) => {
  try {
    const { data, error } = await supabase
      .from('teams')
      .select('*, players(*)')
      .eq('id', id)
      .single();
    if (error) throw error;
    return data;
  } catch (error) {
    console.error('DB Error [team by id]:', error.message);
    return null;
  }
};

// ============ PLAYERS ============

export const getPlayersByTeam = async (teamId) => {
  try {
    const { data, error } = await supabase
      .from('players')
      .select('*')
      .eq('team_id', teamId)
      .order('name', { ascending: true });
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [players by team]:', error.message);
    return [];
  }
};

export const getPlayersByMatch = async (matchId) => {
  try {
    const { data, error } = await supabase
      .from('match_players')
      .select('*, player:players(*)')
      .eq('match_id', matchId);
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [players by match]:', error.message);
    return [];
  }
};

export const getPlayerById = async (id) => {
  try {
    const { data, error } = await supabase
      .from('players')
      .select('*, team:teams(name, logo)')
      .eq('id', id)
      .single();
    if (error) throw error;
    return data;
  } catch (error) {
    console.error('DB Error [player by id]:', error.message);
    return null;
  }
};

// ============ CONTESTS ============

export const getContestsByMatch = async (matchId) => {
  try {
    const { data, error } = await supabase
      .from('contests')
      .select('*')
      .eq('match_id', matchId)
      .order('prize_pool', { ascending: false });
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [contests by match]:', error.message);
    return [];
  }
};

export const getContestById = async (id) => {
  try {
    const { data, error } = await supabase
      .from('contests')
      .select('*, match:matches(team_a_name, team_b_name, date_time, status)')
      .eq('id', id)
      .single();
    if (error) throw error;
    return data;
  } catch (error) {
    console.error('DB Error [contest by id]:', error.message);
    return null;
  }
};

// ============ FANTASY TEAMS ============

export const getUserFantasyTeams = async (userId, matchId) => {
  try {
    let query = supabase
      .from('fantasy_teams')
      .select('*, fantasy_team_players(*, player:players(name, role, team:teams(name)))')
      .eq('user_id', userId);
    if (matchId) {
      query = query.eq('match_id', matchId);
    }
    query = query.order('created_at', { ascending: false });
    const { data, error } = await query;
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [fantasy teams]:', error.message);
    return [];
  }
};

export const createFantasyTeam = async (teamData) => {
  try {
    const { data, error } = await supabase
      .from('fantasy_teams')
      .insert(teamData)
      .select()
      .single();
    if (error) throw error;
    return data;
  } catch (error) {
    console.error('DB Error [create fantasy team]:', error.message);
    return null;
  }
};

// ============ FEED POSTS ============

export const getFeedPosts = async (limit = 20) => {
  try {
    const { data, error } = await supabase
      .from('feed_posts')
      .select('*, user:users(username, avatar_url)')
      .order('created_at', { ascending: false })
      .limit(limit);
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [feed posts]:', error.message);
    return [];
  }
};

export const createFeedPost = async (postData) => {
  try {
    const { data, error } = await supabase
      .from('feed_posts')
      .insert(postData)
      .select()
      .single();
    if (error) throw error;
    return data;
  } catch (error) {
    console.error('DB Error [create feed post]:', error.message);
    return null;
  }
};

// ============ GROUPS ============

export const getUserGroups = async (userId) => {
  try {
    const { data, error } = await supabase
      .from('group_members')
      .select('*, group:groups(*)')
      .eq('user_id', userId);
    if (error) throw error;
    return data?.map(gm => ({ ...gm.group, membership: { role: gm.role, joined_at: gm.joined_at } })) || [];
  } catch (error) {
    console.error('DB Error [user groups]:', error.message);
    return [];
  }
};

export const getGroupById = async (groupId) => {
  try {
    const { data, error } = await supabase
      .from('groups')
      .select('*, group_members(*, user:users(username, avatar_url))')
      .eq('id', groupId)
      .single();
    if (error) throw error;
    return data;
  } catch (error) {
    console.error('DB Error [group by id]:', error.message);
    return null;
  }
};

export const createGroup = async (groupData) => {
  try {
    const { data, error } = await supabase
      .from('groups')
      .insert(groupData)
      .select()
      .single();
    if (error) throw error;
    return data;
  } catch (error) {
    console.error('DB Error [create group]:', error.message);
    return null;
  }
};

// ============ WALLET ============

export const getWallet = async (userId) => {
  try {
    const { data, error } = await supabase
      .from('wallets')
      .select('*')
      .eq('user_id', userId)
      .single();
    if (error && error.code !== 'PGRST116') throw error; // PGRST116 = no rows
    return data;
  } catch (error) {
    console.error('DB Error [wallet]:', error.message);
    return null;
  }
};

export const getTransactions = async (userId) => {
  try {
    const { data, error } = await supabase
      .from('transactions')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [transactions]:', error.message);
    return [];
  }
};

// ============ NOTIFICATIONS ============

export const getUserNotifications = async (userId) => {
  try {
    const { data, error } = await supabase
      .from('notifications')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(50);
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [notifications]:', error.message);
    return [];
  }
};

export const markNotificationRead = async (notificationId) => {
  try {
    const { error } = await supabase
      .from('notifications')
      .update({ is_read: true })
      .eq('id', notificationId);
    if (error) throw error;
    return true;
  } catch (error) {
    console.error('DB Error [mark notification read]:', error.message);
    return false;
  }
};

// ============ USERS ============

export const getUserProfile = async (uid) => {
  try {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('uid', uid)
      .single();
    if (error && error.code !== 'PGRST116') throw error;
    return data;
  } catch (error) {
    console.error('DB Error [user profile]:', error.message);
    return null;
  }
};

export const upsertUser = async (userData) => {
  try {
    const { data, error } = await supabase
      .from('users')
      .upsert(userData, { onConflict: 'uid' })
      .select()
      .single();
    if (error) throw error;
    return data;
  } catch (error) {
    console.error('DB Error [upsert user]:', error.message);
    return null;
  }
};

export const searchUsers = async (searchTerm) => {
  try {
    const { data, error } = await supabase
      .from('users')
      .select('uid, username, email, avatar_url')
      .ilike('username', `${searchTerm}%`)
      .limit(20);
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [search users]:', error.message);
    return [];
  }
};

// ============ ADMINS ============

export const checkIsAdmin = async (uid) => {
  try {
    const { data, error } = await supabase
      .from('admins')
      .select('*')
      .eq('uid', uid)
      .single();
    if (error && error.code !== 'PGRST116') throw error;
    return data || null;
  } catch (error) {
    console.error('DB Error [check admin]:', error.message);
    return null;
  }
};

export const getAdminByEmail = async (email) => {
  try {
    const { data, error } = await supabase
      .from('admins')
      .select('*')
      .eq('email', email)
      .single();
    if (error && error.code !== 'PGRST116') throw error;
    return data || null;
  } catch (error) {
    console.error('DB Error [admin by email]:', error.message);
    return null;
  }
};

// ============ LEADERBOARD ============

export const getLeaderboard = async (contestId) => {
  try {
    const { data, error } = await supabase
      .from('leaderboard')
      .select('*, user:users(username, avatar_url)')
      .eq('contest_id', contestId)
      .order('rank', { ascending: true });
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [leaderboard]:', error.message);
    return [];
  }
};

// ============ SCOREBOARD ============

export const getScoreboard = async (matchId) => {
  try {
    const { data, error } = await supabase
      .from('scoreboard')
      .select('*, player:players(name, role)')
      .eq('match_id', matchId)
      .order('points', { ascending: false });
    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('DB Error [scoreboard]:', error.message);
    return [];
  }
};

export default {
  getMatches,
  getMatchById,
  getUpcomingMatches,
  getLiveMatches,
  getCompletedMatches,
  getTournaments,
  getTournamentById,
  getTeams,
  getTeamById,
  getPlayersByTeam,
  getPlayersByMatch,
  getPlayerById,
  getContestsByMatch,
  getContestById,
  getUserFantasyTeams,
  createFantasyTeam,
  getFeedPosts,
  createFeedPost,
  getUserGroups,
  getGroupById,
  createGroup,
  getWallet,
  getTransactions,
  getUserNotifications,
  markNotificationRead,
  getUserProfile,
  upsertUser,
  searchUsers,
  checkIsAdmin,
  getAdminByEmail,
  getLeaderboard,
  getScoreboard
};

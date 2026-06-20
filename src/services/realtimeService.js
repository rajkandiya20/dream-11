/**
 * Supabase Real-time Subscription Service
 * Provides helpers for subscribing to database changes via Supabase Realtime.
 * Each function returns an unsubscribe function for cleanup.
 */

import supabase from '../supabase';

/**
 * Subscribe to all changes on the matches table.
 * @param {Function} callback - Called with payload on any change (INSERT, UPDATE, DELETE)
 * @returns {Function} unsubscribe function
 */
export const subscribeToMatches = (callback) => {
  const channel = supabase
    .channel('realtime-matches')
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'matches' },
      (payload) => {
        callback(payload);
      }
    )
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
};

/**
 * Subscribe to all changes on the tournaments table.
 * @param {Function} callback - Called with payload on any change
 * @returns {Function} unsubscribe function
 */
export const subscribeToTournaments = (callback) => {
  const channel = supabase
    .channel('realtime-tournaments')
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'tournaments' },
      (payload) => {
        callback(payload);
      }
    )
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
};

/**
 * Subscribe to changes on the contests table, optionally filtered by match_id.
 * @param {string|null} matchId - Optional match ID to filter by
 * @param {Function} callback - Called with payload on any change
 * @returns {Function} unsubscribe function
 */
export const subscribeToContests = (matchId, callback) => {
  const channelName = matchId
    ? `realtime-contests-${matchId}`
    : 'realtime-contests-all';

  const subscriptionConfig = {
    event: '*',
    schema: 'public',
    table: 'contests',
  };

  if (matchId) {
    subscriptionConfig.filter = `match_id=eq.${matchId}`;
  }

  const channel = supabase
    .channel(channelName)
    .on('postgres_changes', subscriptionConfig, (payload) => {
      callback(payload);
    })
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
};

/**
 * Subscribe to changes on the players table, optionally filtered by team_id.
 * @param {string|null} teamId - Optional team ID to filter by
 * @param {Function} callback - Called with payload on any change
 * @returns {Function} unsubscribe function
 */
export const subscribeToPlayers = (teamId, callback) => {
  const channelName = teamId
    ? `realtime-players-${teamId}`
    : 'realtime-players-all';

  const subscriptionConfig = {
    event: '*',
    schema: 'public',
    table: 'players',
  };

  if (teamId) {
    subscriptionConfig.filter = `team_id=eq.${teamId}`;
  }

  const channel = supabase
    .channel(channelName)
    .on('postgres_changes', subscriptionConfig, (payload) => {
      callback(payload);
    })
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
};

/**
 * Subscribe to changes on the scoreboard table filtered by match_id.
 * @param {string} matchId - Match ID to filter by
 * @param {Function} callback - Called with payload on any change
 * @returns {Function} unsubscribe function
 */
export const subscribeToScoreboard = (matchId, callback) => {
  const channel = supabase
    .channel(`realtime-scoreboard-${matchId}`)
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'scoreboard',
        filter: `match_id=eq.${matchId}`,
      },
      (payload) => {
        callback(payload);
      }
    )
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
};

/**
 * Subscribe to changes on the notifications table filtered by user_id.
 * @param {string} userId - User ID to filter by
 * @param {Function} callback - Called with payload on any change
 * @returns {Function} unsubscribe function
 */
export const subscribeToNotifications = (userId, callback) => {
  const channel = supabase
    .channel(`realtime-notifications-${userId}`)
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'notifications',
        filter: `user_id=eq.${userId}`,
      },
      (payload) => {
        callback(payload);
      }
    )
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
};

/**
 * Subscribe to changes on the commentary table filtered by match_id.
 * @param {string} matchId - Match ID to filter by
 * @param {Function} callback - Called with payload on any change
 * @returns {Function} unsubscribe function
 */
export const subscribeToCommentary = (matchId, callback) => {
  const channel = supabase
    .channel(`realtime-commentary-${matchId}`)
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'commentary',
        filter: `match_id=eq.${matchId}`,
      },
      (payload) => {
        callback(payload);
      }
    )
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
};

/**
 * Subscribe to all changes on the teams table.
 * @param {Function} callback - Called with payload on any change
 * @returns {Function} unsubscribe function
 */
export const subscribeToTeams = (callback) => {
  const channel = supabase
    .channel('realtime-teams')
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'teams' },
      (payload) => {
        callback(payload);
      }
    )
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
};

export default {
  subscribeToMatches,
  subscribeToTournaments,
  subscribeToContests,
  subscribeToPlayers,
  subscribeToScoreboard,
  subscribeToNotifications,
  subscribeToCommentary,
  subscribeToTeams,
};

/**
 * Centralized Firestore service layer
 * Provides reusable query functions for all collections.
 * Each function includes error handling and returns empty arrays/null on failure.
 */

import db from '../firebase';
import {
  collection,
  getDocs,
  query,
  where,
  orderBy,
  limit as firestoreLimit,
  doc,
  getDoc
} from 'firebase/firestore';
import { logQuery } from '../utils/logger';

/**
 * Get matches filtered by status
 * @param {string} status - 'upcoming' | 'live' | 'completed'
 * @returns {Promise<Array>} Array of match documents
 */
export const getMatches = async (status) => {
  try {
    logQuery('matches', 'start', { status });
    const matchesRef = collection(db, 'matches');
    let q;
    if (status) {
      q = query(matchesRef, where('status', '==', status), orderBy('date', 'desc'));
    } else {
      q = query(matchesRef, orderBy('date', 'desc'));
    }
    const snapshot = await getDocs(q);
    const results = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    logQuery('matches', 'success', { count: results.length });
    return results;
  } catch (error) {
    logQuery('matches', 'error', error.message);
    return [];
  }
};

/**
 * Get a single match by ID
 * @param {string} id - Match document ID
 * @returns {Promise<Object|null>} Match document or null
 */
export const getMatchById = async (id) => {
  try {
    logQuery('matches', 'start', { id });
    const docRef = doc(db, 'matches', id);
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      logQuery('matches', 'success', { id });
      return { id: docSnap.id, ...docSnap.data() };
    }
    logQuery('matches', 'success', { id, found: false });
    return null;
  } catch (error) {
    logQuery('matches', 'error', error.message);
    return null;
  }
};

/**
 * Get contests for a specific match
 * @param {string} matchId - Match document ID
 * @returns {Promise<Array>} Array of contest documents
 */
export const getContestsByMatch = async (matchId) => {
  try {
    logQuery('contests', 'start', { matchId });
    const contestsRef = collection(db, 'contests');
    const q = query(contestsRef, where('matchId', '==', matchId));
    const snapshot = await getDocs(q);
    const results = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    logQuery('contests', 'success', { count: results.length });
    return results;
  } catch (error) {
    logQuery('contests', 'error', error.message);
    return [];
  }
};

/**
 * Get players for a specific team
 * @param {string} teamId - Team document ID
 * @returns {Promise<Array>} Array of player documents
 */
export const getPlayersByTeam = async (teamId) => {
  try {
    logQuery('players', 'start', { teamId });
    const playersRef = collection(db, 'players');
    const q = query(playersRef, where('teamId', '==', teamId));
    const snapshot = await getDocs(q);
    const results = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    logQuery('players', 'success', { count: results.length });
    return results;
  } catch (error) {
    logQuery('players', 'error', error.message);
    return [];
  }
};

/**
 * Get user profile by UID
 * @param {string} uid - User UID
 * @returns {Promise<Object|null>} User profile or null
 */
export const getUserProfile = async (uid) => {
  try {
    logQuery('users', 'start', { uid });
    const docRef = doc(db, 'users', uid);
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      logQuery('users', 'success', { uid });
      return { id: docSnap.id, ...docSnap.data() };
    }
    logQuery('users', 'success', { uid, found: false });
    return null;
  } catch (error) {
    logQuery('users', 'error', error.message);
    return null;
  }
};

/**
 * Get groups for a specific user
 * @param {string} uid - User UID
 * @returns {Promise<Array>} Array of group documents
 */
export const getUserGroups = async (uid) => {
  try {
    logQuery('groups', 'start', { uid });
    const groupsRef = collection(db, 'groups');
    const q = query(groupsRef, where(`members.${uid}`, '==', true));
    const snapshot = await getDocs(q);
    const results = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    logQuery('groups', 'success', { count: results.length });
    return results;
  } catch (error) {
    logQuery('groups', 'error', error.message);
    return [];
  }
};

/**
 * Get notifications for a specific user
 * @param {string} uid - User UID
 * @returns {Promise<Array>} Array of notification documents
 */
export const getUserNotifications = async (uid) => {
  try {
    logQuery('notifications', 'start', { uid });
    const notificationsRef = collection(db, 'notifications');
    const q = query(
      notificationsRef,
      where('userId', '==', uid),
      orderBy('createdAt', 'desc')
    );
    const snapshot = await getDocs(q);
    const results = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    logQuery('notifications', 'success', { count: results.length });
    return results;
  } catch (error) {
    logQuery('notifications', 'error', error.message);
    return [];
  }
};

/**
 * Get feed posts with optional limit
 * @param {number} postLimit - Maximum number of posts to return (default 20)
 * @returns {Promise<Array>} Array of feed post documents
 */
export const getFeedPosts = async (postLimit = 20) => {
  try {
    logQuery('feed', 'start', { limit: postLimit });
    const feedRef = collection(db, 'feed');
    const q = query(feedRef, orderBy('createdAt', 'desc'), firestoreLimit(postLimit));
    const snapshot = await getDocs(q);
    const results = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    logQuery('feed', 'success', { count: results.length });
    return results;
  } catch (error) {
    logQuery('feed', 'error', error.message);
    return [];
  }
};

/**
 * Get wallet for a specific user
 * @param {string} uid - User UID
 * @returns {Promise<Object|null>} Wallet document or null
 */
export const getWallet = async (uid) => {
  try {
    logQuery('wallets', 'start', { uid });
    const docRef = doc(db, 'wallets', uid);
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      logQuery('wallets', 'success', { uid });
      return { id: docSnap.id, ...docSnap.data() };
    }
    logQuery('wallets', 'success', { uid, found: false });
    return null;
  } catch (error) {
    logQuery('wallets', 'error', error.message);
    return null;
  }
};

/**
 * Get transactions for a specific user
 * @param {string} uid - User UID
 * @returns {Promise<Array>} Array of transaction documents
 */
export const getTransactions = async (uid) => {
  try {
    logQuery('transactions', 'start', { uid });
    const transactionsRef = collection(db, 'transactions');
    const q = query(
      transactionsRef,
      where('userId', '==', uid),
      orderBy('createdAt', 'desc')
    );
    const snapshot = await getDocs(q);
    const results = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    logQuery('transactions', 'success', { count: results.length });
    return results;
  } catch (error) {
    logQuery('transactions', 'error', error.message);
    return [];
  }
};

/**
 * Get tournaments filtered by status
 * @param {string} status - 'upcoming' | 'live' | 'completed'
 * @returns {Promise<Array>} Array of tournament documents
 */
export const getTournaments = async (status) => {
  try {
    logQuery('tournaments', 'start', { status });
    const tournamentsRef = collection(db, 'tournaments');
    let q;
    if (status) {
      q = query(tournamentsRef, where('status', '==', status));
    } else {
      q = query(tournamentsRef);
    }
    const snapshot = await getDocs(q);
    const results = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    logQuery('tournaments', 'success', { count: results.length });
    return results;
  } catch (error) {
    logQuery('tournaments', 'error', error.message);
    return [];
  }
};

export default {
  getMatches,
  getMatchById,
  getContestsByMatch,
  getPlayersByTeam,
  getUserProfile,
  getUserGroups,
  getUserNotifications,
  getFeedPosts,
  getWallet,
  getTransactions,
  getTournaments
};

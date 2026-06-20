/**
 * Admin service for admin operations and permission management.
 */

import db from '../firebase';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import { logAuth, logQuery } from '../utils/logger';

const ADMIN_EMAIL = 'rexoagency.in@gmail.com';

const SUPER_ADMIN_PERMISSIONS = [
  'full_access',
  'user_management',
  'tournament_management',
  'match_management',
  'player_management',
  'contest_management',
  'wallet_management',
  'transaction_management',
  'notification_management',
  'database_management'
];

/**
 * Check if an email belongs to an admin
 * @param {string} email - Email address to check
 * @returns {boolean} True if the email is the admin email
 */
export const checkIsAdmin = (email) => {
  const result = email === ADMIN_EMAIL;
  logAuth('Admin check', { email, isAdmin: result });
  return result;
};

/**
 * Get admin permissions from Firestore
 * @param {string} uid - User UID
 * @returns {Promise<Object|null>} Admin document with role and permissions, or null
 */
export const getAdminPermissions = async (uid) => {
  try {
    logQuery('admins', 'start', { uid });
    const docRef = doc(db, 'admins', uid);
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      logQuery('admins', 'success', { uid, role: docSnap.data().role });
      return { id: docSnap.id, ...docSnap.data() };
    }
    logQuery('admins', 'success', { uid, found: false });
    return null;
  } catch (error) {
    logQuery('admins', 'error', error.message);
    return null;
  }
};

/**
 * Ensure the admin document exists with super_admin role and full permissions.
 * Creates or updates the admins document if the user is the known admin email.
 * @param {string} uid - User UID
 * @param {string} email - User email
 * @returns {Promise<Object|null>} The admin document
 */
export const ensureAdminDocument = async (uid, email) => {
  if (!checkIsAdmin(email)) {
    return null;
  }

  try {
    logQuery('admins', 'start', { action: 'ensure', uid });
    const docRef = doc(db, 'admins', uid);
    const docSnap = await getDoc(docRef);

    if (docSnap.exists()) {
      const data = docSnap.data();
      if (data.role === 'super_admin' && data.permissions?.length === SUPER_ADMIN_PERMISSIONS.length) {
        logQuery('admins', 'success', { action: 'already_exists', uid });
        return { id: docSnap.id, ...data };
      }
    }

    // Create or update admin document with full permissions
    const adminData = {
      uid,
      email,
      role: 'super_admin',
      permissions: SUPER_ADMIN_PERMISSIONS,
      createdAt: new Date()
    };
    await setDoc(docRef, adminData, { merge: true });
    logQuery('admins', 'success', { action: 'created', uid });
    return { id: uid, ...adminData };
  } catch (error) {
    logQuery('admins', 'error', error.message);
    return null;
  }
};

export default {
  checkIsAdmin,
  getAdminPermissions,
  ensureAdminDocument,
  ADMIN_EMAIL,
  SUPER_ADMIN_PERMISSIONS
};

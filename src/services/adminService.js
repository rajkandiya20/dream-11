/**
 * Admin service - uses Supabase for admin operations.
 */

import { checkIsAdmin as checkAdmin, getAdminByEmail } from './supabaseService';

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
 * Check if an email belongs to an admin (quick check)
 */
export const checkIsAdmin = (email) => {
  return email === ADMIN_EMAIL;
};

/**
 * Verify admin status from database
 */
export const verifyAdminFromDB = async (uid) => {
  const admin = await checkAdmin(uid);
  return admin;
};

/**
 * Get admin permissions from Supabase
 */
export const getAdminPermissions = async (email) => {
  try {
    const admin = await getAdminByEmail(email);
    if (admin) {
      return {
        id: admin.id,
        uid: admin.uid,
        email: admin.email,
        role: admin.role,
        permissions: admin.permissions || SUPER_ADMIN_PERMISSIONS
      };
    }
    return null;
  } catch (error) {
    console.error('Admin permissions error:', error);
    return null;
  }
};

export default {
  checkIsAdmin,
  verifyAdminFromDB,
  getAdminPermissions,
  ADMIN_EMAIL,
  SUPER_ADMIN_PERMISSIONS
};

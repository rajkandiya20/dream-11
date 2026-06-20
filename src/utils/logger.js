/**
 * Debug logging utility
 * Only logs in development mode to avoid noise in production.
 */

const isDev = process.env.NODE_ENV === 'development';

const getTimestamp = () => new Date().toISOString();

/**
 * Log authentication-related events
 * @param {string} message - Description of the auth event
 * @param {*} data - Optional data to log
 */
export const logAuth = (message, data = null) => {
  if (!isDev) return;
  const prefix = `[AUTH ${getTimestamp()}]`;
  if (data) {
    console.log(prefix, message, data);
  } else {
    console.log(prefix, message);
  }
};

/**
 * Log Firestore query events
 * @param {string} collectionName - The collection being queried
 * @param {string} status - 'start' | 'success' | 'error'
 * @param {*} data - Optional data (result count, error, etc.)
 */
export const logQuery = (collectionName, status, data = null) => {
  if (!isDev) return;
  const prefix = `[QUERY ${getTimestamp()}]`;
  if (data) {
    console.log(prefix, `${collectionName} - ${status}`, data);
  } else {
    console.log(prefix, `${collectionName} - ${status}`);
  }
};

/**
 * Log network/API events
 * @param {string} url - The URL being accessed
 * @param {string} status - 'request' | 'success' | 'error'
 * @param {*} error - Optional error object
 */
export const logNetwork = (url, status, error = null) => {
  if (!isDev) return;
  const prefix = `[NETWORK ${getTimestamp()}]`;
  if (error) {
    console.log(prefix, `${url} - ${status}`, error);
  } else {
    console.log(prefix, `${url} - ${status}`);
  }
};

/**
 * Log component render events
 * @param {string} component - Component name
 * @param {string} status - 'mount' | 'update' | 'unmount' | 'error'
 */
export const logRender = (component, status) => {
  if (!isDev) return;
  const prefix = `[RENDER ${getTimestamp()}]`;
  console.log(prefix, `${component} - ${status}`);
};

export default { logAuth, logQuery, logNetwork, logRender };

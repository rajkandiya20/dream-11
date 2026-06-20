import axios from "axios";
import { 
  auth, 
  registerUser as firebaseRegister, 
  loginUser as firebaseLogin,
  logoutUser as firebaseLogout,
  resetPassword as firebaseResetPassword,
  getFreshToken
} from "../firebase";
import { upsertUser, getUserProfile, getAdminByEmail } from "../services/supabaseService";

import {
  ADD_CONFETTI,
  LOAD_USER_FAIL,
  LOAD_USER_REQUEST,
  LOAD_USER_SUCCESS,
  LOGIN_FAIL,
  LOGIN_REQUEST,
  LOGIN_SUCCESS,
  REGISTER_USER_FAIL,
  REGISTER_USER_REQUEST,
  REGISTER_USER_SUCCESS,
  REMOVE_CONFETTI,
  URL,
} from "../constants/userConstants";

export const API = axios.create({ baseURL: `${URL}` });

// Request interceptor with token refresh
API.interceptors.request.use(async (req) => {
  const token = localStorage.getItem("token");
  if (token) {
    req.headers.Authorization = `Bearer ${token}`;
    req.headers.servertoken = token;
    req.headers.ContentType = "application/json";
  }
  return req;
});

// Response interceptor for error handling
API.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error.response?.status, error.message);
    return Promise.reject(error);
  }
);

// Register user with Firebase Auth + Supabase DB
export const register = (formData) => async (dispatch) => {
  try {
    console.log('Starting registration...');
    dispatch({ type: REGISTER_USER_REQUEST });
    
    const { email, password, username, phoneNumber } = formData;
    
    // Create user in Firebase Auth
    const userCredential = await firebaseRegister(email, password);
    const user = userCredential.user;
    
    // Store user data in Supabase
    const userData = {
      uid: user.uid,
      email: email,
      username: username || email.split('@')[0],
      phone_number: phoneNumber || null,
      role: "user",
      balance: 0,
      avatar_url: null,
      created_at: new Date().toISOString()
    };
    
    const savedUser = await upsertUser(userData);
    console.log('User data stored in Supabase');
    
    // Build local user object
    const localUserData = {
      uid: user.uid,
      _id: user.uid,
      email: email,
      username: username || email.split('@')[0],
      phoneNumber: phoneNumber || null,
      role: "user",
      balance: 0,
      isAdmin: false
    };
    
    // Store token in localStorage
    const token = await user.getIdToken();
    localStorage.setItem("token", token);
    localStorage.setItem("user", JSON.stringify(localUserData));
    
    dispatch({ type: REGISTER_USER_SUCCESS, payload: localUserData });
    
    return { success: true, user: localUserData };
  } catch (error) {
    console.error('Registration failed:', error);
    const errorMessage = getFirebaseErrorMessage(error.code);
    dispatch({ type: REGISTER_USER_FAIL, payload: errorMessage });
    return { success: false, message: errorMessage };
  }
};

// Login user with Firebase Auth + Supabase DB
export const login = (formData) => async (dispatch) => {
  try {
    console.log('Starting login...');
    dispatch({ type: LOGIN_REQUEST });
    
    const { email, password } = formData;
    
    // Login with Firebase Auth
    const userCredential = await firebaseLogin(email, password);
    const user = userCredential.user;
    
    // Get user data from Supabase
    let userData = {
      uid: user.uid,
      _id: user.uid,
      email: user.email,
      role: "user",
      isAdmin: false
    };
    
    try {
      const supabaseUser = await getUserProfile(user.uid);
      if (supabaseUser) {
        userData = {
          ...userData,
          username: supabaseUser.username,
          phoneNumber: supabaseUser.phone_number,
          balance: supabaseUser.balance || 0,
          avatar_url: supabaseUser.avatar_url,
          role: supabaseUser.role || "user"
        };
        console.log('User data loaded from Supabase');
      } else {
        // Create user in Supabase if doesn't exist
        const newUserData = {
          uid: user.uid,
          email: user.email,
          username: email.split('@')[0],
          role: "user",
          balance: 0,
          created_at: new Date().toISOString()
        };
        await upsertUser(newUserData);
        userData.username = newUserData.username;
        console.log('New user created in Supabase');
      }
    } catch (dbError) {
      console.error('Supabase error:', dbError);
      userData.username = email.split('@')[0];
    }
    
    // Check if user is admin
    try {
      const adminRecord = await getAdminByEmail(email);
      if (adminRecord) {
        userData.isAdmin = true;
        userData.role = adminRecord.role || 'super_admin';
        userData.permissions = adminRecord.permissions || [];
        console.log('Admin user detected');
      }
    } catch (adminError) {
      // Not an admin, continue
    }
    
    // Store token in localStorage
    const token = await user.getIdToken();
    localStorage.setItem("token", token);
    localStorage.setItem("user", JSON.stringify(userData));
    
    dispatch({ type: LOGIN_SUCCESS, payload: userData });
    return { success: true, user: userData };
  } catch (error) {
    console.error('Login failed:', error);
    const errorMessage = getFirebaseErrorMessage(error.code);
    dispatch({ type: LOGIN_FAIL, payload: errorMessage });
    return { success: false, message: errorMessage };
  }
};

// Forgot password
export const forgot = (email) => async (dispatch) => {
  try {
    dispatch({ type: LOGIN_REQUEST });
    await firebaseResetPassword(email);
    dispatch({ type: LOGIN_SUCCESS, payload: null });
    return { success: true, message: "Password reset email sent!" };
  } catch (error) {
    const errorMessage = getFirebaseErrorMessage(error.code);
    dispatch({ type: LOGIN_FAIL, payload: errorMessage });
    return { success: false, message: errorMessage };
  }
};

// Logout user
export const logout = () => async (dispatch) => {
  try {
    await firebaseLogout();
    localStorage.removeItem("token");
    localStorage.removeItem("user");
    window.location.href = "/login";
  } catch (error) {
    console.error('Logout error:', error);
  }
};

export const addconfetti = () => async (dispatch) => {
  dispatch({ type: ADD_CONFETTI });
};

export const removeconfetti = () => async (dispatch) => {
  dispatch({ type: REMOVE_CONFETTI });
};

// Load user from localStorage with validation
export const loadUser = () => async (dispatch) => {
  try {
    dispatch({ type: LOAD_USER_REQUEST });
    
    const storedUser = localStorage.getItem("user");
    const token = localStorage.getItem("token");
    
    if (storedUser && token) {
      const userData = JSON.parse(storedUser);
      dispatch({ type: LOAD_USER_SUCCESS, payload: userData });
    } else {
      dispatch({ type: LOAD_USER_FAIL });
    }
  } catch (error) {
    console.error('Load user error:', error);
    dispatch({ type: LOAD_USER_FAIL });
  }
};

// Helper function to get user-friendly error messages
const getFirebaseErrorMessage = (code) => {
  const errorMessages = {
    'auth/email-already-in-use': 'This email is already registered. Please login.',
    'auth/invalid-email': 'Invalid email address format.',
    'auth/operation-not-allowed': 'Operation not allowed. Contact support.',
    'auth/weak-password': 'Password is too weak. Use at least 6 characters.',
    'auth/user-disabled': 'This account has been disabled.',
    'auth/user-not-found': 'No account found with this email.',
    'auth/wrong-password': 'Incorrect password. Try again.',
    'auth/invalid-credential': 'Invalid email or password.',
    'auth/too-many-requests': 'Too many failed attempts. Try again later.',
    'auth/network-request-failed': 'Network error. Check your connection.',
    'permission-denied': 'Permission denied.',
    'unavailable': 'Service temporarily unavailable. Try again later.'
  };
  return errorMessages[code] || 'An error occurred. Please try again.';
};

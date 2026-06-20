import axios from "axios";
import { 
  auth, 
  registerUser as firebaseRegister, 
  loginUser as firebaseLogin,
  logoutUser as firebaseLogout,
  resetPassword as firebaseResetPassword,
  getFreshToken
} from "../firebase";
import { 
  doc, 
  setDoc, 
  getDoc,
  serverTimestamp 
} from "firebase/firestore";
import db from "../firebase";

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
    console.error('❌ API Error:', error.response?.status, error.message);
    return Promise.reject(error);
  }
);

// Register user with Firebase Auth
export const register = (formData) => async (dispatch) => {
  try {
    console.log('📝 Starting registration...');
    dispatch({ type: REGISTER_USER_REQUEST });
    
    const { email, password, username, phoneNumber } = formData;
    
    // Create user in Firebase Auth
    const userCredential = await firebaseRegister(email, password);
    const user = userCredential.user;
    
    // Store additional user data in Firestore
    const userData = {
      uid: user.uid,
      _id: user.uid, // Add _id for compatibility
      email: email,
      username: username,
      phoneNumber: phoneNumber,
      createdAt: serverTimestamp(),
      role: "user",
      balance: 0,
      teams: [],
      matches: []
    };
    
    await setDoc(doc(db, "users", user.uid), userData);
    console.log('✅ User data stored in Firestore');
    
    // Store token in localStorage
    const token = await user.getIdToken();
    localStorage.setItem("token", token);
    localStorage.setItem("user", JSON.stringify(userData));
    
    dispatch({ type: REGISTER_USER_SUCCESS, payload: userData });
    
    return { success: true, user: userData };
  } catch (error) {
    console.error('❌ Registration failed:', error);
    const errorMessage = getFirebaseErrorMessage(error.code);
    dispatch({ type: REGISTER_USER_FAIL, payload: errorMessage });
    return { success: false, message: errorMessage };
  }
};

// Login user with Firebase Auth
export const login = (formData) => async (dispatch) => {
  try {
    console.log('🔑 Starting login...');
    dispatch({ type: LOGIN_REQUEST });
    
    const { email, password } = formData;
    
    // Login with Firebase Auth
    const userCredential = await firebaseLogin(email, password);
    const user = userCredential.user;
    
    // Get additional user data from Firestore
    let userData = {
      uid: user.uid,
      _id: user.uid,
      email: user.email,
      role: "user"
    };
    
    try {
      const userDoc = await getDoc(doc(db, "users", user.uid));
      if (userDoc.exists()) {
        userData = { ...userData, ...userDoc.data() };
        console.log('✅ User data loaded from Firestore');
      } else {
        // Create user document if it doesn't exist
        const newUserData = {
          uid: user.uid,
          _id: user.uid,
          email: user.email,
          username: email.split('@')[0],
          createdAt: serverTimestamp(),
          role: "user",
          balance: 0
        };
        await setDoc(doc(db, "users", user.uid), newUserData);
        userData = { ...userData, ...newUserData };
        console.log('✅ New user document created');
      }
    } catch (firestoreError) {
      console.error('❌ Firestore error (permissions?):', firestoreError);
      // Continue with basic user data even if Firestore fails
    }
    
    // Check if user is admin and set isAdmin flag
    const ADMIN_EMAIL = 'rexoagency.in@gmail.com';
    if (userData.email === ADMIN_EMAIL) {
      userData.isAdmin = true;
      userData.role = 'super_admin';
      console.log('✅ Admin user detected');
    }
    
    // Store token in localStorage
    const token = await user.getIdToken();
    localStorage.setItem("token", token);
    localStorage.setItem("user", JSON.stringify(userData));
    
    dispatch({ type: LOGIN_SUCCESS, payload: userData });
    return { success: true, user: userData };
  } catch (error) {
    console.error('❌ Login failed:', error);
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
    console.error('❌ Logout error:', error);
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
    console.log('🔄 Loading user from storage...');
    dispatch({ type: LOAD_USER_REQUEST });
    
    const storedUser = localStorage.getItem("user");
    const token = localStorage.getItem("token");
    
    if (storedUser && token) {
      const userData = JSON.parse(storedUser);
      
      // Ensure admin flag is set for admin email
      const ADMIN_EMAIL = 'rexoagency.in@gmail.com';
      if (userData.email === ADMIN_EMAIL) {
        userData.isAdmin = true;
        userData.role = 'super_admin';
        // Update localStorage with admin flag
        localStorage.setItem("user", JSON.stringify(userData));
      }
      
      console.log('✅ User loaded from localStorage:', userData.uid);
      dispatch({ type: LOAD_USER_SUCCESS, payload: userData });
    } else {
      console.log('⚠️ No user in storage');
      dispatch({ type: LOAD_USER_FAIL });
    }
  } catch (error) {
    console.error('❌ Load user error:', error);
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
    'permission-denied': 'Permission denied. Check Firebase rules.',
    'unavailable': 'Service temporarily unavailable. Try again later.'
  };
  return errorMessages[code] || 'An error occurred. Please try again.';
};

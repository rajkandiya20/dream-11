import axios from "axios";
import { 
  auth, 
  registerUser as firebaseRegister, 
  loginUser as firebaseLogin,
  logoutUser as firebaseLogout,
  resetPassword as firebaseResetPassword,
  onAuthChange
} from "../firebase";
import { 
  doc, 
  setDoc, 
  getDoc, 
  updateDoc 
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

API.interceptors.request.use((req) => {
  if (localStorage.getItem("token")) {
    const servertoken = localStorage.getItem("token");
    req.headers.Authorization = `Bearer ${servertoken}`;
    req.headers.servertoken = servertoken;
    req.headers.ContentType = "application/json";
  }
  return req;
});

// Register user with Firebase Auth
export const register = (formData) => async (dispatch) => {
  try {
    dispatch({ type: REGISTER_USER_REQUEST });
    
    const { email, password, username, phoneNumber } = formData;
    
    // Create user in Firebase Auth
    const userCredential = await firebaseRegister(email, password);
    const user = userCredential.user;
    
    // Store additional user data in Firestore
    await setDoc(doc(db, "users", user.uid), {
      uid: user.uid,
      email: email,
      username: username,
      phoneNumber: phoneNumber,
      createdAt: new Date().toISOString(),
      role: email === "rexoagency.in@gmail.com" ? "admin" : "user"
    });
    
    // Store token in localStorage
    const token = await user.getIdToken();
    localStorage.setItem("token", token);
    localStorage.setItem("user", JSON.stringify({
      uid: user.uid,
      email: email,
      username: username,
      role: email === "rexoagency.in@gmail.com" ? "admin" : "user"
    }));
    
    dispatch({ 
      type: REGISTER_USER_SUCCESS, 
      payload: {
        uid: user.uid,
        email: email,
        username: username,
        role: email === "rexoagency.in@gmail.com" ? "admin" : "user"
      }
    });
    
    return { success: true };
  } catch (error) {
    console.log(error, "register error");
    dispatch({
      type: REGISTER_USER_FAIL,
      payload: error.message || "Registration failed",
    });
    return { success: false, message: error.message };
  }
};

// Login user with Firebase Auth
export const login = (formData) => async (dispatch) => {
  try {
    dispatch({ type: LOGIN_REQUEST });
    
    const { email, password } = formData;
    
    // Login with Firebase Auth
    const userCredential = await firebaseLogin(email, password);
    const user = userCredential.user;
    
    // Get additional user data from Firestore
    const userDoc = await getDoc(doc(db, "users", user.uid));
    let userData = {
      uid: user.uid,
      email: user.email,
      role: email === "rexoagency.in@gmail.com" ? "admin" : "user"
    };
    
    if (userDoc.exists()) {
      userData = { ...userData, ...userDoc.data() };
    } else {
      // Create user document if it doesn't exist
      await setDoc(doc(db, "users", user.uid), {
        uid: user.uid,
        email: user.email,
        username: email.split('@')[0],
        createdAt: new Date().toISOString(),
        role: email === "rexoagency.in@gmail.com" ? "admin" : "user"
      });
      userData.username = email.split('@')[0];
    }
    
    // Store token in localStorage
    const token = await user.getIdToken();
    localStorage.setItem("token", token);
    localStorage.setItem("user", JSON.stringify(userData));
    
    dispatch({ type: LOGIN_SUCCESS, payload: userData });
    return { success: true, user: userData };
  } catch (error) {
    console.log(error, "login error");
    dispatch({
      type: LOGIN_FAIL,
      payload: error.message || "Login failed",
    });
    return { success: false, message: error.message };
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
    console.log(error, "forgot password error");
    dispatch({ type: LOGIN_FAIL, payload: error.message });
    return { success: false, message: error.message };
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
    console.log(error, "logout error");
  }
};

export const addconfetti = () => async (dispatch) => {
  try {
    dispatch({ type: ADD_CONFETTI });
  } catch (error) {
    dispatch({ type: LOGIN_FAIL, payload: error.message });
  }
};

export const removeconfetti = () => async (dispatch) => {
  try {
    dispatch({ type: REMOVE_CONFETTI });
  } catch (error) {
    dispatch({ type: LOGIN_FAIL, payload: error.message });
  }
};

// Load user from Firebase Auth
export const loadUser = () => async (dispatch) => {
  try {
    dispatch({ type: LOAD_USER_REQUEST });
    
    const storedUser = localStorage.getItem("user");
    if (storedUser) {
      const userData = JSON.parse(storedUser);
      dispatch({ type: LOAD_USER_SUCCESS, payload: userData });
    }
  } catch (error) {
    console.log(error);
    dispatch({ type: LOAD_USER_FAIL });
  }
};

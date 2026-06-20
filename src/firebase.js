import { initializeApp } from "firebase/app";
import { getFirestore, connectFirestoreEmulator } from "firebase/firestore";
import { getStorage } from "firebase/storage";
import { getDatabase } from "firebase/database";
import { 
  getAuth, 
  createUserWithEmailAndPassword, 
  signInWithEmailAndPassword,
  signOut,
  sendPasswordResetEmail,
  onAuthStateChanged
} from "firebase/auth";

// Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDoR9h0NdjyLUrKtkHEsQ0iZvgWj4rgYEc",
  authDomain: "dream11local.firebaseapp.com",
  databaseURL: "https://dream11local-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "dream11local",
  storageBucket: "dream11local.firebasestorage.app",
  messagingSenderId: "325007849691",
  appId: "1:325007849691:web:2bc6df74747cf46e5234fe"
};

// Initialize Firebase
export const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
export const storage = getStorage(app);
export const realtimeDb = getDatabase(app);
export const auth = getAuth(app);
export default db;

// Enable debug logging
if (process.env.NODE_ENV === 'development') {
  console.log('🔥 Firebase initialized with project:', firebaseConfig.projectId);
}

// Auth helper functions with error handling
export const registerUser = async (email, password) => {
  try {
    console.log('🔥 Creating user with email:', email);
    const result = await createUserWithEmailAndPassword(auth, email, password);
    console.log('✅ User created successfully:', result.user.uid);
    return result;
  } catch (error) {
    console.error('❌ Register error:', error.code, error.message);
    throw error;
  }
};

export const loginUser = async (email, password) => {
  try {
    console.log('🔥 Logging in user:', email);
    const result = await signInWithEmailAndPassword(auth, email, password);
    console.log('✅ Login successful:', result.user.uid);
    return result;
  } catch (error) {
    console.error('❌ Login error:', error.code, error.message);
    throw error;
  }
};

export const logoutUser = async () => {
  try {
    console.log('🔥 Logging out user');
    await signOut(auth);
    console.log('✅ Logout successful');
    return true;
  } catch (error) {
    console.error('❌ Logout error:', error);
    throw error;
  }
};

export const resetPassword = async (email) => {
  try {
    console.log('🔥 Sending password reset email to:', email);
    await sendPasswordResetEmail(auth, email);
    console.log('✅ Password reset email sent');
    return true;
  } catch (error) {
    console.error('❌ Password reset error:', error);
    throw error;
  }
};

export const getCurrentUser = () => {
  const user = auth.currentUser;
  console.log('🔥 Current user:', user ? user.uid : 'No user');
  return user;
};

export const onAuthChange = (callback) => {
  console.log('🔥 Setting up auth state listener');
  return onAuthStateChanged(auth, (user) => {
    console.log('🔥 Auth state changed:', user ? user.uid : 'No user');
    callback(user);
  });
};

// Get fresh ID token
export const getFreshToken = async () => {
  const user = auth.currentUser;
  if (!user) {
    console.error('❌ No current user for token');
    return null;
  }
  try {
    const token = await user.getIdToken(true);
    console.log('✅ Fresh token obtained');
    return token;
  } catch (error) {
    console.error('❌ Error getting token:', error);
    return null;
  }
};

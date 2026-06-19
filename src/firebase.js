import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
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

export const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
export const storage = getStorage(app);
export const realtimeDb = getDatabase(app);
export const auth = getAuth(app);
export default db;

// Auth helper functions
export const registerUser = async (email, password) => {
  return await createUserWithEmailAndPassword(auth, email, password);
};

export const loginUser = async (email, password) => {
  return await signInWithEmailAndPassword(auth, email, password);
};

export const logoutUser = async () => {
  return await signOut(auth);
};

export const resetPassword = async (email) => {
  return await sendPasswordResetEmail(auth, email);
};

export const getCurrentUser = () => {
  return auth.currentUser;
};

export const onAuthChange = (callback) => {
  return onAuthStateChanged(auth, callback);
};

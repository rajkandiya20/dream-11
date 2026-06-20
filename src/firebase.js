import { initializeApp } from "firebase/app";
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
export const auth = getAuth(app);

// Enable debug logging
if (process.env.NODE_ENV === 'development') {
  console.log('🔥 Firebase initialized with project:', firebaseConfig.projectId);
}

// Auth helper functions with error handling
export const registerUser = async (email, password) => {
  try {
    if (process.env.NODE_ENV === 'development') {
      console.log('Creating user with email:', email);
    }
    const result = await createUserWithEmailAndPassword(auth, email, password);
    if (process.env.NODE_ENV === 'development') {
      console.log('User created successfully:', result.user.uid);
    }
    return result;
  } catch (error) {
    if (process.env.NODE_ENV === 'development') {
      console.error('Register error:', error.code, error.message);
    }
    throw error;
  }
};

export const loginUser = async (email, password) => {
  try {
    if (process.env.NODE_ENV === 'development') {
      console.log('Logging in user:', email);
    }
    const result = await signInWithEmailAndPassword(auth, email, password);
    if (process.env.NODE_ENV === 'development') {
      console.log('Login successful:', result.user.uid);
    }
    return result;
  } catch (error) {
    if (process.env.NODE_ENV === 'development') {
      console.error('Login error:', error.code, error.message);
    }
    throw error;
  }
};

export const logoutUser = async () => {
  try {
    if (process.env.NODE_ENV === 'development') {
      console.log('Logging out user');
    }
    await signOut(auth);
    if (process.env.NODE_ENV === 'development') {
      console.log('Logout successful');
    }
    return true;
  } catch (error) {
    if (process.env.NODE_ENV === 'development') {
      console.error('Logout error:', error);
    }
    throw error;
  }
};

export const resetPassword = async (email) => {
  try {
    if (process.env.NODE_ENV === 'development') {
      console.log('Sending password reset email to:', email);
    }
    await sendPasswordResetEmail(auth, email);
    if (process.env.NODE_ENV === 'development') {
      console.log('Password reset email sent');
    }
    return true;
  } catch (error) {
    if (process.env.NODE_ENV === 'development') {
      console.error('Password reset error:', error);
    }
    throw error;
  }
};

export const getCurrentUser = () => {
  const user = auth.currentUser;
  if (process.env.NODE_ENV === 'development') {
    console.log('Current user:', user ? user.uid : 'No user');
  }
  return user;
};

export const onAuthChange = (callback) => {
  if (process.env.NODE_ENV === 'development') {
    console.log('Setting up auth state listener');
  }
  return onAuthStateChanged(auth, (user) => {
    if (process.env.NODE_ENV === 'development') {
      console.log('Auth state changed:', user ? user.uid : 'No user');
    }
    callback(user);
  });
};

// Get fresh ID token
export const getFreshToken = async () => {
  const user = auth.currentUser;
  if (!user) {
    if (process.env.NODE_ENV === 'development') {
      console.error('No current user for token');
    }
    return null;
  }
  try {
    const token = await user.getIdToken(true);
    if (process.env.NODE_ENV === 'development') {
      console.log('Fresh token obtained');
    }
    return token;
  } catch (error) {
    if (process.env.NODE_ENV === 'development') {
      console.error('Error getting token:', error);
    }
    return null;
  }
};

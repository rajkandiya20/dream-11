import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";
import { getDatabase } from "firebase/database";

const firebaseConfig = {
  apiKey: "AIzaSyBlQ7Xg4MZPFWKONrPJE_piXg2B6VHiWHk",
  authDomain: "dream11local.firebaseapp.com",
  databaseURL: "https://dream11local-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "dream11local",
  storageBucket: "dream11local.firebasestorage.app",
  messagingSenderId: "325007849691",
  appId: "1:325007849691:android:1e80296e19d308fc5234fe"
};

export const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
export const storage = getStorage(app);
export const realtimeDb = getDatabase(app);
export default db;

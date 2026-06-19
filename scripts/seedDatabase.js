// Firebase Database Seeder Script
// Run this script to populate your Firestore database with sample data

import { initializeApp } from "firebase/app";
import { getFirestore, collection, doc, setDoc } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyDoR9h0NdjyLUrKtkHEsQ0iZvgWj4rgYEc",
  authDomain: "dream11local.firebaseapp.com",
  databaseURL: "https://dream11local-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "dream11local",
  storageBucket: "dream11local.firebasestorage.app",
  messagingSenderId: "325007849691",
  appId: "1:325007849691:web:2bc6df74747cf46e5234fe"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// ============ SAMPLE DATA ============

const sampleTeams = [
  { id: "team1", name: "Mumbai Indians", shortName: "MI", country: "India", flag: "https://example.com/mi.png" },
  { id: "team2", name: "Chennai Super Kings", shortName: "CSK", country: "India", flag: "https://example.com/csk.png" },
  { id: "team3", name: "Royal Challengers Bangalore", shortName: "RCB", country: "India", flag: "https://example.com/rcb.png" },
  { id: "team4", name: "Kolkata Knight Riders", shortName: "KKR", country: "India", flag: "https://example.com/kkr.png" }
];

const samplePlayers = [
  { id: "p1", name: "Virat Kohli", teamId: "team3", role: "batsman", credits: 10.5, photo: "" },
  { id: "p2", name: "MS Dhoni", teamId: "team2", role: "wicket-keeper", credits: 9.5, photo: "" },
  { id: "p3", name: "Rohit Sharma", teamId: "team1", role: "batsman", credits: 10, photo: "" },
  { id: "p4", name: "Jasprit Bumrah", teamId: "team1", role: "bowler", credits: 9, photo: "" },
  { id: "p5", name: "Hardik Pandya", teamId: "team1", role: "all-rounder", credits: 9, photo: "" },
  { id: "p6", name: "Ravindra Jadeja", teamId: "team2", role: "all-rounder", credits: 9, photo: "" }
];

const sampleTournaments = [
  { 
    id: "t1", 
    name: "Indian Premier League 2026", 
    shortName: "IPL 2026",
    status: "live",
    startDate: new Date("2026-03-01"),
    endDate: new Date("2026-05-30"),
    teams: ["team1", "team2", "team3", "team4"],
    matches: []
  }
];

const sampleMatches = [
  {
    id: "m1",
    tournamentId: "t1",
    home: { teamId: "team1", code: "MI", score: "" },
    away: { teamId: "team2", code: "CSK", score: "" },
    date: new Date("2026-06-20T19:30:00"),
    venue: "Wankhede Stadium, Mumbai",
    status: "upcoming",
    result: "",
    teamHomeFlagUrl: "https://example.com/mi.png",
    teamAwayFlagUrl: "https://example.com/csk.png"
  },
  {
    id: "m2",
    tournamentId: "t1",
    home: { teamId: "team3", code: "RCB", score: "" },
    away: { teamId: "team4", code: "KKR", score: "" },
    date: new Date("2026-06-21T19:30:00"),
    venue: "M. Chinnaswamy Stadium, Bangalore",
    status: "upcoming",
    result: "",
    teamHomeFlagUrl: "https://example.com/rcb.png",
    teamAwayFlagUrl: "https://example.com/kkr.png"
  }
];

const sampleContests = [
  {
    id: "c1",
    matchId: "m1",
    name: "Mega Contest",
    entryFee: 50,
    totalSpots: 1000,
    filledSpots: 750,
    prizePool: 40000,
    winners: 100,
    status: "open"
  },
  {
    id: "c2",
    matchId: "m1",
    name: "Head to Head",
    entryFee: 100,
    totalSpots: 2,
    filledSpots: 1,
    prizePool: 180,
    winners: 1,
    status: "open"
  }
];

const sampleAdmin = {
  uid: "ADMIN_UID_HERE", // Replace with actual admin UID
  email: "rexoagency.in@gmail.com",
  role: "super_admin",
  permissions: ["all"],
  createdAt: new Date()
};

// ============ SEED FUNCTION ============

async function seedDatabase() {
  console.log("🌱 Starting database seed...");

  try {
    // Seed Teams
    console.log("📝 Seeding teams...");
    for (const team of sampleTeams) {
      await setDoc(doc(db, "teams", team.id), team);
    }
    console.log("✅ Teams seeded");

    // Seed Players
    console.log("📝 Seeding players...");
    for (const player of samplePlayers) {
      await setDoc(doc(db, "players", player.id), player);
    }
    console.log("✅ Players seeded");

    // Seed Tournaments
    console.log("📝 Seeding tournaments...");
    for (const tournament of sampleTournaments) {
      await setDoc(doc(db, "tournaments", tournament.id), tournament);
    }
    console.log("✅ Tournaments seeded");

    // Seed Matches
    console.log("📝 Seeding matches...");
    for (const match of sampleMatches) {
      await setDoc(doc(db, "matches", match.id), match);
    }
    console.log("✅ Matches seeded");

    // Seed Contests
    console.log("📝 Seeding contests...");
    for (const contest of sampleContests) {
      await setDoc(doc(db, "contests", contest.id), contest);
    }
    console.log("✅ Contests seeded");

    // Seed Admin
    console.log("📝 Seeding admin...");
    await setDoc(doc(db, "admins", sampleAdmin.uid), sampleAdmin);
    console.log("✅ Admin seeded");

    console.log("🎉 Database seeding completed!");
  } catch (error) {
    console.error("❌ Error seeding database:", error);
  }
}

// Run the seed function
seedDatabase();

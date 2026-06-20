import "./App.css";

import { useEffect, useState } from "react";
import ReactCanvasConfetti from "react-confetti";
import { useDispatch, useSelector } from "react-redux";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import { loadUser } from "./actions/userAction";
import Completed from "./components/completed";
import ContestDetail from "./components/contestdetail";

import CreateTeam from "./components/createteam/createteam";
import { ForgotPassword } from "./components/forget-password";

import Home from "./components/home/home";
import JoinedContests from "./components/joinedcontests";
import Login from "./components/login";
import Contests from "./components/MatchDetails";
import Payment from "./components/payment";
import Players from "./components/players";
import Register from "./components/register";
import SavedTeam from "./components/savedteam";
import NewUsers from "./components/newUsers";
import FindPeople from "./components/findPeople/FindPeople";

import MyInfo from "./components/myinfo/MyInfo";
import TransactionTabs from "./components/transaction";
import Admin from "./components/admin/Admin";

import ContestManager from "./components/admin/ContestManager";
import PlayerManager from "./components/admin/PlayerManager";
import MatchManager from "./components/admin/MatchManager";
import TournamentManager from "./components/admin/TournamentManager";
import ScoreboardManager from "./components/admin/ScoreboardManager";
import ADeposit from "./components/admin/ADeposit";
import AWithdrawal from "./components/admin/Awithdrawal";
import ProtectedRoute from "./components/ProtectedRoute";
import SplashScreen from "./components/SplashScreen";
import Feed from "./components/feed/Feed";
import Groups from "./components/groups/Groups";
import More from "./components/more/More";
import Notifications from "./components/notifications/Notifications";

function App() {
  const dispatch = useDispatch();
  const { confetti } = useSelector((state) => state.user);
  const [showSplash, setShowSplash] = useState(true);

  const [dimensions, setDimensions] = useState({
    width: window.innerWidth,
    height: window.innerHeight,
  });

  const showAnimation = () => {
    setDimensions({
      width: window.innerWidth,
      height: window.innerHeight,
    });
  };

  // Show splash screen for 2.5 seconds on app load
  useEffect(() => {
    const splashTimer = setTimeout(() => {
      setShowSplash(false);
    }, 2500);
    return () => clearTimeout(splashTimer);
  }, []);

  useEffect(() => {
    window.addEventListener("resize", showAnimation);
    return () => {
      window.removeEventListener("resize", showAnimation);
    };
  }, [dimensions]);

  const { user, isAuthenticated, loading, error } = useSelector(
    (state) => state.user
  );

  useEffect(() => {
    dispatch(loadUser());
  }, [dispatch]);

  // Show splash screen on initial app load
  if (showSplash) {
    return <SplashScreen />;
  }

  return (
    <>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<ProtectedRoute><Home /></ProtectedRoute>} />
          <Route path="/register" element={<Register />} />
          <Route path="/login" element={<Login />} />
          <Route path="/completed/:id" element={<ProtectedRoute><Completed /></ProtectedRoute>} />
          <Route path="/players" element={<ProtectedRoute><Players /></ProtectedRoute>} />
          <Route path="/createteam/:id" element={<ProtectedRoute><CreateTeam /></ProtectedRoute>} />
          <Route path="/editTeam/:id" element={<ProtectedRoute><CreateTeam /></ProtectedRoute>} />
          <Route path="/contests/:id" element={<ProtectedRoute><Contests /></ProtectedRoute>} />
          <Route path="/forgot-password" element={<ForgotPassword />} />
          <Route path="/savedteam/:id" element={<ProtectedRoute><SavedTeam /></ProtectedRoute>} />
          <Route path="/contestdetail/:id" element={<ProtectedRoute><ContestDetail /></ProtectedRoute>} />
          <Route path="/joined" element={<ProtectedRoute><JoinedContests /></ProtectedRoute>} />

          <Route path="/payment" element={<ProtectedRoute><Payment /></ProtectedRoute>} />

          <Route path="/newusers" element={<ProtectedRoute><NewUsers /></ProtectedRoute>} />
          <Route path="/findpeople" element={<ProtectedRoute><FindPeople /></ProtectedRoute>} />
          <Route path="/my-info" element={<ProtectedRoute><MyInfo /></ProtectedRoute>} />
          <Route path="/transaction" element={<ProtectedRoute><TransactionTabs /></ProtectedRoute>} />
          <Route path="/admin" element={<ProtectedRoute><Admin/></ProtectedRoute>} />
          <Route path="/admin/contests" element={<ProtectedRoute><ContestManager/></ProtectedRoute>} />
          <Route path="/admin/players" element={<ProtectedRoute><PlayerManager/></ProtectedRoute>} />
          <Route path="/admin/matches" element={<ProtectedRoute><MatchManager/></ProtectedRoute>} />
          <Route path="/admin/tournaments" element={<ProtectedRoute><TournamentManager/></ProtectedRoute>} />
          <Route path="/admin/scoreboard" element={<ProtectedRoute><ScoreboardManager/></ProtectedRoute>} />
          <Route path="/admin/deposits" element={<ProtectedRoute><ADeposit/></ProtectedRoute>} />
          <Route path="/admin/withdrawals" element={<ProtectedRoute><AWithdrawal/></ProtectedRoute>} />
          <Route path="/feed" element={<ProtectedRoute><Feed/></ProtectedRoute>} />
          <Route path="/groups" element={<ProtectedRoute><Groups/></ProtectedRoute>} />
          <Route path="/more" element={<ProtectedRoute><More/></ProtectedRoute>} />
          <Route path="/notifications" element={<ProtectedRoute><Notifications/></ProtectedRoute>} />
        </Routes>
      </BrowserRouter>
      {confetti && (
        <ReactCanvasConfetti
          width={dimensions.width - 10}
          height={dimensions.height - 10}
          opacity={0.6}
        />
      )}
    </>
  );
}

export default App;

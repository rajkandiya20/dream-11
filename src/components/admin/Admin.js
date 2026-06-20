import styled from "@emotion/styled";
import { Box, Tabs, Tab, Typography, Button } from "@mui/material";
import AccountBalanceIcon from "@mui/icons-material/AccountBalance";
import SportsCricketIcon from "@mui/icons-material/SportsCricket";
import EmojiEventsIcon from "@mui/icons-material/EmojiEvents";
import GroupAddIcon from "@mui/icons-material/GroupAdd";
import PeopleIcon from "@mui/icons-material/People";
import LeaderboardIcon from "@mui/icons-material/Leaderboard";
import { useState, useEffect } from "react";
import { useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";
import ADeposit from "./ADeposit";
import AWithdrawal from "./Awithdrawal";
import TournamentManager from "./TournamentManager";
import MatchManager from "./MatchManager";
import ScoreboardManager from "./ScoreboardManager";
import PlayerManager from "./PlayerManager";
import ContestManager from "./ContestManager";
import TeamManager from "./TeamManager";
import Navbar from "../navbar";
import Bottomnav from "../navbar/bottomnavbar";
import { checkIsAdmin, ensureAdminDocument } from "../../services/adminService";
import { logRender } from "../../utils/logger";

const Container = styled.div`
  .MuiTabs-indicator {
    background-color: var(--green) !important;
    padding: 1px 0;
  }
  .Mui-selected {
    color: var(--black) !important;
    font-weight: 600;
  }
  .MuiTab-root {
    text-transform: capitalize;
    font-family: "Open Sans";
  }
`;

const Title = styled.h1`
  font-size: 18px;
  padding: 10px;
  background: var(--black);
  color: white;
  margin: 0;
`;

function TabPanel(props) {
  const { children, value, index, ...other } = props;

  return (
    <div role="tabpanel" hidden={value !== index} {...other}>
      {value === index && (
        <Box sx={{ p: 0 }}>
          <Typography>{children}</Typography>
        </Box>
      )}
    </div>
  );
}

export default function AdminDashboard() {
  const navigate = useNavigate();
  const [value, setValue] = useState(0);
  const { user, isAuthenticated } = useSelector((state) => state.user);
  const [isAdmin, setIsAdmin] = useState(false);

  useEffect(() => {
    logRender('AdminDashboard', 'mount');

    const verifyAdmin = async () => {
      const storedUser = JSON.parse(localStorage.getItem("user") || "{}");
      const storedToken = localStorage.getItem("token");
      const currentEmail = user?.email || storedUser?.email;
      const currentUid = user?.uid || storedUser?.uid;

      if (currentEmail && checkIsAdmin(currentEmail)) {
        setIsAdmin(true);
        // Ensure admin document exists in Firestore with super_admin role
        if (currentUid) {
          try {
            await ensureAdminDocument(currentUid, currentEmail);
          } catch (e) {
            // Silently handle - admin doc creation may fail due to Firestore rules
            console.log('Admin doc creation handled:', e?.message || 'ok');
          }
        }
      } else if (!isAuthenticated && !storedToken) {
        navigate("/login");
      } else {
        navigate("/");
      }
    };

    verifyAdmin();
  }, [user, isAuthenticated, navigate]);

  const handleChange = (event, newValue) => {
    setValue(newValue);
  };

  const ADMIN_TABS = [
    { label: "Deposit Approve", icon: <AccountBalanceIcon /> },
    { label: "Withdrawal Approve", icon: <AccountBalanceIcon /> },
    { label: "Tournaments", icon: <EmojiEventsIcon /> },
    { label: "Matches", icon: <SportsCricketIcon /> },
    { label: "Players", icon: <PeopleIcon /> },
    { label: "Contests", icon: <LeaderboardIcon /> },
    { label: "Scoreboard", icon: <GroupAddIcon /> },
    { label: "Teams", icon: <GroupAddIcon /> },
  ];

  if (!isAdmin) {
    return null;
  }

  return (
    <>
      <Navbar />
      <Title>Admin Dashboard</Title>
      <Container>
        <Box sx={{ width: "100%" }}>
          <Tabs
            value={value}
            onChange={handleChange}
            variant="scrollable"
            scrollButtons
            allowScrollButtonsMobile
          >
            {ADMIN_TABS.map((tab, index) => (
              <Tab key={index} label={tab.label} icon={tab.icon} />
            ))}
          </Tabs>
        </Box>

        <TabPanel value={value} index={0}>
          <ADeposit />
        </TabPanel>
        <TabPanel value={value} index={1}>
          <AWithdrawal />
        </TabPanel>
        <TabPanel value={value} index={2}>
          <TournamentManager />
        </TabPanel>
        <TabPanel value={value} index={3}>
          <MatchManager />
        </TabPanel>
        <TabPanel value={value} index={4}>
          <PlayerManager />
        </TabPanel>
        <TabPanel value={value} index={5}>
          <ContestManager />
        </TabPanel>
        <TabPanel value={value} index={6}>
          <ScoreboardManager />
        </TabPanel>
        <TabPanel value={value} index={7}>
          <TeamManager />
        </TabPanel>
      </Container>
      <Bottomnav />
    </>
  );
}

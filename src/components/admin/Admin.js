import styled from "@emotion/styled";
import { Box, Tabs, Tab, Typography, Button } from "@mui/material";
import AccountBalanceIcon from "@mui/icons-material/AccountBalance";
import SportsCricketIcon from "@mui/icons-material/SportsCricket";
import EmojiEventsIcon from "@mui/icons-material/EmojiEvents";
import GroupAddIcon from "@mui/icons-material/GroupAdd";
import { useState, useEffect } from "react";
import { useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";
import ADeposit from "./ADeposit";
import AWithdrawal from "./Awithdrawal";
import TournamentManager from "./TournamentManager";
import MatchManager from "./MatchManager";
import ScoreboardManager from "./ScoreboardManager";
import Navbar from "../navbar";
import Bottomnav from "../navbar/bottomnavbar";

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
    const adminEmail = "rexoagency.in@gmail.com";
    const storedUser = JSON.parse(localStorage.getItem("user") || "{}");
    const storedToken = localStorage.getItem("token");
    
    if (storedUser?.email === adminEmail || user?.email === adminEmail) {
      setIsAdmin(true);
    } else if (!isAuthenticated || !storedToken) {
      navigate("/login");
    }
  }, [user, isAuthenticated, navigate]);

  const handleChange = (event, newValue) => {
    setValue(newValue);
  };

  const ADMIN_TABS = [
    { label: "Deposit Approve", icon: <AccountBalanceIcon /> },
    { label: "Withdrawal Approve", icon: <AccountBalanceIcon /> },
    { label: "Tournaments", icon: <EmojiEventsIcon /> },
    { label: "Matches", icon: <SportsCricketIcon /> },
    { label: "Scoreboard", icon: <GroupAddIcon /> },
  ];

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
          <ScoreboardManager />
        </TabPanel>
      </Container>
      <Bottomnav />
    </>
  );
}
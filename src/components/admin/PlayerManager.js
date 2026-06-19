import styled from "@emotion/styled";
import { Button, TextField, Typography, Card, CardContent, Select, MenuItem, FormControl, InputLabel, Grid, IconButton } from "@mui/material";
import SportsCricketIcon from "@mui/icons-material/SportsCricket";
import AddIcon from "@mui/icons-material/Add";
import SearchIcon from "@mui/icons-material/Search";
import axios from "axios";
import { useState, useEffect } from "react";
import { useAlert } from "react-alert";
import { URL } from "../../constants/userConstants";

const Container = styled.div`
  padding: 20px;
`;

const CardWrapper = styled(Card)`
  margin-bottom: 15px;
`;

const SectionTitle = styled.h2`
  font-size: 18px;
  margin: 20px 0 15px;
  color: var(--black);
  border-bottom: 2px solid var(--green);
  padding-bottom: 5px;
`;

const PLAYER_ROLES = ["Batsman", "Bowler", "All-rounder", "WK"];

export default function PlayerManager() {
  const alert = useAlert();
  const [teams, setTeams] = useState([]);
  const [selectedTeam, setSelectedTeam] = useState(null);
  const [players, setPlayers] = useState([]);
  const [searchUser, setSearchUser] = useState("");
  const [searchResults, setSearchResults] = useState([]);
  const [openDialog, setOpenDialog] = useState(false);
  const [formData, setFormData] = useState({
    name: "",
    role: "Batsman",
    points: 0,
    userId: null,
  });

  useEffect(() => {
    fetchTeams();
  }, []);

  const fetchTeams = async () => {
    try {
      const { data } = await axios.get(`${URL}/admin/teams`);
      setTeams(data.teams || []);
    } catch (error) {
      alert.error("Failed to fetch teams");
    }
  };

  const fetchPlayers = async (teamId) => {
    try {
      const { data } = await axios.get(`${URL}/admin/players/${teamId}`);
      setPlayers(data.players || []);
    } catch (error) {
      alert.error("Failed to fetch players");
    }
  };

  const searchUserById = async () => {
    try {
      const { data } = await axios.get(`${URL}/admin/user/search?email=${searchUser}`);
      setSearchResults(data.users || []);
    } catch (error) {
      alert.error("Search failed");
    }
  };

  const handleAddPlayer = async () => {
    try {
      await axios.post(`${URL}/admin/players`, {
        teamId: selectedTeam?._id,
        ...formData,
      });
      alert.success("Player added successfully");
      setOpenDialog(false);
      setFormData({ name: "", role: "Batsman", points: 0, userId: null });
      fetchPlayers(selectedTeam?._id);
      setSearchResults([]);
    } catch (error) {
      alert.error("Failed to add player");
    }
  };

  const handleSelectUser = (user) => {
    setFormData({ ...formData, userId: user._id, name: user.username });
    setSearchResults([]);
  };

  return (
    <Container>
      <SectionTitle>Player Management</SectionTitle>

      <FormControl fullWidth style={{ marginBottom: "20px" }}>
        <InputLabel>Select Team</InputLabel>
        <Select
          value={selectedTeam?._id || ""}
          onChange={(e) => {
            const team = teams.find(t => t._id === e.target.value);
            setSelectedTeam(team);
            if (team) fetchPlayers(team._id);
          }}
        >
          {teams.map((team) => (
            <MenuItem key={team._id} value={team._id}>
              {team.name}
            </MenuItem>
          ))}
        </Select>
      </FormControl>

      {selectedTeam && (
        <>
          <Button variant="contained" onClick={() => setOpenDialog(true)} fullWidth>
            Add Player Manually
          </Button>

          <Grid container spacing={2} style={{ marginTop: "20px" }}>
            <Grid item xs={12}>
              <TextField
                label="Search User by Email/ID"
                value={searchUser}
                onChange={(e) => setSearchUser(e.target.value)}
                fullWidth
                InputProps={{
                  endAdornment: (
                    <IconButton onClick={searchUserById}>
                      <SearchIcon />
                    </IconButton>
                  ),
                }}
              />
              {searchResults.map((user) => (
                <Button key={user._id} onClick={() => handleSelectUser(user)}>
                  {user.username} ({user.email})
                </Button>
              ))}
            </Grid>

            {players.map((player) => (
              <Grid item xs={12} key={player._id}>
                <CardWrapper>
                  <CardContent>
                    <Typography variant="h6">{player.name}</Typography>
                    <Typography variant="body2" color="text.secondary">
                      Role: {player.role} | Points: {player.points}
                    </Typography>
                  </CardContent>
                </CardWrapper>
              </Grid>
            ))}
          </Grid>
        </>
      )}
    </Container>
  );
}
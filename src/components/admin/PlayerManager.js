import styled from "@emotion/styled";
import {
  Button,
  TextField,
  Typography,
  Card,
  CardContent,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Grid,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
} from "@mui/material";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import { useState, useEffect } from "react";
import { useAlert } from "react-alert";
import {
  getTeams,
  getPlayersForAdmin,
  createPlayer,
  updatePlayer,
  deletePlayer,
} from "../../services/supabaseService";
import { subscribeToPlayers } from "../../services/realtimeService";

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
  const [openDialog, setOpenDialog] = useState(false);
  const [editingPlayer, setEditingPlayer] = useState(null);
  const [formData, setFormData] = useState({
    name: "",
    role: "Batsman",
    credits: 8.0,
  });

  useEffect(() => {
    fetchTeams();
  }, []);

  useEffect(() => {
    if (!selectedTeam) return;

    fetchPlayers(selectedTeam.id);

    const unsubscribe = subscribeToPlayers(selectedTeam.id, (payload) => {
      const { eventType, new: newRecord, old: oldRecord } = payload;
      setPlayers((prev) => {
        if (eventType === "INSERT") {
          return [...prev, newRecord].sort((a, b) =>
            (a.name || "").localeCompare(b.name || "")
          );
        } else if (eventType === "UPDATE") {
          return prev.map((p) => (p.id === newRecord.id ? newRecord : p));
        } else if (eventType === "DELETE") {
          return prev.filter((p) => p.id !== oldRecord.id);
        }
        return prev;
      });
    });

    return () => {
      unsubscribe();
    };
  }, [selectedTeam]);

  const fetchTeams = async () => {
    const data = await getTeams();
    setTeams(data);
  };

  const fetchPlayers = async (teamId) => {
    const data = await getPlayersForAdmin(teamId);
    setPlayers(data);
  };

  const handleOpenCreate = () => {
    setEditingPlayer(null);
    setFormData({
      name: "",
      role: "Batsman",
      credits: 8.0,
    });
    setOpenDialog(true);
  };

  const handleOpenEdit = (player) => {
    setEditingPlayer(player);
    setFormData({
      name: player.name || "",
      role: player.role || "Batsman",
      credits: player.credits || 8.0,
    });
    setOpenDialog(true);
  };

  const handleSave = async () => {
    if (!formData.name.trim()) {
      alert.error("Player name is required");
      return;
    }
    if (!selectedTeam) {
      alert.error("Please select a team first");
      return;
    }

    try {
      const playerData = {
        ...formData,
        team_id: selectedTeam.id,
        credits: Number(formData.credits),
      };

      if (editingPlayer) {
        await updatePlayer(editingPlayer.id, playerData);
        alert.success("Player updated successfully");
      } else {
        await createPlayer(playerData);
        alert.success("Player added successfully");
      }
      setOpenDialog(false);
      fetchPlayers(selectedTeam.id);
    } catch (error) {
      alert.error(
        editingPlayer ? "Failed to update player" : "Failed to add player"
      );
    }
  };

  const handleDelete = async (playerId) => {
    if (!window.confirm("Are you sure you want to delete this player?")) {
      return;
    }
    try {
      await deletePlayer(playerId);
      alert.success("Player deleted successfully");
      fetchPlayers(selectedTeam.id);
    } catch (error) {
      alert.error("Failed to delete player");
    }
  };

  return (
    <Container>
      <SectionTitle>Player Management</SectionTitle>

      <FormControl fullWidth style={{ marginBottom: "20px" }}>
        <InputLabel>Select Team</InputLabel>
        <Select
          value={selectedTeam?.id || ""}
          onChange={(e) => {
            const team = teams.find((t) => t.id === e.target.value);
            setSelectedTeam(team || null);
          }}
          label="Select Team"
        >
          {teams.map((team) => (
            <MenuItem key={team.id} value={team.id}>
              {team.name}
            </MenuItem>
          ))}
        </Select>
      </FormControl>

      {selectedTeam && (
        <>
          <Button variant="contained" onClick={handleOpenCreate} fullWidth>
            Add Player
          </Button>

          <Grid container spacing={2} style={{ marginTop: "20px" }}>
            {players.map((player) => (
              <Grid item xs={12} key={player.id}>
                <CardWrapper>
                  <CardContent>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                      <div>
                        <Typography variant="h6">{player.name}</Typography>
                        <Typography variant="body2" color="text.secondary">
                          Role: {player.role} | Credits: {player.credits}
                        </Typography>
                      </div>
                      <div>
                        <IconButton size="small" onClick={() => handleOpenEdit(player)}>
                          <EditIcon fontSize="small" />
                        </IconButton>
                        <IconButton size="small" onClick={() => handleDelete(player.id)}>
                          <DeleteIcon fontSize="small" />
                        </IconButton>
                      </div>
                    </div>
                  </CardContent>
                </CardWrapper>
              </Grid>
            ))}
          </Grid>
        </>
      )}

      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} fullWidth maxWidth="sm">
        <DialogTitle>
          {editingPlayer ? "Edit Player" : "Add Player"}
        </DialogTitle>
        <DialogContent>
          <TextField
            label="Name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            fullWidth
            margin="normal"
          />
          <FormControl fullWidth margin="normal">
            <InputLabel>Role</InputLabel>
            <Select
              value={formData.role}
              onChange={(e) => setFormData({ ...formData, role: e.target.value })}
              label="Role"
            >
              {PLAYER_ROLES.map((role) => (
                <MenuItem key={role} value={role}>
                  {role}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
          <TextField
            label="Credits"
            type="number"
            value={formData.credits}
            onChange={(e) => setFormData({ ...formData, credits: e.target.value })}
            fullWidth
            margin="normal"
            inputProps={{ step: 0.5, min: 1, max: 20 }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDialog(false)}>Cancel</Button>
          <Button onClick={handleSave} variant="contained">
            {editingPlayer ? "Update" : "Add"}
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
}

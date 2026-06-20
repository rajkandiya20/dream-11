import styled from "@emotion/styled";
import {
  Button,
  Grid,
  TextField,
  Typography,
  Card,
  CardContent,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  IconButton,
} from "@mui/material";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import { useState, useEffect } from "react";
import { useAlert } from "react-alert";
import {
  getMatchesForAdmin,
  getTeams,
  getTournaments,
  createMatch,
  updateMatch,
  deleteMatch,
} from "../../services/supabaseService";
import { subscribeToMatches } from "../../services/realtimeService";

const Container = styled.div`
  padding: 20px;
`;

const MatchCard = styled(Card)`
  margin-bottom: 15px;
  cursor: pointer;
  &:hover {
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  }
`;

const SectionTitle = styled.h2`
  font-size: 18px;
  margin: 20px 0 15px;
  color: var(--black);
  border-bottom: 2px solid var(--green);
  padding-bottom: 5px;
`;

const StatusBadge = styled.span`
  display: inline-block;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  background-color: ${(props) => {
    switch (props.status) {
      case "live":
        return "#ffebee";
      case "upcoming":
      case "scheduled":
        return "#e3f2fd";
      case "completed":
        return "#e8f5e9";
      default:
        return "#f5f5f5";
    }
  }};
  color: ${(props) => {
    switch (props.status) {
      case "live":
        return "#c62828";
      case "upcoming":
      case "scheduled":
        return "#1565c0";
      case "completed":
        return "#2e7d32";
      default:
        return "#616161";
    }
  }};
`;

const MATCH_STATUSES = ["upcoming", "scheduled", "live", "completed", "cancelled"];

export default function MatchManager() {
  const alert = useAlert();
  const [matches, setMatches] = useState([]);
  const [tournaments, setTournaments] = useState([]);
  const [teams, setTeams] = useState([]);
  const [openDialog, setOpenDialog] = useState(false);
  const [editingMatch, setEditingMatch] = useState(null);
  const [formData, setFormData] = useState({
    tournament_id: "",
    team_a_id: "",
    team_b_id: "",
    team_a_name: "",
    team_b_name: "",
    date_time: "",
    venue: "",
    status: "upcoming",
  });

  useEffect(() => {
    fetchMatches();
    fetchTournaments();
    fetchTeams();

    const unsubscribe = subscribeToMatches((payload) => {
      const { eventType, new: newRecord, old: oldRecord } = payload;
      setMatches((prev) => {
        if (eventType === "INSERT") {
          return [newRecord, ...prev];
        } else if (eventType === "UPDATE") {
          return prev.map((m) => (m.id === newRecord.id ? newRecord : m));
        } else if (eventType === "DELETE") {
          return prev.filter((m) => m.id !== oldRecord.id);
        }
        return prev;
      });
    });

    return () => {
      unsubscribe();
    };
  }, []);

  const fetchMatches = async () => {
    const data = await getMatchesForAdmin();
    setMatches(data);
  };

  const fetchTournaments = async () => {
    const data = await getTournaments();
    setTournaments(data);
  };

  const fetchTeams = async () => {
    const data = await getTeams();
    setTeams(data);
  };

  const handleOpenCreate = () => {
    setEditingMatch(null);
    setFormData({
      tournament_id: "",
      team_a_id: "",
      team_b_id: "",
      team_a_name: "",
      team_b_name: "",
      date_time: "",
      venue: "",
      status: "upcoming",
    });
    setOpenDialog(true);
  };

  const handleOpenEdit = (match) => {
    setEditingMatch(match);
    setFormData({
      tournament_id: match.tournament_id || "",
      team_a_id: match.team_a_id || "",
      team_b_id: match.team_b_id || "",
      team_a_name: match.team_a_name || "",
      team_b_name: match.team_b_name || "",
      date_time: match.date_time ? match.date_time.slice(0, 16) : "",
      venue: match.venue || "",
      status: match.status || "upcoming",
    });
    setOpenDialog(true);
  };

  const handleTeamAChange = (teamId) => {
    const team = teams.find((t) => t.id === teamId);
    setFormData({
      ...formData,
      team_a_id: teamId,
      team_a_name: team ? team.name : "",
    });
  };

  const handleTeamBChange = (teamId) => {
    const team = teams.find((t) => t.id === teamId);
    setFormData({
      ...formData,
      team_b_id: teamId,
      team_b_name: team ? team.name : "",
    });
  };

  const handleSave = async () => {
    if (!formData.team_a_name || !formData.team_b_name) {
      alert.error("Both teams are required");
      return;
    }

    try {
      if (editingMatch) {
        await updateMatch(editingMatch.id, formData);
        alert.success("Match updated successfully");
      } else {
        await createMatch(formData);
        alert.success("Match created successfully");
      }
      setOpenDialog(false);
      fetchMatches();
    } catch (error) {
      alert.error(
        editingMatch ? "Failed to update match" : "Failed to create match"
      );
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure you want to delete this match?")) {
      return;
    }
    try {
      await deleteMatch(id);
      alert.success("Match deleted successfully");
      fetchMatches();
    } catch (error) {
      alert.error("Failed to delete match");
    }
  };

  return (
    <Container>
      <SectionTitle>Match Management</SectionTitle>
      <Button variant="contained" onClick={handleOpenCreate} fullWidth>
        Create New Match
      </Button>

      <Grid container spacing={2} style={{ marginTop: "20px" }}>
        {matches.map((match) => (
          <Grid item xs={12} key={match.id}>
            <MatchCard>
              <CardContent>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                  <div>
                    <Typography variant="h6" style={{ display: "flex", alignItems: "center" }}>
                      {match.team_a_flag && (
                        <img src={match.team_a_flag} alt={match.team_a_name} style={{ width: 24, height: 24, objectFit: "contain", marginRight: 6 }} />
                      )}
                      {match.team_a_name} vs{" "}
                      {match.team_b_flag && (
                        <img src={match.team_b_flag} alt={match.team_b_name} style={{ width: 24, height: 24, objectFit: "contain", marginLeft: 6, marginRight: 6 }} />
                      )}
                      {match.team_b_name}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      {match.venue} |{" "}
                      {match.date_time
                        ? new Date(match.date_time).toLocaleString()
                        : "TBD"}
                    </Typography>
                    {match.tournament && (
                      <Typography variant="caption" color="text.secondary">
                        {match.tournament.name}
                      </Typography>
                    )}
                    <div style={{ marginTop: 5 }}>
                      <StatusBadge status={match.status}>
                        {match.status || "unknown"}
                      </StatusBadge>
                    </div>
                  </div>
                  <div>
                    <IconButton size="small" onClick={() => handleOpenEdit(match)}>
                      <EditIcon fontSize="small" />
                    </IconButton>
                    <IconButton size="small" onClick={() => handleDelete(match.id)}>
                      <DeleteIcon fontSize="small" />
                    </IconButton>
                  </div>
                </div>
              </CardContent>
            </MatchCard>
          </Grid>
        ))}
      </Grid>

      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} fullWidth maxWidth="sm">
        <DialogTitle>
          {editingMatch ? "Edit Match" : "Create Match"}
        </DialogTitle>
        <DialogContent>
          <FormControl fullWidth margin="normal">
            <InputLabel>Tournament</InputLabel>
            <Select
              value={formData.tournament_id}
              onChange={(e) =>
                setFormData({ ...formData, tournament_id: e.target.value })
              }
              label="Tournament"
            >
              <MenuItem value="">None</MenuItem>
              {tournaments.map((t) => (
                <MenuItem key={t.id} value={t.id}>
                  {t.name}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          <FormControl fullWidth margin="normal">
            <InputLabel>Team A</InputLabel>
            <Select
              value={formData.team_a_id}
              onChange={(e) => handleTeamAChange(e.target.value)}
              label="Team A"
            >
              <MenuItem value="">Select Team</MenuItem>
              {teams.map((t) => (
                <MenuItem key={t.id} value={t.id}>
                  {t.name}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          <FormControl fullWidth margin="normal">
            <InputLabel>Team B</InputLabel>
            <Select
              value={formData.team_b_id}
              onChange={(e) => handleTeamBChange(e.target.value)}
              label="Team B"
            >
              <MenuItem value="">Select Team</MenuItem>
              {teams.map((t) => (
                <MenuItem key={t.id} value={t.id}>
                  {t.name}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          <TextField
            label="Date & Time"
            type="datetime-local"
            value={formData.date_time}
            onChange={(e) =>
              setFormData({ ...formData, date_time: e.target.value })
            }
            fullWidth
            margin="normal"
            InputLabelProps={{ shrink: true }}
          />

          <TextField
            label="Venue"
            value={formData.venue}
            onChange={(e) =>
              setFormData({ ...formData, venue: e.target.value })
            }
            fullWidth
            margin="normal"
          />

          <FormControl fullWidth margin="normal">
            <InputLabel>Status</InputLabel>
            <Select
              value={formData.status}
              onChange={(e) =>
                setFormData({ ...formData, status: e.target.value })
              }
              label="Status"
            >
              {MATCH_STATUSES.map((status) => (
                <MenuItem key={status} value={status}>
                  {status.charAt(0).toUpperCase() + status.slice(1)}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDialog(false)}>Cancel</Button>
          <Button onClick={handleSave} variant="contained">
            {editingMatch ? "Update" : "Create"}
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
}

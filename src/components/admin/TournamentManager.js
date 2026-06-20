import styled from "@emotion/styled";
import {
  Button,
  Grid,
  TextField,
  Typography,
  Card,
  CardContent,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
} from "@mui/material";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import { useState, useEffect } from "react";
import { useAlert } from "react-alert";
import {
  getTournaments,
  createTournament,
  updateTournament,
  deleteTournament,
} from "../../services/supabaseService";
import { subscribeToTournaments } from "../../services/realtimeService";
import uploadImage from "../../utils/imageUpload";

const Container = styled.div`
  padding: 20px;
`;

const TournamentCard = styled(Card)`
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
      case "active":
        return "#e8f5e9";
      case "upcoming":
        return "#e3f2fd";
      case "completed":
        return "#f3e5f5";
      default:
        return "#f5f5f5";
    }
  }};
  color: ${(props) => {
    switch (props.status) {
      case "active":
        return "#2e7d32";
      case "upcoming":
        return "#1565c0";
      case "completed":
        return "#7b1fa2";
      default:
        return "#616161";
    }
  }};
`;

const TOURNAMENT_STATUSES = ["upcoming", "active", "completed"];

export default function TournamentManager() {
  const alert = useAlert();
  const [tournaments, setTournaments] = useState([]);
  const [openDialog, setOpenDialog] = useState(false);
  const [editingTournament, setEditingTournament] = useState(null);
  const [formData, setFormData] = useState({
    name: "",
    logo: "",
    description: "",
    start_date: "",
    end_date: "",
    status: "upcoming",
  });

  useEffect(() => {
    fetchTournaments();

    const unsubscribe = subscribeToTournaments((payload) => {
      const { eventType, new: newRecord, old: oldRecord } = payload;
      setTournaments((prev) => {
        if (eventType === "INSERT") {
          return [newRecord, ...prev];
        } else if (eventType === "UPDATE") {
          return prev.map((t) => (t.id === newRecord.id ? newRecord : t));
        } else if (eventType === "DELETE") {
          return prev.filter((t) => t.id !== oldRecord.id);
        }
        return prev;
      });
    });

    return () => {
      unsubscribe();
    };
  }, []);

  const fetchTournaments = async () => {
    const data = await getTournaments();
    setTournaments(data);
  };

  const handleOpenCreate = () => {
    setEditingTournament(null);
    setFormData({
      name: "",
      logo: "",
      description: "",
      start_date: "",
      end_date: "",
      status: "upcoming",
    });
    setOpenDialog(true);
  };

  const handleOpenEdit = (tournament) => {
    setEditingTournament(tournament);
    setFormData({
      name: tournament.name || "",
      logo: tournament.logo || "",
      description: tournament.description || "",
      start_date: tournament.start_date ? tournament.start_date.split("T")[0] : "",
      end_date: tournament.end_date ? tournament.end_date.split("T")[0] : "",
      status: tournament.status || "upcoming",
    });
    setOpenDialog(true);
  };

  const handleSave = async () => {
    if (!formData.name.trim()) {
      alert.error("Tournament name is required");
      return;
    }

    try {
      if (editingTournament) {
        await updateTournament(editingTournament.id, formData);
        alert.success("Tournament updated successfully");
      } else {
        await createTournament(formData);
        alert.success("Tournament created successfully");
      }
      setOpenDialog(false);
      fetchTournaments();
    } catch (error) {
      alert.error(
        editingTournament
          ? "Failed to update tournament"
          : "Failed to create tournament"
      );
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure you want to delete this tournament?")) {
      return;
    }
    try {
      await deleteTournament(id);
      alert.success("Tournament deleted successfully");
      fetchTournaments();
    } catch (error) {
      alert.error("Failed to delete tournament");
    }
  };

  return (
    <Container>
      <SectionTitle>Tournament Management</SectionTitle>
      <Button variant="contained" onClick={handleOpenCreate} fullWidth>
        Create New Tournament
      </Button>

      <Grid container spacing={2} style={{ marginTop: "20px" }}>
        {tournaments.map((tournament) => (
          <Grid item xs={12} key={tournament.id}>
            <TournamentCard>
              <CardContent>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                  <div>
                    <Typography variant="h6">{tournament.name}</Typography>
                    <Typography variant="body2" color="text.secondary">
                      {tournament.description}
                    </Typography>
                    {tournament.start_date && (
                      <Typography variant="caption" color="text.secondary">
                        {new Date(tournament.start_date).toLocaleDateString()} -{" "}
                        {tournament.end_date
                          ? new Date(tournament.end_date).toLocaleDateString()
                          : "TBD"}
                      </Typography>
                    )}
                    <div style={{ marginTop: 5 }}>
                      <StatusBadge status={tournament.status}>
                        {tournament.status || "unknown"}
                      </StatusBadge>
                    </div>
                  </div>
                  <div>
                    <IconButton size="small" onClick={() => handleOpenEdit(tournament)}>
                      <EditIcon fontSize="small" />
                    </IconButton>
                    <IconButton size="small" onClick={() => handleDelete(tournament.id)}>
                      <DeleteIcon fontSize="small" />
                    </IconButton>
                  </div>
                </div>
              </CardContent>
            </TournamentCard>
          </Grid>
        ))}
      </Grid>

      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} fullWidth maxWidth="sm">
        <DialogTitle>
          {editingTournament ? "Edit Tournament" : "Create Tournament"}
        </DialogTitle>
        <DialogContent>
          <TextField
            label="Name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            fullWidth
            margin="normal"
          />
          <Typography variant="body2" sx={{ mt: 2, mb: 1 }}>
            Tournament Logo
          </Typography>
          <input
            type="file"
            accept="image/*"
            onChange={async (e) => {
              const file = e.target.files[0];
              if (!file) return;
              const url = await uploadImage(file, "tournaments");
              if (url) {
                setFormData((prev) => ({ ...prev, logo: url }));
              }
            }}
          />
          {formData.logo && (
            <img
              src={formData.logo}
              alt="Logo preview"
              style={{ width: 60, height: 60, objectFit: "contain", marginTop: 8, borderRadius: 8, border: "1px solid #eee" }}
            />
          )}
          <TextField
            label="Or enter Logo URL"
            value={formData.logo}
            onChange={(e) => setFormData({ ...formData, logo: e.target.value })}
            fullWidth
            margin="normal"
            size="small"
          />
          <TextField
            label="Description"
            value={formData.description}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            fullWidth
            multiline
            rows={3}
            margin="normal"
          />
          <TextField
            label="Start Date"
            type="date"
            value={formData.start_date}
            onChange={(e) => setFormData({ ...formData, start_date: e.target.value })}
            fullWidth
            margin="normal"
            InputLabelProps={{ shrink: true }}
          />
          <TextField
            label="End Date"
            type="date"
            value={formData.end_date}
            onChange={(e) => setFormData({ ...formData, end_date: e.target.value })}
            fullWidth
            margin="normal"
            InputLabelProps={{ shrink: true }}
          />
          <FormControl fullWidth margin="normal">
            <InputLabel>Status</InputLabel>
            <Select
              value={formData.status}
              onChange={(e) => setFormData({ ...formData, status: e.target.value })}
              label="Status"
            >
              {TOURNAMENT_STATUSES.map((status) => (
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
            {editingTournament ? "Update" : "Create"}
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
}

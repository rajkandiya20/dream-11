import styled from "@emotion/styled";
import {
  Button,
  Grid,
  TextField,
  Typography,
  Card,
  CardContent,
  IconButton,
  Drawer,
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
  getTeams,
  getTournaments,
  createTeam,
  updateTeam,
  deleteTeam,
} from "../../services/supabaseService";
import { subscribeToTeams } from "../../services/realtimeService";
import uploadImage from "../../utils/imageUpload";

const Container = styled.div`
  padding: 20px;
`;

const TeamCard = styled(Card)`
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

const ImagePreview = styled.img`
  width: 60px;
  height: 60px;
  object-fit: contain;
  border-radius: 8px;
  border: 1px solid #eee;
  margin-top: 8px;
`;

const SmallLogo = styled.img`
  width: 30px;
  height: 30px;
  object-fit: contain;
  border-radius: 4px;
  margin-right: 10px;
`;

export default function TeamManager() {
  const alert = useAlert();
  const [teams, setTeams] = useState([]);
  const [tournaments, setTournaments] = useState([]);
  const [openDialog, setOpenDialog] = useState(false);
  const [editingTeam, setEditingTeam] = useState(null);
  const [confirmingDelete, setConfirmingDelete] = useState(null);
  const [formData, setFormData] = useState({
    name: "",
    code: "",
    logo: "",
    flag: "",
    tournament_id: "",
  });
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    fetchTeams();
    fetchTournaments();

    const unsubscribe = subscribeToTeams((payload) => {
      const { eventType, new: newRecord, old: oldRecord } = payload;
      setTeams((prev) => {
        if (eventType === "INSERT") {
          return [...prev, newRecord].sort((a, b) =>
            (a.name || "").localeCompare(b.name || "")
          );
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

  const fetchTeams = async () => {
    const data = await getTeams();
    setTeams(data);
  };

  const fetchTournaments = async () => {
    const data = await getTournaments();
    setTournaments(data);
  };

  const handleOpenCreate = () => {
    setEditingTeam(null);
    setFormData({
      name: "",
      code: "",
      logo: "",
      flag: "",
      tournament_id: "",
    });
    setOpenDialog(true);
  };

  const handleOpenEdit = (team) => {
    setEditingTeam(team);
    setFormData({
      name: team.name || "",
      code: team.code || "",
      logo: team.logo || "",
      flag: team.flag || "",
      tournament_id: team.tournament_id || "",
    });
    setOpenDialog(true);
  };

  const handleLogoUpload = async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    setUploading(true);
    const url = await uploadImage(file, "teams/logos");
    if (url) {
      setFormData({ ...formData, logo: url });
      alert.success("Logo uploaded");
    } else {
      alert.error("Logo upload failed");
    }
    setUploading(false);
  };

  const handleFlagUpload = async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    setUploading(true);
    const url = await uploadImage(file, "teams/flags");
    if (url) {
      setFormData({ ...formData, flag: url });
      alert.success("Flag uploaded");
    } else {
      alert.error("Flag upload failed");
    }
    setUploading(false);
  };

  const handleSave = async () => {
    if (!formData.name.trim()) {
      alert.error("Team name is required");
      return;
    }
    if (!formData.code.trim()) {
      alert.error("Team code is required");
      return;
    }

    try {
      const teamData = { ...formData };
      if (!teamData.tournament_id) {
        delete teamData.tournament_id;
      }

      if (editingTeam) {
        await updateTeam(editingTeam.id, teamData);
        alert.success("Team updated successfully");
      } else {
        await createTeam(teamData);
        alert.success("Team created successfully");
      }
      setOpenDialog(false);
      fetchTeams();
    } catch (error) {
      alert.error(
        editingTeam ? "Failed to update team" : "Failed to create team"
      );
    }
  };

  const handleDelete = async (id) => {
    try {
      await deleteTeam(id);
      alert.success("Team deleted successfully");
      setConfirmingDelete(null);
      fetchTeams();
    } catch (error) {
      alert.error("Failed to delete team");
    }
  };

  const getTournamentName = (tournamentId) => {
    const t = tournaments.find((t) => t.id === tournamentId);
    return t ? t.name : "";
  };

  return (
    <Container>
      <SectionTitle>Team Management</SectionTitle>
      <Button variant="contained" onClick={handleOpenCreate} fullWidth>
        Create New Team
      </Button>

      <Grid container spacing={2} style={{ marginTop: "20px" }}>
        {teams.map((team) => (
          <Grid item xs={12} key={team.id}>
            <TeamCard>
              <CardContent>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                  <div style={{ display: "flex", alignItems: "center" }}>
                    {team.logo && <SmallLogo src={team.logo} alt={team.name} />}
                    <div>
                      <Typography variant="h6">
                        {team.name} ({team.code})
                      </Typography>
                      {team.tournament_id && (
                        <Typography variant="body2" color="text.secondary">
                          {getTournamentName(team.tournament_id)}
                        </Typography>
                      )}
                    </div>
                  </div>
                  <div>
                    <IconButton size="small" onClick={() => handleOpenEdit(team)}>
                      <EditIcon fontSize="small" />
                    </IconButton>
                    {confirmingDelete === team.id ? (
                      <span style={{ fontSize: "12px" }}>
                        Sure?{" "}
                        <Button size="small" color="error" onClick={() => handleDelete(team.id)}>Yes</Button>
                        <Button size="small" onClick={() => setConfirmingDelete(null)}>No</Button>
                      </span>
                    ) : (
                      <IconButton size="small" onClick={() => setConfirmingDelete(team.id)}>
                        <DeleteIcon fontSize="small" />
                      </IconButton>
                    )}
                  </div>
                </div>
              </CardContent>
            </TeamCard>
          </Grid>
        ))}
      </Grid>

      <Drawer anchor="bottom" open={openDialog} onClose={() => setOpenDialog(false)}>
        <div style={{ borderRadius: "16px 16px 0 0", maxHeight: "85vh", overflowY: "auto" }}>
          <div style={{ display: "flex", justifyContent: "center", padding: "10px 0 0" }}>
            <div style={{ width: "40px", height: "4px", borderRadius: "2px", backgroundColor: "#ccc" }} />
          </div>
          <div style={{ padding: "16px 20px 8px", borderBottom: "1px solid #eee" }}>
            <Typography variant="h6">
              {editingTeam ? "Edit Team" : "Create Team"}
            </Typography>
          </div>
          <div style={{ padding: "10px 20px 20px" }}>
          <TextField
            label="Team Name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            fullWidth
            margin="normal"
          />
          <TextField
            label="Team Code"
            value={formData.code}
            onChange={(e) => setFormData({ ...formData, code: e.target.value.toUpperCase() })}
            fullWidth
            margin="normal"
            placeholder="e.g. MI, CSK, RCB"
          />

          <Typography variant="body2" sx={{ mt: 2, mb: 1 }}>
            Team Logo
          </Typography>
          <input
            type="file"
            accept="image/*"
            onChange={handleLogoUpload}
            disabled={uploading}
          />
          {formData.logo && <ImagePreview src={formData.logo} alt="Logo preview" />}
          <TextField
            label="Or enter Logo URL"
            value={formData.logo}
            onChange={(e) => setFormData({ ...formData, logo: e.target.value })}
            fullWidth
            margin="normal"
            size="small"
          />

          <Typography variant="body2" sx={{ mt: 2, mb: 1 }}>
            Team Flag
          </Typography>
          <input
            type="file"
            accept="image/*"
            onChange={handleFlagUpload}
            disabled={uploading}
          />
          {formData.flag && <ImagePreview src={formData.flag} alt="Flag preview" />}
          <TextField
            label="Or enter Flag URL"
            value={formData.flag}
            onChange={(e) => setFormData({ ...formData, flag: e.target.value })}
            fullWidth
            margin="normal"
            size="small"
          />

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
          </div>
          <div style={{ position: "sticky", bottom: 0, backgroundColor: "#fff", padding: "12px 20px", borderTop: "1px solid #eee", display: "flex", justifyContent: "space-between" }}>
            <Button onClick={() => setOpenDialog(false)}>Cancel</Button>
            <Button onClick={handleSave} variant="contained" disabled={uploading}>
              {editingTeam ? "Update" : "Create"}
            </Button>
          </div>
        </div>
      </Drawer>
    </Container>
  );
}

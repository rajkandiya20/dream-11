import styled from "@emotion/styled";
import { Button, Grid, TextField, Typography, Card, CardContent, IconButton } from "@mui/material";
import AddPhotoAlternateIcon from "@mui/icons-material/AddPhotoAlternate";
import SportsCricketIcon from "@mui/icons-material/SportsCricket";
import EmojiEventsIcon from "@mui/icons-material/EmojiEvents";
import axios from "axios";
import { useState, useEffect } from "react";
import { useAlert } from "react-alert";
import { URL } from "../../constants/userConstants";

const Container = styled.div`
  padding: 20px;
`;

const TournamentCard = styled(Card)`
  margin-bottom: 15px;
  cursor: pointer;
  &:hover {
    box-shadow: 0 4px 20px rgba(0,0,0,0.15);
  }
`;

const SectionTitle = styled.h2`
  font-size: 18px;
  margin: 20px 0 15px;
  color: var(--black);
  border-bottom: 2px solid var(--green);
  padding-bottom: 5px;
`;

export default function TournamentManager() {
  const alert = useAlert();
  const [tournaments, setTournaments] = useState([]);
  const [openDialog, setOpenDialog] = useState(false);
  const [editingTournament, setEditingTournament] = useState(null);
  const [formData, setFormData] = useState({
    name: "",
    logo: null,
    description: "",
    startDate: "",
    endDate: "",
  });

  useEffect(() => {
    fetchTournaments();
  }, []);

  const fetchTournaments = async () => {
    try {
      const { data } = await axios.get(`${URL}/admin/tournaments`);
      setTournaments(data.tournaments || []);
    } catch (error) {
      alert.error("Failed to fetch tournaments");
    }
  };

  const handleCreateTournament = async () => {
    try {
      const form = new FormData();
      form.append("name", formData.name);
      form.append("description", formData.description);
      form.append("startDate", formData.startDate);
      form.append("endDate", formData.endDate);
      if (formData.logo) {
        form.append("logo", formData.logo);
      }

      await axios.post(`${URL}/admin/tournaments`, form, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      alert.success("Tournament created successfully");
      setOpenDialog(false);
      setFormData({ name: "", logo: null, description: "", startDate: "", endDate: "" });
      fetchTournaments();
    } catch (error) {
      alert.error("Failed to create tournament");
    }
  };

  const handleUpdateTournament = async () => {
    try {
      const form = new FormData();
      Object.keys(formData).forEach(key => {
        if (formData[key]) form.append(key, formData[key]);
      });

      await axios.put(`${URL}/admin/tournaments/${editingTournament._id}`, form, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      alert.success("Tournament updated successfully");
      setEditingTournament(null);
      setOpenDialog(false);
      fetchTournaments();
    } catch (error) {
      alert.error("Failed to update tournament");
    }
  };

  return (
    <Container>
      <SectionTitle>Tournament Management</SectionTitle>
      <Button variant="contained" onClick={() => setOpenDialog(true)} fullWidth>
        Create New Tournament
      </Button>

      <Grid container spacing={2} style={{ marginTop: "20px" }}>
        {tournaments.map((tournament) => (
          <Grid item xs={12} key={tournament._id}>
            <TournamentCard>
              <CardContent>
                <Typography variant="h6">{tournament.name}</Typography>
                <Typography variant="body2" color="text.secondary">
                  {tournament.description}
                </Typography>
              </CardContent>
            </TournamentCard>
          </Grid>
        ))}
      </Grid>
    </Container>
  );
}
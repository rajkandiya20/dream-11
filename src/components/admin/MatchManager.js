import styled from "@emotion/styled";
import { Button, Grid, TextField, Typography, Card, CardContent, Select, MenuItem, FormControl, InputLabel } from "@mui/material";
import SportsCricketIcon from "@mui/icons-material/SportsCricket";
import AccessTimeIcon from "@mui/icons-material/AccessTime";
import axios from "axios";
import { useState, useEffect } from "react";
import { useAlert } from "react-alert";
import { URL } from "../../constants/userConstants";

const Container = styled.div`
  padding: 20px;
`;

const MatchCard = styled(Card)`
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

export default function MatchManager() {
  const alert = useAlert();
  const [matches, setMatches] = useState([]);
  const [tournaments, setTournaments] = useState([]);
  const [openDialog, setOpenDialog] = useState(false);
  const [formData, setFormData] = useState({
    tournamentId: "",
    teamA: { name: "", logo: null },
    teamB: { name: "", logo: null },
    dateTime: "",
    venue: "",
  });

  useEffect(() => {
    fetchMatches();
    fetchTournaments();
  }, []);

  const fetchMatches = async () => {
    try {
      const { data } = await axios.get(`${URL}/admin/matches`);
      setMatches(data.matches || []);
    } catch (error) {
      alert.error("Failed to fetch matches");
    }
  };

  const fetchTournaments = async () => {
    try {
      const { data } = await axios.get(`${URL}/admin/tournaments`);
      setTournaments(data.tournaments || []);
    } catch (error) {
      console.log(error);
    }
  };

  const handleCreateMatch = async () => {
    try {
      const form = new FormData();
      form.append("tournamentId", formData.tournamentId);
      form.append("teamAName", formData.teamA.name);
      form.append("teamBName", formData.teamB.name);
      form.append("dateTime", formData.dateTime);
      form.append("venue", formData.venue);
      if (formData.teamA.logo) form.append("teamALogo", formData.teamA.logo);
      if (formData.teamB.logo) form.append("teamBLogo", formData.teamB.logo);

      await axios.post(`${URL}/admin/matches`, form, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      alert.success("Match created successfully");
      setOpenDialog(false);
      setFormData({
        tournamentId: "",
        teamA: { name: "", logo: null },
        teamB: { name: "", logo: null },
        dateTime: "",
        venue: "",
      });
      fetchMatches();
    } catch (error) {
      alert.error("Failed to create match");
    }
  };

  return (
    <Container>
      <SectionTitle>Match Management</SectionTitle>
      <Button variant="contained" onClick={() => setOpenDialog(true)} fullWidth>
        Create New Match
      </Button>

      <Grid container spacing={2} style={{ marginTop: "20px" }}>
        {matches.map((match) => (
          <Grid item xs={12} key={match._id}>
            <MatchCard>
              <CardContent>
                <Typography variant="h6">
                  {match.teamA?.name} vs {match.teamB?.name}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  {match.venue} | {new Date(match.dateTime).toLocaleString()}
                </Typography>
              </CardContent>
            </MatchCard>
          </Grid>
        ))}
      </Grid>
    </Container>
  );
}
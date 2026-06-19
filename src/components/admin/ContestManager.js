import styled from "@emotion/styled";
import { Button, TextField, Typography, Card, CardContent, Select, MenuItem, FormControl, InputLabel, IconButton, Grid } from "@mui/material";
import EmojiEventsIcon from "@mui/icons-material/EmojiEvents";
import AddIcon from "@mui/icons-material/Add";
import DeleteIcon from "@mui/icons-material/Delete";
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

export default function ContestManager() {
  const alert = useAlert();
  const [matches, setMatches] = useState([]);
  const [selectedMatch, setSelectedMatch] = useState(null);
  const [contests, setContests] = useState([]);
  const [openDialog, setOpenDialog] = useState(false);
  const [formData, setFormData] = useState({
    entryFee: 0,
    prizePool: 0,
    maxTeams: 0,
    contestType: "paid",
  });

  useEffect(() => {
    fetchMatches();
  }, []);

  const fetchMatches = async () => {
    try {
      const { data } = await axios.get(`${URL}/admin/matches`);
      setMatches(data.matches || []);
    } catch (error) {
      alert.error("Failed to fetch matches");
    }
  };

  const fetchContests = async (matchId) => {
    try {
      const { data } = await axios.get(`${URL}/admin/contests/${matchId}`);
      setContests(data.contests || []);
    } catch (error) {
      alert.error("Failed to fetch contests");
    }
  };

  const handleCreateContest = async () => {
    try {
      await axios.post(`${URL}/admin/contests`, {
        matchId: selectedMatch?._id,
        ...formData,
      });
      alert.success("Contest created successfully");
      setOpenDialog(false);
      setFormData({ entryFee: 0, prizePool: 0, maxTeams: 0, contestType: "paid" });
      fetchContests(selectedMatch?._id);
    } catch (error) {
      alert.error("Failed to create contest");
    }
  };

  const handleDeleteContest = async (contestId) => {
    try {
      await axios.delete(`${URL}/admin/contests/${contestId}`);
      alert.success("Contest deleted successfully");
      fetchContests(selectedMatch?._id);
    } catch (error) {
      alert.error("Failed to delete contest");
    }
  };

  return (
    <Container>
      <SectionTitle>Contest Management</SectionTitle>

      <FormControl fullWidth style={{ marginBottom: "20px" }}>
        <InputLabel>Select Match</InputLabel>
        <Select
          value={selectedMatch?._id || ""}
          onChange={(e) => {
            const match = matches.find(m => m._id === e.target.value);
            setSelectedMatch(match);
            if (match) fetchContests(match._id);
          }}
        >
          {matches.map((match) => (
            <MenuItem key={match._id} value={match._id}>
              {match.teamA?.name} vs {match.teamB?.name}
            </MenuItem>
          ))}
        </Select>
      </FormControl>

      {selectedMatch && (
        <>
          <Button variant="contained" onClick={() => setOpenDialog(true)} fullWidth>
            Create New Contest
          </Button>

          <Grid container spacing={2} style={{ marginTop: "20px" }}>
            {contests.map((contest) => (
              <Grid item xs={12} key={contest._id}>
                <CardWrapper>
                  <CardContent>
                    <Typography variant="h6">
                      Entry Fee: ₹{contest.entryFee} | Prize Pool: ₹{contest.prizePool}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      Max Teams: {contest.maxTeams} | Type: {contest.contestType}
                    </Typography>
                    <IconButton onClick={() => handleDeleteContest(contest._id)}>
                      <DeleteIcon />
                    </IconButton>
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
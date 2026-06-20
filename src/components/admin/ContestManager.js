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
  IconButton,
  Grid,
  Drawer,
} from "@mui/material";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import { useState, useEffect } from "react";
import { useAlert } from "react-alert";
import {
  getMatchesForAdmin,
  getContestsForAdmin,
  createContest,
  updateContest,
  deleteContest,
} from "../../services/supabaseService";
import { subscribeToContests } from "../../services/realtimeService";

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

const CONTEST_TYPES = ["paid", "free", "practice"];

export default function ContestManager() {
  const alert = useAlert();
  const [matches, setMatches] = useState([]);
  const [selectedMatch, setSelectedMatch] = useState(null);
  const [contests, setContests] = useState([]);
  const [openDialog, setOpenDialog] = useState(false);
  const [editingContest, setEditingContest] = useState(null);
  const [confirmingDelete, setConfirmingDelete] = useState(null);
  const [formData, setFormData] = useState({
    entry_fee: 0,
    prize_pool: 0,
    max_teams: 0,
    contest_type: "paid",
    status: "active",
  });

  useEffect(() => {
    fetchMatches();
  }, []);

  useEffect(() => {
    if (!selectedMatch) return;

    fetchContests(selectedMatch.id);

    const unsubscribe = subscribeToContests(selectedMatch.id, (payload) => {
      const { eventType, new: newRecord, old: oldRecord } = payload;
      setContests((prev) => {
        if (eventType === "INSERT") {
          return [newRecord, ...prev];
        } else if (eventType === "UPDATE") {
          return prev.map((c) => (c.id === newRecord.id ? newRecord : c));
        } else if (eventType === "DELETE") {
          return prev.filter((c) => c.id !== oldRecord.id);
        }
        return prev;
      });
    });

    return () => {
      unsubscribe();
    };
  }, [selectedMatch]);

  const fetchMatches = async () => {
    const data = await getMatchesForAdmin();
    setMatches(data);
  };

  const fetchContests = async (matchId) => {
    const data = await getContestsForAdmin(matchId);
    setContests(data);
  };

  const handleOpenCreate = () => {
    setEditingContest(null);
    setFormData({
      entry_fee: 0,
      prize_pool: 0,
      max_teams: 0,
      contest_type: "paid",
      status: "active",
    });
    setOpenDialog(true);
  };

  const handleOpenEdit = (contest) => {
    setEditingContest(contest);
    setFormData({
      entry_fee: contest.entry_fee || 0,
      prize_pool: contest.prize_pool || 0,
      max_teams: contest.max_teams || 0,
      contest_type: contest.contest_type || "paid",
      status: contest.status || "active",
    });
    setOpenDialog(true);
  };

  const handleSave = async () => {
    if (!selectedMatch) {
      alert.error("Please select a match first");
      return;
    }

    try {
      const contestData = {
        ...formData,
        match_id: selectedMatch.id,
        entry_fee: Number(formData.entry_fee),
        prize_pool: Number(formData.prize_pool),
        max_teams: Number(formData.max_teams),
      };

      if (editingContest) {
        await updateContest(editingContest.id, contestData);
        alert.success("Contest updated successfully");
      } else {
        await createContest(contestData);
        alert.success("Contest created successfully");
      }
      setOpenDialog(false);
      fetchContests(selectedMatch.id);
    } catch (error) {
      alert.error(
        editingContest ? "Failed to update contest" : "Failed to create contest"
      );
    }
  };

  const handleDelete = async (contestId) => {
    try {
      await deleteContest(contestId);
      alert.success("Contest deleted successfully");
      setConfirmingDelete(null);
      fetchContests(selectedMatch.id);
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
          value={selectedMatch?.id || ""}
          onChange={(e) => {
            const match = matches.find((m) => m.id === e.target.value);
            setSelectedMatch(match || null);
          }}
          label="Select Match"
        >
          {matches.map((match) => (
            <MenuItem key={match.id} value={match.id}>
              {match.team_a_name} vs {match.team_b_name}
            </MenuItem>
          ))}
        </Select>
      </FormControl>

      {selectedMatch && (
        <>
          <Button variant="contained" onClick={handleOpenCreate} fullWidth>
            Create New Contest
          </Button>

          <Grid container spacing={2} style={{ marginTop: "20px" }}>
            {contests.map((contest) => (
              <Grid item xs={12} key={contest.id}>
                <CardWrapper>
                  <CardContent>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                      <div>
                        <Typography variant="h6">
                          Entry Fee: {contest.entry_fee} | Prize Pool: {contest.prize_pool}
                        </Typography>
                        <Typography variant="body2" color="text.secondary">
                          Max Teams: {contest.max_teams} | Type: {contest.contest_type} | Status: {contest.status}
                        </Typography>
                        {contest.joined_teams !== undefined && (
                          <Typography variant="caption" color="text.secondary">
                            Joined: {contest.joined_teams}/{contest.max_teams}
                          </Typography>
                        )}
                      </div>
                      <div>
                        <IconButton size="small" onClick={() => handleOpenEdit(contest)}>
                          <EditIcon fontSize="small" />
                        </IconButton>
                        {confirmingDelete === contest.id ? (
                          <span style={{ fontSize: "12px" }}>
                            Sure?{" "}
                            <Button size="small" color="error" onClick={() => handleDelete(contest.id)}>Yes</Button>
                            <Button size="small" onClick={() => setConfirmingDelete(null)}>No</Button>
                          </span>
                        ) : (
                          <IconButton size="small" onClick={() => setConfirmingDelete(contest.id)}>
                            <DeleteIcon fontSize="small" />
                          </IconButton>
                        )}
                      </div>
                    </div>
                  </CardContent>
                </CardWrapper>
              </Grid>
            ))}
          </Grid>
        </>
      )}

      <Drawer anchor="bottom" open={openDialog} onClose={() => setOpenDialog(false)}>
        <div style={{ borderRadius: "16px 16px 0 0", maxHeight: "85vh", overflowY: "auto" }}>
          <div style={{ display: "flex", justifyContent: "center", padding: "10px 0 0" }}>
            <div style={{ width: "40px", height: "4px", borderRadius: "2px", backgroundColor: "#ccc" }} />
          </div>
          <div style={{ padding: "16px 20px 8px", borderBottom: "1px solid #eee" }}>
            <Typography variant="h6">
              {editingContest ? "Edit Contest" : "Create Contest"}
            </Typography>
          </div>
          <div style={{ padding: "10px 20px 20px" }}>
          <TextField
            label="Entry Fee"
            type="number"
            value={formData.entry_fee}
            onChange={(e) => setFormData({ ...formData, entry_fee: e.target.value })}
            fullWidth
            margin="normal"
          />
          <TextField
            label="Prize Pool"
            type="number"
            value={formData.prize_pool}
            onChange={(e) => setFormData({ ...formData, prize_pool: e.target.value })}
            fullWidth
            margin="normal"
          />
          <TextField
            label="Max Teams"
            type="number"
            value={formData.max_teams}
            onChange={(e) => setFormData({ ...formData, max_teams: e.target.value })}
            fullWidth
            margin="normal"
          />
          <FormControl fullWidth margin="normal">
            <InputLabel>Contest Type</InputLabel>
            <Select
              value={formData.contest_type}
              onChange={(e) => setFormData({ ...formData, contest_type: e.target.value })}
              label="Contest Type"
            >
              {CONTEST_TYPES.map((type) => (
                <MenuItem key={type} value={type}>
                  {type.charAt(0).toUpperCase() + type.slice(1)}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
          </div>
          <div style={{ position: "sticky", bottom: 0, backgroundColor: "#fff", padding: "12px 20px", borderTop: "1px solid #eee", display: "flex", justifyContent: "space-between" }}>
            <Button onClick={() => setOpenDialog(false)}>Cancel</Button>
            <Button onClick={handleSave} variant="contained">
              {editingContest ? "Update" : "Create"}
            </Button>
          </div>
        </div>
      </Drawer>
    </Container>
  );
}

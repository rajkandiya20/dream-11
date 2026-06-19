import styled from "@emotion/styled";
import { Button, Grid, TextField, Typography, Card, CardContent, Select, MenuItem, FormControl, InputLabel, Divider, IconButton } from "@mui/material";
import SportsCricketIcon from "@mui/icons-material/SportsCricket";
import AddIcon from "@mui/icons-material/Add";
import RemoveIcon from "@mui/icons-material/Remove";
import axios from "axios";
import { useState, useEffect } from "react";
import { useAlert } from "react-alert";
import { URL } from "../../constants/userConstants";

const Container = styled.div`
  padding: 20px;
`;

const ScoreCard = styled(Card)`
  margin-bottom: 15px;
`;

const SectionTitle = styled.h2`
  font-size: 18px;
  margin: 20px 0 15px;
  color: var(--black);
  border-bottom: 2px solid var(--green);
  padding-bottom: 5px;
`;

const ScoreRow = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid #eee;
`;

const TeamHeader = styled.div`
  background: var(--black);
  color: white;
  padding: 15px;
  text-align: center;
  font-weight: bold;
`;

const OUT_TYPES = ["Bowled", "Caught", "Run Out", "LBW", "Stumped", "Hit Wicket", "Retired Hurt"];

export default function ScoreboardManager() {
  const alert = useAlert();
  const [matches, setMatches] = useState([]);
  const [selectedMatch, setSelectedMatch] = useState(null);
  const [scoreData, setScoreData] = useState({
    teamAScore: 0,
    teamBScore: 0,
    teamAWickets: 0,
    teamBWickets: 0,
    teamAOvers: 0,
    teamBOvers: 0,
    striker: "",
    nonStriker: "",
    bowler: "",
    outType: "",
    catchBy: "",
    runs: 0,
    isWide: false,
    isNoBall: false,
    commentary: [],
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

  const handleAddRuns = (runs) => {
    const newScore = { ...scoreData, runs };
    const newCommentary = [
      ...scoreData.commentary,
      `${runs} runs scored by ${scoreData.striker || "batsman"}`,
    ];
    setScoreData({ ...newScore, commentary: newCommentary });
  };

  const handleWicket = () => {
    const newCommentary = [
      ...scoreData.commentary,
      `Wicket! ${scoreData.striker || "batsman"} is out (${scoreData.outType || "unknown"})`,
    ];
    setScoreData({ ...scoreData, commentary: newCommentary });
  };

  const handleSpecialBall = (type) => {
    const newCommentary = [...scoreData.commentary, `${type} ball!`];
    setScoreData({ ...scoreData, commentary: newCommentary, [type === "Wide" ? "isWide" : "isNoBall"]: true });
  };

  const saveScore = async () => {
    try {
      await axios.post(`${URL}/admin/scoreboard`, {
        matchId: selectedMatch?._id,
        scoreData,
      });
      alert.success("Score saved successfully");
    } catch (error) {
      alert.error("Failed to save score");
    }
  };

  return (
    <Container>
      <SectionTitle>Scoreboard Management</SectionTitle>

      <FormControl fullWidth style={{ marginBottom: "20px" }}>
        <InputLabel>Select Match</InputLabel>
        <Select
          value={selectedMatch?._id || ""}
          onChange={(e) => {
            const match = matches.find(m => m._id === e.target.value);
            setSelectedMatch(match);
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
          <ScoreCard>
            <TeamHeader>
              {selectedMatch.teamA?.name} vs {selectedMatch.teamB?.name}
            </TeamHeader>
            <CardContent>
              <ScoreRow>
                <Typography>Team A Score: {scoreData.teamAScore}/{scoreData.teamAWickets}</Typography>
                <Typography>Overs: {scoreData.teamAOvers}</Typography>
              </ScoreRow>
              <ScoreRow>
                <Typography>Team B Score: {scoreData.teamBScore}/{scoreData.teamBWickets}</Typography>
                <Typography>Overs: {scoreData.teamBOvers}</Typography>
              </ScoreRow>

              <Divider style={{ margin: "15px 0" }} />

              <TextField
                label="Striker"
                value={scoreData.striker}
                onChange={(e) => setScoreData({ ...scoreData, striker: e.target.value })}
                fullWidth
                style={{ marginBottom: "10px" }}
              />
              <TextField
                label="Non Striker"
                value={scoreData.nonStriker}
                onChange={(e) => setScoreData({ ...scoreData, nonStriker: e.target.value })}
                fullWidth
                style={{ marginBottom: "10px" }}
              />
              <TextField
                label="Bowler"
                value={scoreData.bowler}
                onChange={(e) => setScoreData({ ...scoreData, bowler: e.target.value })}
                fullWidth
                style={{ marginBottom: "10px" }}
              />

              <FormControl fullWidth style={{ marginBottom: "10px" }}>
                <InputLabel>Out Type</InputLabel>
                <Select
                  value={scoreData.outType}
                  onChange={(e) => setScoreData({ ...scoreData, outType: e.target.value })}
                >
                  <MenuItem value="">Select Out Type</MenuItem>
                  {OUT_TYPES.map((type) => (
                    <MenuItem key={type} value={type}>{type}</MenuItem>
                  ))}
                </Select>
              </FormControl>

              <TextField
                label="Catch By (if caught)"
                value={scoreData.catchBy}
                onChange={(e) => setScoreData({ ...scoreData, catchBy: e.target.value })}
                fullWidth
                style={{ marginBottom: "15px" }}
              />

              <Grid container spacing={1} style={{ marginBottom: "15px" }}>
                {[1, 2, 3, 4, 5, 6].map((runs) => (
                  <Grid item xs={2} key={runs}>
                    <Button variant="contained" fullWidth onClick={() => handleAddRuns(runs)}>
                      {runs}
                    </Button>
                  </Grid>
                ))}
              </Grid>

              <Grid container spacing={1} style={{ marginBottom: "15px" }}>
                <Grid item xs={6}>
                  <Button variant="outlined" color="error" fullWidth onClick={handleWicket}>
                    Wicket
                  </Button>
                </Grid>
                <Grid item xs={6}>
                  <Button variant="outlined" color="warning" fullWidth onClick={() => handleSpecialBall("Wide")}>
                    Wide
                  </Button>
                </Grid>
              </Grid>

              <Grid container spacing={1} style={{ marginBottom: "15px" }}>
                <Grid item xs={6}>
                  <Button variant="outlined" color="warning" fullWidth onClick={() => handleSpecialBall("No Ball")}>
                    No Ball
                  </Button>
                </Grid>
              </Grid>

              <Button variant="contained" color="success" fullWidth onClick={saveScore}>
                Save Score
              </Button>

              <Divider style={{ margin: "15px 0" }} />
              <Typography variant="h6">Commentary</Typography>
              {scoreData.commentary.map((entry, index) => (
                <Typography key={index} variant="body2">• {entry}</Typography>
              ))}
            </CardContent>
          </ScoreCard>
        </>
      )}
    </Container>
  );
}
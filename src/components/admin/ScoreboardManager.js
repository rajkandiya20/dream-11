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
  Divider,
} from "@mui/material";
import { useState, useEffect } from "react";
import { useAlert } from "react-alert";
import {
  getMatchesForAdmin,
  getScoreboard,
  updateScoreboard,
} from "../../services/supabaseService";
import { subscribeToScoreboard } from "../../services/realtimeService";

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
  const [scoreboard, setScoreboard] = useState([]);
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

  useEffect(() => {
    if (!selectedMatch) return;

    fetchScoreboard(selectedMatch.id);

    const unsubscribe = subscribeToScoreboard(selectedMatch.id, (payload) => {
      const { eventType, new: newRecord, old: oldRecord } = payload;
      setScoreboard((prev) => {
        if (eventType === "INSERT") {
          return [...prev, newRecord];
        } else if (eventType === "UPDATE") {
          return prev.map((s) => (s.id === newRecord.id ? newRecord : s));
        } else if (eventType === "DELETE") {
          return prev.filter((s) => s.id !== oldRecord.id);
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

  const fetchScoreboard = async (matchId) => {
    const data = await getScoreboard(matchId);
    setScoreboard(data);
  };

  const handleAddRuns = (runs) => {
    const newCommentary = [
      ...scoreData.commentary,
      `${runs} runs scored by ${scoreData.striker || "batsman"}`,
    ];
    setScoreData({ ...scoreData, runs, commentary: newCommentary });
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
    setScoreData({
      ...scoreData,
      commentary: newCommentary,
      [type === "Wide" ? "isWide" : "isNoBall"]: true,
    });
  };

  const saveScore = async () => {
    if (!selectedMatch) {
      alert.error("Please select a match");
      return;
    }

    try {
      await updateScoreboard(selectedMatch.id, {
        player_id: selectedMatch.id,
        points: scoreData.teamAScore + scoreData.teamBScore,
        runs: scoreData.teamAScore,
        wickets: scoreData.teamAWickets,
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
          <ScoreCard>
            <TeamHeader>
              {selectedMatch.team_a_name} vs {selectedMatch.team_b_name}
            </TeamHeader>
            <CardContent>
              <ScoreRow>
                <Typography>
                  Team A Score: {scoreData.teamAScore}/{scoreData.teamAWickets}
                </Typography>
                <Typography>Overs: {scoreData.teamAOvers}</Typography>
              </ScoreRow>
              <ScoreRow>
                <Typography>
                  Team B Score: {scoreData.teamBScore}/{scoreData.teamBWickets}
                </Typography>
                <Typography>Overs: {scoreData.teamBOvers}</Typography>
              </ScoreRow>

              <Divider style={{ margin: "15px 0" }} />

              <TextField
                label="Striker"
                value={scoreData.striker}
                onChange={(e) =>
                  setScoreData({ ...scoreData, striker: e.target.value })
                }
                fullWidth
                style={{ marginBottom: "10px" }}
              />
              <TextField
                label="Non Striker"
                value={scoreData.nonStriker}
                onChange={(e) =>
                  setScoreData({ ...scoreData, nonStriker: e.target.value })
                }
                fullWidth
                style={{ marginBottom: "10px" }}
              />
              <TextField
                label="Bowler"
                value={scoreData.bowler}
                onChange={(e) =>
                  setScoreData({ ...scoreData, bowler: e.target.value })
                }
                fullWidth
                style={{ marginBottom: "10px" }}
              />

              <FormControl fullWidth style={{ marginBottom: "10px" }}>
                <InputLabel>Out Type</InputLabel>
                <Select
                  value={scoreData.outType}
                  onChange={(e) =>
                    setScoreData({ ...scoreData, outType: e.target.value })
                  }
                  label="Out Type"
                >
                  <MenuItem value="">Select Out Type</MenuItem>
                  {OUT_TYPES.map((type) => (
                    <MenuItem key={type} value={type}>
                      {type}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>

              <TextField
                label="Catch By (if caught)"
                value={scoreData.catchBy}
                onChange={(e) =>
                  setScoreData({ ...scoreData, catchBy: e.target.value })
                }
                fullWidth
                style={{ marginBottom: "15px" }}
              />

              <Grid container spacing={1} style={{ marginBottom: "15px" }}>
                {[1, 2, 3, 4, 5, 6].map((runs) => (
                  <Grid item xs={2} key={runs}>
                    <Button
                      variant="contained"
                      fullWidth
                      onClick={() => handleAddRuns(runs)}
                    >
                      {runs}
                    </Button>
                  </Grid>
                ))}
              </Grid>

              <Grid container spacing={1} style={{ marginBottom: "15px" }}>
                <Grid item xs={6}>
                  <Button
                    variant="outlined"
                    color="error"
                    fullWidth
                    onClick={handleWicket}
                  >
                    Wicket
                  </Button>
                </Grid>
                <Grid item xs={6}>
                  <Button
                    variant="outlined"
                    color="warning"
                    fullWidth
                    onClick={() => handleSpecialBall("Wide")}
                  >
                    Wide
                  </Button>
                </Grid>
              </Grid>

              <Grid container spacing={1} style={{ marginBottom: "15px" }}>
                <Grid item xs={6}>
                  <Button
                    variant="outlined"
                    color="warning"
                    fullWidth
                    onClick={() => handleSpecialBall("No Ball")}
                  >
                    No Ball
                  </Button>
                </Grid>
              </Grid>

              <Button
                variant="contained"
                color="success"
                fullWidth
                onClick={saveScore}
              >
                Save Score
              </Button>

              <Divider style={{ margin: "15px 0" }} />
              <Typography variant="h6">Commentary</Typography>
              {scoreData.commentary.map((entry, index) => (
                <Typography key={index} variant="body2">
                  {entry}
                </Typography>
              ))}

              {scoreboard.length > 0 && (
                <>
                  <Divider style={{ margin: "15px 0" }} />
                  <Typography variant="h6">Player Scores</Typography>
                  {scoreboard.map((entry) => (
                    <ScoreRow key={entry.id}>
                      <Typography variant="body2">
                        {entry.player?.name || "Unknown"}
                      </Typography>
                      <Typography variant="body2">
                        Pts: {entry.points} | R: {entry.runs} | W: {entry.wickets}
                      </Typography>
                    </ScoreRow>
                  ))}
                </>
              )}
            </CardContent>
          </ScoreCard>
        </>
      )}
    </Container>
  );
}

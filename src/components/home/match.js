import "./home.css";
import styled from "@emotion/styled";
import NotificationAddOutlinedIcon from "@mui/icons-material/NotificationAddOutlined";
import SportsCricketOutlinedIcon from "@mui/icons-material/SportsCricket";
import LinearProgress from "@mui/material/LinearProgress";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  getDisplayDate,
  hoursRemaining,
  isTommorrow,
  sameDayorNot,
} from "../../utils/dateformat";

const Top = styled.div`
  display: flex;
  justify-content: space-between;
  color: #595959;
  align-items: center;
  border-bottom: 1px solid rgba(196, 195, 195, 0.15);
  padding: 5px 15px;
  background-color: #ffffff;
`;

export function Match({ match }) {
  const [date, setDate] = useState(new Date());
  const navigate = useNavigate();

  useEffect(() => {
    const i = setInterval(() => setDate(new Date()), 1000);
    return () => clearInterval(i);
  }, []);

  if (!match) return null;

  // Support both Supabase format and old API format
  const teamACode = match.team_a_code || match?.away?.code || 'TBA';
  const teamBCode = match.team_b_code || match?.home?.code || 'TBA';
  const teamAFlag = match.team_a_flag || match?.teamAwayFlagUrl || match?.away?.flag || '';
  const teamBFlag = match.team_b_flag || match?.teamHomeFlagUrl || match?.home?.flag || '';
  const matchDate = match.date_time || match.date;
  const matchId = match.id || match._id;
  const isLive = match.live || match.status === 'live';
  const isCompleted = match.status === 'completed' || match.result === 'Yes';
  const lineups = match.lineups || '';

  return (
    <div
      className="matchcontainer"
      onClick={() => navigate(`/contests/${matchId}`)}
    >
      <Top>
        <h5
          style={{
            color: "#595959",
            fontSize: "12px",
            fontWeight: "800",
            display: "flex",
            alignItems: "center",
          }}
        >
          <span style={{ marginRight: "5px" }}>{teamACode}</span> vs
          <span style={{ marginLeft: "5px" }}>{teamBCode}</span>
        </h5>
        <h5
          style={{
            marginLeft: "90px",
            color: "rgb(31, 169, 81)",
            fontFamily: "Montserrat",
          }}
        >
          {isLive ? 'LIVE' : lineups}
        </h5>
        <NotificationAddOutlinedIcon style={{ fontSize: "18px" }} />
      </Top>
      <div className="match">
        <div className="matchcenter">
          <div className="matchlefts">
            {teamAFlag && <img src={teamAFlag} alt={teamACode} width="40" />}
            <h5>{teamACode}</h5>
          </div>
          {isLive ? (
            <div style={{ width: "40px", textAlign: "center" }}>
              <h5 style={{ color: "var(--green)", marginBottom: "3px" }}>live</h5>
              <LinearProgress color="success" />
            </div>
          ) : (
            <h5 className={isCompleted ? "completed" : "time"}>
              {isCompleted ? (
                "Completed"
              ) : matchDate ? (
                sameDayorNot(new Date(), new Date(matchDate)) ||
                isTommorrow(new Date(), new Date(matchDate)) ? (
                  <div>
                    <p>{hoursRemaining(matchDate, "k", date)}</p>
                    <p style={{ color: "#5e5b5b", fontSize: "10px", marginTop: "2px" }}>
                      {getDisplayDate(matchDate, "i", date)}
                    </p>
                  </div>
                ) : (
                  <p style={{ color: "#e10000" }}>
                    {getDisplayDate(matchDate, "i")}
                  </p>
                )
              ) : (
                "TBA"
              )}
            </h5>
          )}
          <div className="matchrights">
            <h5>{teamBCode}</h5>
            {teamBFlag && <img src={teamBFlag} alt={teamBCode} width="40" />}
          </div>
        </div>
      </div>
      <div className="bottom">
        <div className="meta">
          <div className="mega">Mega</div>
          <div className="meg">
            <h5 style={{ fontSize: "10px", textTransform: "uppercase" }}>
              {match.venue || 'Fantasy Cricket'}
            </h5>
          </div>
        </div>
        <div className="icon">
          <SportsCricketOutlinedIcon
            style={{ color: "#595959", fontSize: "18px" }}
          />
        </div>
      </div>
    </div>
  );
}

export default Match;

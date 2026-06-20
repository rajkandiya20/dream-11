import "./home.css";

import styled from "@emotion/styled";
import ArrowForwardIosIcon from "@mui/icons-material/ArrowForwardIos";
import NotificationAddOutlinedIcon from "@mui/icons-material/NotificationAddOutlined";
import PersonOutlineOutlinedIcon from "@mui/icons-material/PersonOutlineOutlined";
import { Button, Alert, Snackbar } from "@mui/material";
import LinearProgress from "@mui/material/LinearProgress";
import axios from "axios";
import { useEffect, useState, useCallback } from "react";
import { useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";
import Match from "./match";
import { URL } from "../../constants/userConstants";
import { getUpcomingMatches, getLiveMatches, getCompletedMatches } from "../../services/supabaseService";
import { subscribeToMatches } from "../../services/realtimeService";
import {
  getDisplayDate,
  hoursRemaining,
  isTommorrow,
  sameDayorNot,
} from "../../utils/dateformat";
import Bottomnav from "../navbar/bottomnavbar";
import Loader from "../loader";
import Navbar from "../navbar";
import { SportsCricketOutlined } from "@mui/icons-material";

const RightSide = styled.div`
  width: 90px;
  display: flex;
  justify-content: center;
  align-items: center;
`;

const Account = styled.h3`
  font-size: 12px;
`;
const Center = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 20px;
  font-weight: 700;
`;

const AddButton = styled(Button)`
  background-color: var(--green);
  color: #ffffff;
  width: 160px;
  margin: 0 auto;
  &:hover {
    background-color: var(--green);
    color: #ffffff;
  }
`;

const Deatil = styled.div`
  border-top: 1px solid #dddddd;
  margin-top: 10px;
  text-align: left;
  padding: 10px 0;
  p {
    color: rgba(0, 0, 0, 0.6);
    text-transform: uppercase;
  }
`;

const DeatilTop = styled.div`
  margin-top: 10px;
  text-align: center;
  padding: 10px 0;
  p {
    color: rgba(0, 0, 0, 0.6);
    text-transform: uppercase;
  }
`;

const CricketBg = styled.div`
  background-image: url("./cricketbg.jpg");
  box-sizing: border-box;
  padding: 10px 10px;
  height: 150px;
  margin-bottom: 60px;
  position: relative;
  background-size: cover;
`;

const Top = styled.div`
  display: flex;
  justify-content: space-between;
  color: #595959;
  align-items: center;
  border-bottom: 1px solid rgba(196, 195, 195, 0.15);
  padding: 5px 15px;
  background-color: #ffffff;
`;

const Dot = styled.div`
  background-color: var(--green) !important;
  width: 7px;
  height: 7px;
  border-radius: 50%;
  margin-right: 5px;
`;

const TopDiv = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
`;
const ViewAll = styled(Button)`
  color: #ffffff;
  text-transform: capitalize;
  font-weight: 800;
  font-size: 18px;
`;

const Spanner = styled.div`
  width: 20px;
  height: 5px;
`;

const ErrorContainer = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 50vh;
  padding: 20px;
  text-align: center;
`;

const RetryButton = styled(Button)`
  margin-top: 20px;
  background-color: var(--green);
  color: white;
  &:hover {
    background-color: #0d7a2c;
  }
`;

export function Home() {
  const { user, isAuthenticated, loading: userLoading } = useSelector((state) => state.user);
  const [upcoming, setUpcoming] = useState([]);
  const [loading, setLoading] = useState(true);
  const [apiError, setApiError] = useState(null);
  const [date, setDate] = useState();
  const [live, setLive] = useState([]);
  const [past, setPast] = useState([]);
  const [open, setOpen] = useState(false);
  const [retryCount, setRetryCount] = useState(0);
  const navigate = useNavigate();

  // Maximum retries and timeout
  const MAX_RETRIES = 3;
  const API_TIMEOUT = 10000; // 10 seconds

  // Fetch matches from Supabase as primary data source
  const fetchMatchesFromSupabase = async () => {
    try {
      const [upcomingData, liveData, completedData] = await Promise.all([
        getUpcomingMatches(),
        getLiveMatches(),
        getCompletedMatches()
      ]);

      // Even if empty, return the arrays (empty state is valid)
      return { upcoming: upcomingData || [], live: liveData || [], past: completedData || [] };
    } catch (error) {
      console.error("Error fetching from Supabase:", error);
      return null;
    }
  };

  // Fetch data with error handling
  const fetchData = useCallback(async () => {
    setLoading(true);
    setApiError(null);

    // Try Supabase first (doesn't need userId)
    const supabaseData = await fetchMatchesFromSupabase();
    if (supabaseData) {
      setUpcoming(supabaseData.upcoming || []);
      setLive(supabaseData.live || []);
      if (supabaseData.past?.length > 0) {
        setPast([supabaseData.past[0]]);
      }
      setLoading(false);
      setApiError(null);
      setRetryCount(0);
      return;
    }

    // Fallback to backend API (needs userId)
    const userId = user?._id || user?.uid;
    if (!userId) {
      setLoading(false);
      return;
    }
    try {
      // Create axios instance with timeout
      const api = axios.create({
        timeout: API_TIMEOUT,
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        }
      });

      // Fetch upcoming matches
      console.log('Fetching upcoming matches from API...');
      const upcomingResponse = await api.get(`${URL}/home`);
      
      if (upcomingResponse.data?.upcoming?.results) {
        const urr = upcomingResponse.data.upcoming.results.sort(
          (a, b) => new Date(a.date) - new Date(b.date)
        );
        setUpcoming([...urr]);
        console.log('Upcoming matches loaded:', urr.length);
      }

      // Fetch user-specific data
      console.log('Fetching user matches from API...');
      const userResponse = await api.get(`${URL}/home/${userId}`);
      
      if (userResponse.data) {
        if (userResponse.data.upcoming?.results) {
          const ucm = userResponse.data.upcoming.results.sort(
            (a, b) => new Date(a.date) - new Date(b.date)
          );
          setUpcoming([...ucm]);
        }
        
        if (userResponse.data.live?.results) {
          const lrr = userResponse.data.live.results.sort(
            (a, b) => new Date(a.date) - new Date(b.date)
          );
          setLive([...lrr]);
        }
        
        if (userResponse.data.past?.results?.length > 0) {
          const pastMatches = userResponse.data.past.results
            .sort((b, a) => new Date(a.date) - new Date(b.date))
            .reverse();
          setPast([pastMatches.pop()]);
        }
        
        console.log('User data loaded successfully from API');
      }

      setLoading(false);
      setApiError(null);
      setRetryCount(0);
      
    } catch (error) {
      console.error('Error fetching data:', error);
      setLoading(false);
      
      // Set user-friendly error message
      let errorMessage = 'Failed to load matches. ';
      
      if (error.code === 'ECONNABORTED') {
        errorMessage += 'Request timed out. Please try again.';
      } else if (error.response?.status === 401) {
        errorMessage = 'Session expired. Please login again.';
        setTimeout(() => {
          localStorage.removeItem('token');
          localStorage.removeItem('user');
          navigate('/login');
        }, 2000);
      } else if (error.response?.status === 403) {
        errorMessage += 'Access denied. Check permissions.';
      } else if (error.response?.status === 404) {
        errorMessage += 'Data not found.';
      } else if (!navigator.onLine) {
        errorMessage += 'No internet connection.';
      } else {
        errorMessage += 'Server error. Please try again later.';
      }
      
      setApiError(errorMessage);
    }
  }, [user, navigate]);

  // Retry handler
  const handleRetry = () => {
    if (retryCount < MAX_RETRIES) {
      setRetryCount(prev => prev + 1);
      fetchData();
    } else {
      setApiError('Maximum retry attempts reached. Please refresh the page.');
    }
  };

  // Load data on mount and when user changes
  useEffect(() => {
    fetchData();
  }, [fetchData]);

  // Real-time subscription for match changes
  useEffect(() => {
    const unsubscribe = subscribeToMatches((payload) => {
      const { eventType, new: newRecord } = payload;
      // Re-fetch all match categories when any match changes
      // This ensures correct filtering by status
      if (eventType === "INSERT" || eventType === "UPDATE" || eventType === "DELETE") {
        fetchMatchesFromSupabase().then((supabaseData) => {
          if (supabaseData) {
            setUpcoming(supabaseData.upcoming || []);
            setLive(supabaseData.live || []);
            if (supabaseData.past?.length > 0) {
              setPast([supabaseData.past[0]]);
            }
          }
        });
      }
    });

    return () => {
      unsubscribe();
    };
  }, []);

  // Authentication is now handled by ProtectedRoute wrapper in App.js

  const handleClick = () => {
    setOpen(true);
  };

  // Render error state
  if (apiError && !loading) {
    return (
      <>
        <Navbar home />
        <ErrorContainer>
          <SportsCricketOutlined style={{ fontSize: 60, color: '#ccc', marginBottom: 20 }} />
          <h3 style={{ color: '#333', marginBottom: 10 }}>Unable to Load Matches</h3>
          <p style={{ color: '#666', marginBottom: 20 }}>{apiError}</p>
          {retryCount < MAX_RETRIES && (
            <RetryButton variant="contained" onClick={handleRetry}>
              Try Again ({MAX_RETRIES - retryCount} attempts left)
            </RetryButton>
          )}
          <Button 
            variant="outlined" 
            style={{ marginTop: 10 }}
            onClick={() => window.location.reload()}
          >
            Refresh Page
          </Button>
        </ErrorContainer>
        <Bottomnav />
      </>
    );
  }

  return (
    <>
      <Navbar home />
      {loading ? (
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '60vh' }}>
          <Loader />
        </div>
      ) : (
        <div className="homecontainer">
          {past?.length > 0 ? (
            <CricketBg id="section1">
              {past?.length > 0 ? (
                <>
                  <TopDiv>
                    <h3 style={{ color: "#FFFFFF", position: "relative" }}>
                      My Matches
                    </h3>
                    <ViewAll
                      style={{ display: "flex", alignItems: "center" }}
                      onClick={() => navigate(`/completed/${user?._id || user?.uid}`)}
                    >
                      View All
                      <ArrowForwardIosIcon style={{ fontSize: "12px" }} />
                    </ViewAll>
                  </TopDiv>

                  {past.map(
                    (u) =>
                      u && (
                        <div
                          key={u.id || u._id}
                          className="matchcontainere"
                          onClick={() => navigate(`/contests/${u.id}`)}
                          style={{
                            postion: "absolute !important",
                            backgroundColor: "#000",
                          }}
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
                              <span style={{ marginRight: "5px" }}>
                                {u?.team_a_code || u?.away?.code || 'TBA'}
                              </span>{" "}
                              vs
                              <span style={{ marginLeft: "5px" }}>
                                {u?.team_b_code || u?.home?.code || 'TBA'}
                              </span>
                            </h5>
                            <NotificationAddOutlinedIcon
                              style={{ fontSize: "18px" }}
                            />
                          </Top>
                          <div className="match">
                            <div className="matchcenter">
                              <div className="matchlefts">
                                <img
                                  src={u?.team_a_flag || u?.teamAwayFlagUrl || u?.away?.flag || ''}
                                  alt=""
                                  width="40"
                                />
                                <h5>{u?.team_a_code || u?.away?.code || 'TBA'}</h5>
                              </div>
                              <div
                                className={
                                  (u?.status === "completed" || u?.result === "Yes") ? "completed" : "time"
                                }
                              >
                                {(u?.status === "completed" || u?.result === "Yes") && (
                                  <div
                                    style={{
                                      display: "flex",
                                      alignItems: "center",
                                      justifyContent: "center",
                                      flexDirection: "column",
                                    }}
                                  >
                                    <div
                                      style={{
                                        display: "flex",
                                        alignItems: "center",
                                        textTransform: "uppercase",
                                      }}
                                    >
                                      <Dot />
                                      <h5
                                        style={{ fontWeight: "600 !important" }}
                                      >
                                        Completed
                                      </h5>
                                    </div>
                                    <p
                                      style={{
                                        color: "#5e5b5b",
                                        textTransform: "auto",
                                        fontSize: "10px",
                                        marginTop: "2px",
                                      }}
                                    >
                                      {getDisplayDate(u.date, "i")}
                                    </p>
                                  </div>
                                )}
                              </div>
                              <div className="matchrights">
                                <h5> {u?.team_b_code || u?.home?.code || 'TBA'}</h5>
                                <img
                                  src={u?.team_b_flag || u?.teamHomeFlagUrl || u?.home?.flag || ''}
                                  alt=""
                                  width="40"
                                />
                              </div>
                            </div>
                          </div>
                        </div>
                      )
                  )}
                </>
              ) : null}
            </CricketBg>
          ) : null}

          {upcoming.length > 0 ? (
            <>
              <h4 style={{ padding: "10px 15px" }}>Upcoming Matches</h4>
              {upcoming.map((match) => (
                <Match key={match.id || match._id} match={match} />
              ))}
            </>
          ) : (
            !loading && (
              <div style={{ textAlign: 'center', padding: '40px 20px' }}>
                <SportsCricketOutlined style={{ fontSize: 60, color: '#ccc' }} />
                <h4 style={{ color: '#666', marginTop: 20 }}>No Upcoming Matches</h4>
                <p style={{ color: '#999', fontSize: 14 }}>Check back later for new matches</p>
              </div>
            )
          )}
        </div>
      )}
      <Bottomnav />
    </>
  );
}

export default Home;

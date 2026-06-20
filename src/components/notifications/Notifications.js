import styled from "@emotion/styled";
import NotificationsOutlinedIcon from "@mui/icons-material/NotificationsOutlined";
import { Button } from "@mui/material";
import { useEffect, useRef, useState } from "react";
import { useSelector } from "react-redux";
import { getUserNotifications, markNotificationRead } from "../../services/supabaseService";
import { subscribeToNotifications } from "../../services/realtimeService";
import Bottomnav from "../navbar/bottomnavbar";
import Loader from "../loader";
import Navbar from "../navbar";

const NotifContainer = styled.div`
  padding: 10px 15px;
  padding-bottom: 90px;
  min-height: 60vh;
`;

const EmptyState = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 50vh;
  padding: 20px;
  text-align: center;
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

const NotifCard = styled.div`
  background-color: ${props => props.isRead ? '#ffffff' : '#f0f9f4'};
  box-shadow: 0 0 1.5px 1.5px rgba(83, 80, 80, 0.1);
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 10px;
  border-left: 3px solid ${props => props.isRead ? '#ddd' : 'var(--green)'};
  cursor: pointer;
`;

const NotifTitle = styled.h5`
  margin: 0 0 5px;
  font-size: 14px;
  color: #333;
`;

const NotifMessage = styled.p`
  margin: 0;
  font-size: 13px;
  color: #666;
  line-height: 1.4;
`;

const NotifTime = styled.span`
  font-size: 11px;
  color: #999;
  margin-top: 5px;
  display: block;
`;

export function Notifications() {
  const { user } = useSelector((state) => state.user);
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const isMountedRef = useRef(true);

  useEffect(() => {
    isMountedRef.current = true;
    fetchNotifications();

    const userId = user?._id || user?.uid;
    let unsubscribe = null;

    if (userId) {
      unsubscribe = subscribeToNotifications(userId, (payload) => {
        const { eventType, new: newRecord, old: oldRecord } = payload;
        if (!isMountedRef.current) return;
        setNotifications((prev) => {
          if (eventType === "INSERT") {
            return [newRecord, ...prev];
          } else if (eventType === "UPDATE") {
            return prev.map((n) => (n.id === newRecord.id ? newRecord : n));
          } else if (eventType === "DELETE") {
            return prev.filter((n) => n.id !== oldRecord.id);
          }
          return prev;
        });
      });
    }

    return () => {
      isMountedRef.current = false;
      if (unsubscribe) {
        unsubscribe();
      }
    };
  }, [user]);

  const fetchNotifications = async () => {
    const userId = user?._id || user?.uid;
    if (!userId) {
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      setError(null);

      const notifs = await getUserNotifications(userId);

      if (!isMountedRef.current) return;
      setNotifications(notifs);
      setLoading(false);
    } catch (err) {
      if (!isMountedRef.current) return;
      console.error("Error fetching notifications:", err);
      setError("Unable to load notifications. Please try again.");
      setLoading(false);
    }
  };

  const handleNotifClick = async (notif) => {
    if (!notif.is_read) {
      await markNotificationRead(notif.id);
      setNotifications(prev =>
        prev.map(n => n.id === notif.id ? { ...n, is_read: true } : n)
      );
    }
  };

  const formatTimestamp = (timestamp) => {
    if (!timestamp) return "";
    try {
      const date = new Date(timestamp);
      const now = new Date();
      const diff = now - date;
      const minutes = Math.floor(diff / 60000);
      const hours = Math.floor(diff / 3600000);
      const days = Math.floor(diff / 86400000);

      if (minutes < 1) return "Just now";
      if (minutes < 60) return `${minutes}m ago`;
      if (hours < 24) return `${hours}h ago`;
      if (days < 7) return `${days}d ago`;
      return date.toLocaleDateString();
    } catch {
      return "";
    }
  };

  const handleRetry = () => {
    fetchNotifications();
  };

  if (error && !loading) {
    return (
      <>
        <Navbar />
        <ErrorContainer>
          <NotificationsOutlinedIcon style={{ fontSize: 60, color: "#ccc", marginBottom: 20 }} />
          <h3 style={{ color: "#333", marginBottom: 10 }}>Unable to Load Notifications</h3>
          <p style={{ color: "#666", marginBottom: 20 }}>{error}</p>
          <RetryButton variant="contained" onClick={handleRetry}>
            Try Again
          </RetryButton>
        </ErrorContainer>
        <Bottomnav />
      </>
    );
  }

  return (
    <>
      <Navbar />
      {loading ? (
        <div style={{ display: "flex", justifyContent: "center", alignItems: "center", minHeight: "60vh" }}>
          <Loader />
        </div>
      ) : (
        <NotifContainer>
          <h4 style={{ marginBottom: 15 }}>Notifications</h4>
          {notifications.length === 0 ? (
            <EmptyState>
              <NotificationsOutlinedIcon style={{ fontSize: 60, color: "#ccc" }} />
              <h4 style={{ color: "#666", marginTop: 20 }}>No notifications</h4>
              <p style={{ color: "#999", fontSize: 14 }}>
                You'll receive notifications about matches, contests, and more
              </p>
            </EmptyState>
          ) : (
            notifications.map((notif) => (
              <NotifCard
                key={notif.id}
                isRead={notif.is_read}
                onClick={() => handleNotifClick(notif)}
              >
                <NotifTitle>{notif.title}</NotifTitle>
                <NotifMessage>{notif.message}</NotifMessage>
                <NotifTime>{formatTimestamp(notif.created_at)}</NotifTime>
              </NotifCard>
            ))
          )}
        </NotifContainer>
      )}
      <Bottomnav />
    </>
  );
}

export default Notifications;

import styled from "@emotion/styled";
import NotificationsOutlinedIcon from "@mui/icons-material/NotificationsOutlined";
import { Button } from "@mui/material";
import { collection, getDocs, query, where, orderBy } from "firebase/firestore";
import { useEffect, useRef, useState } from "react";
import { useSelector } from "react-redux";
import db from "../../firebase";
import Bottomnav from "../navbar/bottomnavbar";
import Loader from "../loader";
import Navbar from "../navbar";

const NotificationsContainer = styled.div`
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

const NotificationCard = styled.div`
  background-color: #ffffff;
  box-shadow: 0 0 1.5px 1.5px rgba(83, 80, 80, 0.15);
  border-radius: 5px;
  padding: 15px;
  margin-bottom: 10px;
  border-left: 3px solid var(--green);
`;

const NotificationTitle = styled.h5`
  font-size: 14px;
  font-weight: 600;
  color: #333;
  margin: 0 0 5px 0;
`;

const NotificationMessage = styled.p`
  font-size: 13px;
  color: #666;
  margin: 0 0 8px 0;
  line-height: 1.4;
`;

const NotificationTime = styled.span`
  font-size: 11px;
  color: #999;
`;

export function Notifications() {
  const { user } = useSelector((state) => state.user);
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const LOADING_TIMEOUT = 10000; // 10 seconds max loading

  const isMountedRef = useRef(true);
  const timerRef = useRef(null);

  useEffect(() => {
    isMountedRef.current = true;

    if (user && (user._id || user.uid)) {
      fetchNotifications();
    } else {
      setLoading(false);
    }

    // Timeout to prevent infinite loading
    timerRef.current = setTimeout(() => {
      if (isMountedRef.current) {
        setLoading(false);
      }
    }, LOADING_TIMEOUT);

    return () => {
      isMountedRef.current = false;
      if (timerRef.current) clearTimeout(timerRef.current);
    };
  }, [user]);

  const fetchNotifications = async () => {
    try {
      setLoading(true);
      setError(null);

      const userId = user?._id || user?.uid;
      if (!userId) {
        setLoading(false);
        return;
      }

      const notifRef = collection(db, "notifications");
      const notifQuery = query(
        notifRef,
        where("userId", "==", userId),
        orderBy("createdAt", "desc")
      );
      const snapshot = await getDocs(notifQuery);

      if (!isMountedRef.current) return;

      if (snapshot.empty) {
        setNotifications([]);
        setLoading(false);
        if (timerRef.current) clearTimeout(timerRef.current);
        return;
      }

      const notifList = [];
      snapshot.forEach((doc) => {
        notifList.push({ id: doc.id, ...doc.data() });
      });

      if (!isMountedRef.current) return;
      setNotifications(notifList);
      setLoading(false);
      if (timerRef.current) clearTimeout(timerRef.current);
    } catch (err) {
      if (!isMountedRef.current) return;
      console.error("Error fetching notifications:", err);
      if (err.code === "permission-denied" || err.code === "not-found") {
        setNotifications([]);
        setLoading(false);
      } else {
        setError("Unable to load notifications. Please try again.");
        setLoading(false);
      }
      if (timerRef.current) clearTimeout(timerRef.current);
    }
  };

  const handleRetry = () => {
    fetchNotifications();
  };

  const formatTimestamp = (timestamp) => {
    if (!timestamp) return "";
    try {
      const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
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

  // Error state
  if (error && !loading) {
    return (
      <>
        <Navbar />
        <ErrorContainer>
          <NotificationsOutlinedIcon
            style={{ fontSize: 60, color: "#ccc", marginBottom: 20 }}
          />
          <h3 style={{ color: "#333", marginBottom: 10 }}>
            Unable to Load Notifications
          </h3>
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
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            minHeight: "60vh",
          }}
        >
          <Loader />
        </div>
      ) : (
        <NotificationsContainer>
          <h4 style={{ marginBottom: 15 }}>Notifications</h4>
          {notifications.length === 0 ? (
            <EmptyState>
              <NotificationsOutlinedIcon
                style={{ fontSize: 60, color: "#ccc" }}
              />
              <h4 style={{ color: "#666", marginTop: 20 }}>
                No notifications yet
              </h4>
              <p style={{ color: "#999", fontSize: 14 }}>
                You will see match updates and alerts here
              </p>
            </EmptyState>
          ) : (
            notifications.map((notif) => (
              <NotificationCard key={notif.id}>
                <NotificationTitle>
                  {notif.title || "Notification"}
                </NotificationTitle>
                <NotificationMessage>
                  {notif.message || notif.body || ""}
                </NotificationMessage>
                <NotificationTime>
                  {formatTimestamp(notif.createdAt)}
                </NotificationTime>
              </NotificationCard>
            ))
          )}
        </NotificationsContainer>
      )}
      <Bottomnav />
    </>
  );
}

export default Notifications;

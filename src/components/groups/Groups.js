import "./Groups.css";

import styled from "@emotion/styled";
import GroupsOutlinedIcon from "@mui/icons-material/GroupsOutlined";
import AddIcon from "@mui/icons-material/Add";
import { Button } from "@mui/material";
import { collection, getDocs } from "firebase/firestore";
import { useEffect, useRef, useState } from "react";
import { useSelector } from "react-redux";
import db from "../../firebase";
import Bottomnav from "../navbar/bottomnavbar";
import Loader from "../loader";
import Navbar from "../navbar";

const GroupsContainer = styled.div`
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

const GroupCard = styled.div`
  background-color: #ffffff;
  box-shadow: 0 0 1.5px 1.5px rgba(83, 80, 80, 0.15);
  border-radius: 5px;
  padding: 15px;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  cursor: pointer;
`;

const GroupAvatar = styled.div`
  width: 45px;
  height: 45px;
  border-radius: 50%;
  background-color: var(--green);
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 18px;
  margin-right: 12px;
  flex-shrink: 0;
`;

const GroupInfo = styled.div`
  flex: 1;
`;

const GroupName = styled.h5`
  font-size: 15px;
  font-weight: 600;
  color: #333;
  margin: 0 0 4px 0;
`;

const GroupMembers = styled.span`
  font-size: 12px;
  color: #999;
`;

const CreateButton = styled(Button)`
  background-color: var(--green);
  color: #ffffff;
  text-transform: capitalize;
  margin-top: 15px;
  &:hover {
    background-color: #0d7a2c;
    color: #ffffff;
  }
`;

export function Groups() {
  const { user } = useSelector((state) => state.user);
  const [groups, setGroups] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const LOADING_TIMEOUT = 10000; // 10 seconds max loading

  const isMountedRef = useRef(true);
  const timerRef = useRef(null);

  useEffect(() => {
    isMountedRef.current = true;

    if (user && (user._id || user.uid)) {
      fetchGroups();
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

  const fetchGroups = async () => {
    try {
      setLoading(true);
      setError(null);

      const userId = user?._id || user?.uid;
      if (!userId) {
        setLoading(false);
        return;
      }

      // members is a map { userId: boolean }, not an array.
      // Firestore does not support array-contains on map fields.
      // Query all groups and filter client-side by checking the map key.
      const groupsRef = collection(db, "groups");
      const snapshot = await getDocs(groupsRef);

      if (!isMountedRef.current) return;

      if (snapshot.empty) {
        setGroups([]);
        setLoading(false);
        if (timerRef.current) clearTimeout(timerRef.current);
        return;
      }

      const userGroups = [];
      snapshot.forEach((doc) => {
        const data = doc.data();
        // Check if user is a member using map key lookup
        if (data.members && data.members[userId] === true) {
          userGroups.push({ id: doc.id, ...data });
        }
      });

      if (!isMountedRef.current) return;
      setGroups(userGroups);
      setLoading(false);
      if (timerRef.current) clearTimeout(timerRef.current);
    } catch (err) {
      if (!isMountedRef.current) return;
      console.error("Error fetching groups:", err);
      // If collection doesn't exist or no permissions, show empty state
      if (err.code === "permission-denied" || err.code === "not-found") {
        setGroups([]);
        setLoading(false);
      } else {
        setError("Unable to load groups. Please try again.");
        setLoading(false);
      }
      if (timerRef.current) clearTimeout(timerRef.current);
    }
  };

  const handleRetry = () => {
    fetchGroups();
  };

  // Error state
  if (error && !loading) {
    return (
      <>
        <Navbar />
        <ErrorContainer>
          <GroupsOutlinedIcon style={{ fontSize: 60, color: "#ccc", marginBottom: 20 }} />
          <h3 style={{ color: "#333", marginBottom: 10 }}>Unable to Load Groups</h3>
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
        <GroupsContainer>
          <h4 style={{ marginBottom: 15 }}>My Groups</h4>
          {groups.length === 0 ? (
            <EmptyState>
              <GroupsOutlinedIcon style={{ fontSize: 60, color: "#ccc" }} />
              <h4 style={{ color: "#666", marginTop: 20 }}>No groups yet</h4>
              <p style={{ color: "#999", fontSize: 14 }}>
                Create or join a group to play with friends
              </p>
              <CreateButton variant="contained" startIcon={<AddIcon />}>
                Create Group
              </CreateButton>
            </EmptyState>
          ) : (
            groups.map((group) => (
              <GroupCard key={group.id}>
                <GroupAvatar>
                  {group.name ? group.name.charAt(0).toUpperCase() : "G"}
                </GroupAvatar>
                <GroupInfo>
                  <GroupName>{group.name || "Unnamed Group"}</GroupName>
                  <GroupMembers>
                    {group.members ? Object.keys(group.members).length : 0} member{(group.members ? Object.keys(group.members).length : 0) !== 1 ? "s" : ""}
                  </GroupMembers>
                </GroupInfo>
              </GroupCard>
            ))
          )}
        </GroupsContainer>
      )}
      <Bottomnav />
    </>
  );
}

export default Groups;

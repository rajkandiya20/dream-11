import "./Groups.css";

import styled from "@emotion/styled";
import GroupsOutlinedIcon from "@mui/icons-material/GroupsOutlined";
import AddIcon from "@mui/icons-material/Add";
import { Button } from "@mui/material";
import { useEffect, useRef, useState } from "react";
import { useSelector } from "react-redux";
import { getUserGroups } from "../../services/supabaseService";
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
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  cursor: pointer;
  transition: box-shadow 0.2s;
  &:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  }
`;

const GroupAvatar = styled.div`
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background-color: #e0f2e9;
  color: var(--green);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 18px;
  margin-right: 15px;
`;

const GroupInfo = styled.div`
  flex: 1;
`;

const GroupName = styled.h4`
  margin: 0;
  font-size: 15px;
  color: #333;
`;

const GroupMeta = styled.p`
  margin: 4px 0 0;
  font-size: 12px;
  color: #999;
`;

export function Groups() {
  const { user } = useSelector((state) => state.user);
  const [groups, setGroups] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const isMountedRef = useRef(true);

  useEffect(() => {
    isMountedRef.current = true;
    fetchGroups();
    return () => { isMountedRef.current = false; };
  }, [user]);

  const fetchGroups = async () => {
    const userId = user?._id || user?.uid;
    if (!userId) {
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      setError(null);

      const userGroups = await getUserGroups(userId);

      if (!isMountedRef.current) return;
      setGroups(userGroups);
      setLoading(false);
    } catch (err) {
      if (!isMountedRef.current) return;
      console.error("Error fetching groups:", err);
      setError("Unable to load groups. Please try again.");
      setLoading(false);
    }
  };

  const handleRetry = () => {
    fetchGroups();
  };

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
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 15 }}>
            <h4>Groups</h4>
          </div>
          {groups.length === 0 ? (
            <EmptyState>
              <GroupsOutlinedIcon style={{ fontSize: 60, color: "#ccc" }} />
              <h4 style={{ color: "#666", marginTop: 20 }}>No groups yet</h4>
              <p style={{ color: "#999", fontSize: 14 }}>
                Join or create a group to connect with other players
              </p>
            </EmptyState>
          ) : (
            groups.map((group) => (
              <GroupCard key={group.id}>
                <GroupAvatar>
                  {(group.name || "G").charAt(0).toUpperCase()}
                </GroupAvatar>
                <GroupInfo>
                  <GroupName>{group.name}</GroupName>
                  <GroupMeta>
                    {group.member_count || 0} members
                    {group.membership?.role === 'admin' && ' - Admin'}
                  </GroupMeta>
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

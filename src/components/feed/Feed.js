import "./Feed.css";

import styled from "@emotion/styled";
import FeedOutlinedIcon from "@mui/icons-material/FeedOutlined";
import { Button } from "@mui/material";
import { useEffect, useRef, useState } from "react";
import { useSelector } from "react-redux";
import { getFeedPosts } from "../../services/supabaseService";
import Bottomnav from "../navbar/bottomnavbar";
import Loader from "../loader";
import Navbar from "../navbar";

const FeedContainer = styled.div`
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

const PostCard = styled.div`
  background-color: #ffffff;
  box-shadow: 0 0 1.5px 1.5px rgba(83, 80, 80, 0.15);
  border-radius: 5px;
  padding: 15px;
  margin-bottom: 12px;
`;

const PostHeader = styled.div`
  display: flex;
  align-items: center;
  margin-bottom: 10px;
`;

const PostAvatar = styled.div`
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background-color: var(--green);
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 14px;
  margin-right: 10px;
`;

const PostAuthor = styled.span`
  font-weight: 600;
  font-size: 14px;
  color: #333;
`;

const PostTime = styled.span`
  font-size: 11px;
  color: #999;
  margin-left: 8px;
`;

const PostContent = styled.p`
  font-size: 14px;
  color: #444;
  line-height: 1.5;
  margin: 0;
`;

export function Feed() {
  const { user } = useSelector((state) => state.user);
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const isMountedRef = useRef(true);

  useEffect(() => {
    isMountedRef.current = true;
    fetchFeed();
    return () => { isMountedRef.current = false; };
  }, []);

  const fetchFeed = async () => {
    try {
      setLoading(true);
      setError(null);

      const feedPosts = await getFeedPosts(30);

      if (!isMountedRef.current) return;
      setPosts(feedPosts);
      setLoading(false);
    } catch (err) {
      if (!isMountedRef.current) return;
      console.error("Error fetching feed posts:", err);
      setError("Unable to load feed. Please try again.");
      setLoading(false);
    }
  };

  const handleRetry = () => {
    fetchFeed();
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

  if (error && !loading) {
    return (
      <>
        <Navbar />
        <ErrorContainer>
          <FeedOutlinedIcon style={{ fontSize: 60, color: "#ccc", marginBottom: 20 }} />
          <h3 style={{ color: "#333", marginBottom: 10 }}>Unable to Load Feed</h3>
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
        <FeedContainer>
          <h4 style={{ marginBottom: 15 }}>Feed</h4>
          {posts.length === 0 ? (
            <EmptyState>
              <FeedOutlinedIcon style={{ fontSize: 60, color: "#ccc" }} />
              <h4 style={{ color: "#666", marginTop: 20 }}>No posts yet</h4>
              <p style={{ color: "#999", fontSize: 14 }}>
                Posts from your community will appear here
              </p>
            </EmptyState>
          ) : (
            posts.map((post) => (
              <PostCard key={post.id}>
                <PostHeader>
                  <PostAvatar>
                    {(post.user?.username || post.author_name || "U").charAt(0).toUpperCase()}
                  </PostAvatar>
                  <div>
                    <PostAuthor>{post.user?.username || post.author_name || "User"}</PostAuthor>
                    <PostTime>{formatTimestamp(post.created_at)}</PostTime>
                  </div>
                </PostHeader>
                <PostContent>{post.content || ""}</PostContent>
              </PostCard>
            ))
          )}
        </FeedContainer>
      )}
      <Bottomnav />
    </>
  );
}

export default Feed;

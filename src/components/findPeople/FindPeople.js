import "../home.css";
import "../create.css";
import Bottomnav from "../navbar/bottomnavbar";
import { useState, useCallback } from "react";
import Loader from "../loader";
import Navbar from "../navbar";
import styled from "@emotion/styled";
import { Grid, TextField, Avatar, List, ListItem, ListItemAvatar, ListItemText } from "@mui/material";
import PersonSearchIcon from "@mui/icons-material/PersonSearch";
import { collection, getDocs, query, where, orderBy, limit } from "firebase/firestore";
import db from "../../firebase";

const Container = styled(Grid)`
  padding: 10px 10px;
`;

const Title = styled.h3`
  margin-bottom: 10px;
`;

const EmptyState = styled.div`
  text-align: center;
  padding: 40px 20px;
`;

const ResultItem = styled(ListItem)`
  border-bottom: 1px solid #eee;
  cursor: pointer;
  &:hover {
    background-color: #f5f5f5;
  }
`;

export default function FindPeople() {
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searched, setSearched] = useState(false);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState("");

  const handleSearch = useCallback(async (term) => {
    setSearchTerm(term);

    if (!term || term.length < 2) {
      setResults([]);
      setSearched(false);
      return;
    }

    setLoading(true);
    setError(null);
    setSearched(true);

    try {
      const usersRef = collection(db, "users");
      // Search by username prefix
      const q = query(
        usersRef,
        where("username", ">=", term.toLowerCase()),
        where("username", "<=", term.toLowerCase() + "\uf8ff"),
        limit(20)
      );
      const snapshot = await getDocs(q);
      const users = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
      setResults(users);
    } catch (err) {
      console.error("Error searching users:", err);
      setError("Unable to search. Please try again.");
      setResults([]);
    } finally {
      setLoading(false);
    }

    // Timeout fallback
    setTimeout(() => {
      setLoading(false);
    }, 10000);
  }, []);

  return (
    <>
      <Navbar />
      <Container>
        <Title>Search People You Know</Title>
        <TextField
          label="Find People"
          fullWidth
          value={searchTerm}
          onChange={(e) => handleSearch(e.target.value)}
          placeholder="Type at least 2 characters to search..."
        />

        {loading && (
          <div style={{ padding: '20px', textAlign: 'center' }}>
            <Loader />
          </div>
        )}

        {error && (
          <EmptyState>
            <p style={{ color: '#d32f2f' }}>{error}</p>
          </EmptyState>
        )}

        {!loading && searched && results.length === 0 && !error && (
          <EmptyState>
            <PersonSearchIcon style={{ fontSize: 60, color: '#ccc' }} />
            <p style={{ color: '#666', marginTop: 10 }}>No users found matching "{searchTerm}"</p>
          </EmptyState>
        )}

        {!loading && results.length > 0 && (
          <List>
            {results.map((person) => (
              <ResultItem key={person.id}>
                <ListItemAvatar>
                  <Avatar src={person.avatar || ""}>
                    {person.username ? person.username[0].toUpperCase() : "U"}
                  </Avatar>
                </ListItemAvatar>
                <ListItemText
                  primary={person.username || "Unknown User"}
                  secondary={person.email || ""}
                />
              </ResultItem>
            ))}
          </List>
        )}

        {!loading && !searched && (
          <EmptyState>
            <PersonSearchIcon style={{ fontSize: 60, color: '#ccc' }} />
            <p style={{ color: '#999', marginTop: 10 }}>Search for people by username</p>
          </EmptyState>
        )}
      </Container>
      <Bottomnav />
    </>
  );
}

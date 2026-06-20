import styled from "@emotion/styled";
import { Grid, TextField, Avatar, List, ListItem, ListItemAvatar, ListItemText } from "@mui/material";
import PersonSearchIcon from "@mui/icons-material/PersonSearch";
import { searchUsers } from "../../services/supabaseService";
import { useState } from "react";
import { useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";
import Navbar from "../navbar";
import Bottomnav from "../navbar/bottomnavbar";

const Container = styled(Grid)`
  padding: 15px;
  padding-bottom: 90px;
  min-height: 60vh;
`;

const SearchContainer = styled.div`
  margin-bottom: 20px;
`;

const EmptyState = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 40vh;
  padding: 20px;
  text-align: center;
`;

export default function FindPeople() {
  const { user } = useSelector((state) => state.user);
  const navigate = useNavigate();
  const [searchTerm, setSearchTerm] = useState("");
  const [results, setResults] = useState([]);
  const [searching, setSearching] = useState(false);

  const handleSearch = async (value) => {
    setSearchTerm(value);
    if (value.length < 2) {
      setResults([]);
      return;
    }

    try {
      setSearching(true);
      const users = await searchUsers(value);
      // Filter out current user
      const filtered = users.filter(u => u.uid !== (user?.uid || user?._id));
      setResults(filtered);
    } catch (err) {
      console.error("Search error:", err);
      setResults([]);
    } finally {
      setSearching(false);
    }
  };

  return (
    <>
      <Navbar />
      <Container container>
        <Grid item xs={12}>
          <h4 style={{ marginBottom: 15 }}>Find People</h4>
          <SearchContainer>
            <TextField
              fullWidth
              variant="outlined"
              placeholder="Search by username..."
              value={searchTerm}
              onChange={(e) => handleSearch(e.target.value)}
              size="small"
            />
          </SearchContainer>

          {results.length > 0 ? (
            <List>
              {results.map((person) => (
                <ListItem key={person.uid} style={{ cursor: "pointer", borderBottom: "1px solid #f0f0f0" }}>
                  <ListItemAvatar>
                    <Avatar style={{ backgroundColor: "var(--green)" }}>
                      {(person.username || "U").charAt(0).toUpperCase()}
                    </Avatar>
                  </ListItemAvatar>
                  <ListItemText
                    primary={person.username}
                    secondary={person.email}
                  />
                </ListItem>
              ))}
            </List>
          ) : searchTerm.length >= 2 && !searching ? (
            <EmptyState>
              <PersonSearchIcon style={{ fontSize: 60, color: "#ccc" }} />
              <p style={{ color: "#666", marginTop: 15 }}>No users found for "{searchTerm}"</p>
            </EmptyState>
          ) : (
            <EmptyState>
              <PersonSearchIcon style={{ fontSize: 60, color: "#ccc" }} />
              <p style={{ color: "#666", marginTop: 15 }}>Search for people by username</p>
            </EmptyState>
          )}
        </Grid>
      </Container>
      <Bottomnav />
    </>
  );
}

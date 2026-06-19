import "./register.css";

import EmojiEventsOutlinedIcon from "@mui/icons-material/EmojiEventsOutlined";
import Button from "@mui/material/Button";
import CircularProgress from "@mui/material/CircularProgress";
import Paper from "@mui/material/Paper";
import TextField from "@mui/material/TextField";
import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Link, useNavigate } from "react-router-dom";
import { login } from "../actions/userAction";
import { useAlert } from "react-alert";

export function Login() {
  const { user, isAuthenticated, loading, error } = useSelector(
    (state) => state.user
  );
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const alert = useAlert();
  const [password, setPassword] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    if (isAuthenticated && user) {
      navigate("/");
    }
    if (error) {
      alert.error(error);
    }
  }, [user, isAuthenticated, error, navigate]);

  const handlesubmit = async (e) => {
    e.preventDefault();
    if (!email || !password) {
      alert.error("Please enter email and password");
      return;
    }
    
    setIsLoading(true);
    const result = await dispatch(login({ email, password }));
    setIsLoading(false);
    
    if (result.success) {
      alert.success("Login successful!");
      navigate("/");
    } else {
      alert.error(result.message || "Login failed");
    }
  };

  return (
    <>
      <div className="logintopbar">
        <EmojiEventsOutlinedIcon style={{ marginRight: "1vw" }} />
        Dream 11
      </div>

      <div className="register">
        <Paper style={{ padding: "2vh 2vw" }}>
          <h5 style={{ marginBottom: "10px", textAlign: "center" }}>LOG IN</h5>
          <form onSubmit={handlesubmit} className="loginform">
            <TextField
              id="email"
              variant="standard"
              placeholder="Email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              type="email"
              fullWidth
              margin="normal"
              required
            />
            <TextField
              id="password"
              variant="standard"
              type="password"
              placeholder="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              fullWidth
              margin="normal"
              required
            />
            <Button
              type="submit"
              className="itseveryday"
              variant="contained"
              disableElevation
              style={{ backgroundColor: "#24B937", marginTop: "20px" }}
              disabled={isLoading}
            >
              {isLoading ? <CircularProgress size={24} color="inherit" /> : "Log in"}
            </Button>
          </form>
          <div style={{ marginTop: "15px", textAlign: "center" }}>
            <Link to="/forgot-password" style={{ display: "block", marginBottom: "10px" }}>
              Forgot Password?
            </Link>
            <Link to="/register">Don't have an account? Sign up</Link>
          </div>
        </Paper>
      </div>
    </>
  );
}

export default Login;

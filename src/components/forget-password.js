import "./register.css";

import EmojiEventsOutlinedIcon from "@mui/icons-material/EmojiEventsOutlined";
import Button from "@mui/material/Button";
import CircularProgress from "@mui/material/CircularProgress";
import Paper from "@mui/material/Paper";
import TextField from "@mui/material/TextField";
import { useState } from "react";
import { useDispatch } from "react-redux";
import { Link, useNavigate } from "react-router-dom";
import { forgot } from "../actions/userAction";
import { useAlert } from "react-alert";

export function ForgotPassword() {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const alert = useAlert();
  const [email, setEmail] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!email) {
      alert.error("Please enter your email");
      return;
    }
    
    setIsLoading(true);
    const result = await dispatch(forgot(email));
    setIsLoading(false);
    
    if (result.success) {
      alert.success(result.message || "Password reset email sent!");
      navigate("/login");
    } else {
      alert.error(result.message || "Failed to send reset email");
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
          <h5 style={{ marginBottom: "15px", textAlign: "center" }}>RESET PASSWORD</h5>
          <p style={{ marginBottom: "15px", textAlign: "center", color: "#666", fontSize: "14px" }}>
            Enter your email to reset your password.
          </p>
          <form onSubmit={handleSubmit} className="loginform">
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
            <Button
              type="submit"
              variant="contained"
              disableElevation
              style={{ backgroundColor: "#24B937", marginTop: "20px" }}
              disabled={isLoading}
            >
              {isLoading ? <CircularProgress size={24} color="inherit" /> : "Send Reset Link"}
            </Button>
          </form>
          <div style={{ marginTop: "15px", textAlign: "center" }}>
            <Link to="/login">Back to Login</Link>
          </div>
        </Paper>
      </div>
    </>
  );
}

export default ForgotPassword;

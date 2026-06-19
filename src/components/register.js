import "./register.css";

import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import Button from "@mui/material/Button";
import CircularProgress from "@mui/material/CircularProgress";
import Paper from "@mui/material/Paper";
import TextField from "@mui/material/TextField";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useDispatch } from "react-redux";
import { register } from "../actions/userAction";
import { useAlert } from "react-alert";

export function Register() {
  const alert = useAlert();
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);
  const [formData, setFormData] = useState({
    email: "",
    username: "",
    phoneNumber: "",
    password: ""
  });
  const [errors, setErrors] = useState({});

  const validateForm = () => {
    const newErrors = {};
    if (!formData.email) newErrors.email = "Email is required";
    else if (!/\S+@\S+\.\S+/.test(formData.email)) newErrors.email = "Invalid email";
    if (!formData.username) newErrors.username = "Username is required";
    else if (formData.username.length < 6) newErrors.username = "Username must be at least 6 characters";
    if (!formData.phoneNumber) newErrors.phoneNumber = "Phone number is required";
    else if (formData.phoneNumber.length < 10) newErrors.phoneNumber = "Phone number must be at least 10 digits";
    if (!formData.password) newErrors.password = "Password is required";
    else if (formData.password.length < 6) newErrors.password = "Password must be at least 6 characters";
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
    if (errors[name]) {
      setErrors({ ...errors, [name]: "" });
    }
  };

  const onSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }
    
    setIsLoading(true);
    const result = await dispatch(register(formData));
    setIsLoading(false);
    
    if (result.success) {
      alert.success("Registration successful! Please login.");
      navigate("/login");
    } else {
      alert.error(result.message || "Registration failed");
    }
  };

  return (
    <>
      <div className="registertopbar">
        <ArrowBackIcon
          style={{ marginRight: "20px", cursor: "pointer" }}
          onClick={() => navigate(-1)}
        />
        Register & Play
      </div>

      <div className="register">
        <Paper style={{ padding: "20px" }}>
          <h5 style={{ marginBottom: "15px", textAlign: "center" }}>CREATE ACCOUNT</h5>
          <form onSubmit={onSubmit} className="registerform">
            <TextField
              id="email"
              name="email"
              label="Email"
              variant="standard"
              fullWidth
              margin="dense"
              value={formData.email}
              onChange={handleChange}
              error={!!errors.email}
              helperText={errors.email}
              type="email"
              required
            />
            <TextField
              id="username"
              name="username"
              label="Username"
              variant="standard"
              fullWidth
              margin="dense"
              value={formData.username}
              onChange={handleChange}
              error={!!errors.username}
              helperText={errors.username}
              required
            />
            <TextField
              id="phoneNumber"
              name="phoneNumber"
              label="Phone Number"
              variant="standard"
              fullWidth
              margin="dense"
              value={formData.phoneNumber}
              onChange={handleChange}
              error={!!errors.phoneNumber}
              helperText={errors.phoneNumber}
              type="tel"
              required
            />
            <TextField
              id="password"
              name="password"
              label="Password"
              variant="standard"
              fullWidth
              margin="dense"
              value={formData.password}
              onChange={handleChange}
              error={!!errors.password}
              helperText={errors.password}
              type="password"
              required
            />
            <Button
              variant="contained"
              type="submit"
              disableElevation
              style={{ backgroundColor: "#24B937", marginTop: "20px" }}
              disabled={isLoading}
            >
              {isLoading ? <CircularProgress size={24} color="inherit" /> : "Register"}
            </Button>
          </form>
          <div style={{ marginTop: "15px", textAlign: "center" }}>
            <Link to="/forgot-password" style={{ display: "block", marginBottom: "10px" }}>
              Forgot Password?
            </Link>
            <Link to="/login">Already have an account? Log in</Link>
          </div>
        </Paper>
      </div>
    </>
  );
}

export default Register;

import styled from "@emotion/styled";
import { Button, TextField, Paper, Typography } from "@mui/material";
import LockIcon from "@mui/icons-material/Lock";
import { useState } from "react";
import { useDispatch } from "react-redux";
import { useNavigate } from "react-router-dom";
import { useAlert } from "react-alert";
import axios from "axios";
import { URL } from "../../constants/userConstants";

const Container = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
`;

const FormWrapper = styled(Paper)`
  padding: 30px;
  max-width: 400px;
  width: 100%;
`;

const Title = styled.h1`
  text-align: center;
  color: var(--black);
  margin-bottom: 20px;
`;

const AdminBadge = styled.div`
  background: var(--green);
  color: white;
  padding: 5px 15px;
  border-radius: 20px;
  font-size: 12px;
  display: inline-block;
  margin-bottom: 10px;
`;

export default function AdminLogin() {
  const [email, setEmail] = useState("rexoagency.in@gmail.com");
  const [password, setPassword] = useState("");
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const alert = useAlert();

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (email !== "rexoagency.in@gmail.com") {
      alert.error("Invalid admin email");
      return;
    }

    try {
      const { data } = await axios.post(`${URL}/auth/login`, {
        myform: { email, password },
      });
      
      if (data.user?.email === "rexoagency.in@gmail.com") {
        localStorage.setItem("token", data.token);
        localStorage.setItem("user", JSON.stringify(data.user));
        alert.success("Admin login successful");
        navigate("/admin");
      } else {
        alert.error("Access denied - Admin only");
      }
    } catch (error) {
      alert.error(error.response?.data?.message || "Login failed");
    }
  };

  return (
    <Container>
      <FormWrapper>
        <AdminBadge>Admin Panel</AdminBadge>
        <Title>Admin Login</Title>
        <form onSubmit={handleSubmit}>
          <TextField
            label="Admin Email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            type="email"
            fullWidth
            margin="normal"
            disabled
          />
          <TextField
            label="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            type="password"
            fullWidth
            margin="normal"
            required
          />
          <Button
            type="submit"
            variant="contained"
            fullWidth
            style={{ backgroundColor: "var(--green)", marginTop: "20px" }}
          >
            Login as Admin
          </Button>
        </form>
      </FormWrapper>
    </Container>
  );
}
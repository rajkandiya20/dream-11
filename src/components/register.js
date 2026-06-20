import styled from "@emotion/styled";
import { keyframes } from "@emotion/react";
import EmailOutlinedIcon from "@mui/icons-material/EmailOutlined";
import LockOutlinedIcon from "@mui/icons-material/LockOutlined";
import PersonOutlineIcon from "@mui/icons-material/PersonOutline";
import PhoneOutlinedIcon from "@mui/icons-material/PhoneOutlined";
import VisibilityIcon from "@mui/icons-material/Visibility";
import VisibilityOffIcon from "@mui/icons-material/VisibilityOff";
import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import SportsCricketIcon from "@mui/icons-material/SportsCricket";
import CircularProgress from "@mui/material/CircularProgress";
import IconButton from "@mui/material/IconButton";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useDispatch } from "react-redux";
import { register } from "../actions/userAction";
import { useAlert } from "react-alert";

const fadeIn = keyframes`
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
`;

const PageContainer = styled.div`
  min-height: 100vh;
  background: linear-gradient(160deg, #1a1a1a 0%, #0a2e0a 40%, #1a1a1a 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
  position: relative;
  overflow: hidden;

  &::before {
    content: "";
    position: absolute;
    top: -100px;
    right: -100px;
    width: 300px;
    height: 300px;
    border-radius: 50%;
    background: radial-gradient(
      circle,
      rgba(16, 158, 56, 0.15) 0%,
      transparent 70%
    );
  }

  &::after {
    content: "";
    position: absolute;
    bottom: -80px;
    left: -80px;
    width: 250px;
    height: 250px;
    border-radius: 50%;
    background: radial-gradient(
      circle,
      rgba(181, 0, 0, 0.1) 0%,
      transparent 70%
    );
  }
`;

const BackButton = styled.button`
  position: absolute;
  top: 20px;
  left: 20px;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 12px;
  padding: 10px;
  color: #ffffff;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  z-index: 2;

  &:hover {
    background: rgba(255, 255, 255, 0.15);
    border-color: rgba(16, 158, 56, 0.5);
  }

  svg {
    font-size: 22px;
  }
`;

const LogoSection = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 30px;
  animation: ${fadeIn} 0.6s ease-out forwards;
  position: relative;
  z-index: 1;
`;

const LogoImage = styled.img`
  width: 64px;
  height: 64px;
  border-radius: 16px;
  object-fit: cover;
  box-shadow: 0 10px 40px rgba(16, 158, 56, 0.3);
  margin-bottom: 12px;
`;

const AppTitle = styled.h1`
  color: #ffffff;
  font-size: 24px;
  font-weight: 800;
  letter-spacing: 1px;
  margin: 0;
`;

const FormCard = styled.div`
  width: 100%;
  max-width: 380px;
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 24px;
  padding: 32px 28px;
  animation: ${fadeIn} 0.6s ease-out forwards;
  animation-delay: 0.2s;
  opacity: 0;
  position: relative;
  z-index: 1;
`;

const FormTitle = styled.h2`
  color: #ffffff;
  font-size: 22px;
  font-weight: 700;
  text-align: center;
  margin: 0 0 24px 0;
`;

const InputGroup = styled.div`
  margin-bottom: 16px;
`;

const InputLabel = styled.label`
  display: block;
  color: rgba(255, 255, 255, 0.7);
  font-size: 13px;
  font-weight: 500;
  margin-bottom: 8px;
  padding-left: 4px;
`;

const InputWrapper = styled.div`
  display: flex;
  align-items: center;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid
    ${(props) =>
      props.error ? "#ff4444" : props.focused ? "#109e38" : "rgba(255, 255, 255, 0.15)"};
  border-radius: 12px;
  padding: 0 16px;
  transition: all 0.3s ease;

  &:hover {
    border-color: ${(props) => (props.error ? "#ff4444" : "rgba(16, 158, 56, 0.5)")};
  }

  svg {
    color: ${(props) =>
      props.error ? "#ff4444" : props.focused ? "#109e38" : "rgba(255, 255, 255, 0.4)"};
    font-size: 20px;
    transition: color 0.3s ease;
  }
`;

const StyledInput = styled.input`
  width: 100%;
  padding: 14px 12px;
  background: transparent;
  border: none;
  outline: none;
  color: #ffffff;
  font-size: 15px;
  font-family: inherit;

  &::placeholder {
    color: rgba(255, 255, 255, 0.35);
  }

  &:-webkit-autofill {
    -webkit-box-shadow: 0 0 0 30px rgba(26, 26, 26, 0.95) inset !important;
    -webkit-text-fill-color: #ffffff !important;
  }
`;

const ErrorText = styled.span`
  color: #ff4444;
  font-size: 12px;
  padding-left: 4px;
  margin-top: 4px;
  display: block;
`;

const RegisterButton = styled.button`
  width: 100%;
  padding: 16px;
  border: none;
  border-radius: 12px;
  background: linear-gradient(135deg, #109e38 0%, #0d7a2c 100%);
  color: #ffffff;
  font-size: 16px;
  font-weight: 700;
  letter-spacing: 0.5px;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;

  &:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(16, 158, 56, 0.4);
  }

  &:active:not(:disabled) {
    transform: translateY(0);
  }

  &:disabled {
    opacity: 0.7;
    cursor: not-allowed;
  }
`;

const Divider = styled.div`
  display: flex;
  align-items: center;
  margin: 20px 0;

  &::before,
  &::after {
    content: "";
    flex: 1;
    height: 1px;
    background: rgba(255, 255, 255, 0.15);
  }

  span {
    padding: 0 16px;
    color: rgba(255, 255, 255, 0.4);
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 1px;
  }
`;

const LinksContainer = styled.div`
  text-align: center;
  margin-top: 16px;
  animation: ${fadeIn} 0.6s ease-out forwards;
  animation-delay: 0.4s;
  opacity: 0;
  position: relative;
  z-index: 1;
`;

const StyledLink = styled(Link)`
  color: rgba(255, 255, 255, 0.6);
  text-decoration: none;
  font-size: 14px;
  transition: color 0.3s ease;

  &:hover {
    color: #109e38;
  }

  span {
    color: #109e38;
    font-weight: 600;
  }
`;

const CricketDecor = styled.div`
  position: absolute;
  bottom: 40px;
  left: 30px;
  color: rgba(16, 158, 56, 0.1);
  z-index: 0;

  svg {
    font-size: 100px;
    transform: rotate(25deg);
  }
`;

export function Register() {
  const alert = useAlert();
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [formData, setFormData] = useState({
    email: "",
    username: "",
    phoneNumber: "",
    password: "",
  });
  const [errors, setErrors] = useState({});
  const [focused, setFocused] = useState({
    email: false,
    username: false,
    phoneNumber: false,
    password: false,
  });

  const validateForm = () => {
    const newErrors = {};
    if (!formData.email) newErrors.email = "Email is required";
    else if (!/\S+@\S+\.\S+/.test(formData.email))
      newErrors.email = "Enter a valid email";
    if (!formData.username) newErrors.username = "Username is required";
    else if (formData.username.length < 6)
      newErrors.username = "At least 6 characters";
    if (!formData.phoneNumber)
      newErrors.phoneNumber = "Phone number is required";
    else if (formData.phoneNumber.length < 10)
      newErrors.phoneNumber = "At least 10 digits";
    if (!formData.password) newErrors.password = "Password is required";
    else if (formData.password.length < 6)
      newErrors.password = "At least 6 characters";

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleChange = (field, value) => {
    setFormData({ ...formData, [field]: value });
    if (errors[field]) {
      setErrors({ ...errors, [field]: "" });
    }
  };

  const onSubmit = async (e) => {
    e.preventDefault();

    if (!validateForm()) return;

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
    <PageContainer>
      <BackButton onClick={() => navigate(-1)}>
        <ArrowBackIcon />
      </BackButton>

      <CricketDecor>
        <SportsCricketIcon />
      </CricketDecor>

      <LogoSection>
        <LogoImage src="/dreamteam.jpeg" alt="Dream11" />
        <AppTitle>Dream11</AppTitle>
      </LogoSection>

      <FormCard>
        <FormTitle>Create Account</FormTitle>

        <form onSubmit={onSubmit}>
          <InputGroup>
            <InputLabel>Email Address</InputLabel>
            <InputWrapper focused={focused.email} error={!!errors.email}>
              <EmailOutlinedIcon />
              <StyledInput
                type="email"
                placeholder="Enter your email"
                value={formData.email}
                onChange={(e) => handleChange("email", e.target.value)}
                onFocus={() => setFocused({ ...focused, email: true })}
                onBlur={() => setFocused({ ...focused, email: false })}
              />
            </InputWrapper>
            {errors.email && <ErrorText>{errors.email}</ErrorText>}
          </InputGroup>

          <InputGroup>
            <InputLabel>Username</InputLabel>
            <InputWrapper focused={focused.username} error={!!errors.username}>
              <PersonOutlineIcon />
              <StyledInput
                type="text"
                placeholder="Choose a username"
                value={formData.username}
                onChange={(e) => handleChange("username", e.target.value)}
                onFocus={() => setFocused({ ...focused, username: true })}
                onBlur={() => setFocused({ ...focused, username: false })}
              />
            </InputWrapper>
            {errors.username && <ErrorText>{errors.username}</ErrorText>}
          </InputGroup>

          <InputGroup>
            <InputLabel>Phone Number</InputLabel>
            <InputWrapper
              focused={focused.phoneNumber}
              error={!!errors.phoneNumber}
            >
              <PhoneOutlinedIcon />
              <StyledInput
                type="tel"
                placeholder="Enter phone number"
                value={formData.phoneNumber}
                onChange={(e) => handleChange("phoneNumber", e.target.value)}
                onFocus={() => setFocused({ ...focused, phoneNumber: true })}
                onBlur={() => setFocused({ ...focused, phoneNumber: false })}
              />
            </InputWrapper>
            {errors.phoneNumber && <ErrorText>{errors.phoneNumber}</ErrorText>}
          </InputGroup>

          <InputGroup>
            <InputLabel>Password</InputLabel>
            <InputWrapper focused={focused.password} error={!!errors.password}>
              <LockOutlinedIcon />
              <StyledInput
                type={showPassword ? "text" : "password"}
                placeholder="Create a password"
                value={formData.password}
                onChange={(e) => handleChange("password", e.target.value)}
                onFocus={() => setFocused({ ...focused, password: true })}
                onBlur={() => setFocused({ ...focused, password: false })}
              />
              <IconButton
                size="small"
                onClick={() => setShowPassword(!showPassword)}
                style={{ color: "rgba(255,255,255,0.4)" }}
              >
                {showPassword ? (
                  <VisibilityOffIcon fontSize="small" />
                ) : (
                  <VisibilityIcon fontSize="small" />
                )}
              </IconButton>
            </InputWrapper>
            {errors.password && <ErrorText>{errors.password}</ErrorText>}
          </InputGroup>

          <RegisterButton type="submit" disabled={isLoading}>
            {isLoading ? (
              <CircularProgress size={22} style={{ color: "#fff" }} />
            ) : (
              "Create Account"
            )}
          </RegisterButton>
        </form>

        <Divider>
          <span>or</span>
        </Divider>

        <div style={{ textAlign: "center" }}>
          <StyledLink to="/login">
            Already have an account? <span>Log In</span>
          </StyledLink>
        </div>
      </FormCard>

      <LinksContainer>
        <StyledLink to="/login" style={{ fontSize: 13 }}>
          By signing up, you agree to our Terms of Service
        </StyledLink>
      </LinksContainer>
    </PageContainer>
  );
}

export default Register;

import styled from "@emotion/styled";
import { keyframes } from "@emotion/react";
import EmailOutlinedIcon from "@mui/icons-material/EmailOutlined";
import LockOutlinedIcon from "@mui/icons-material/LockOutlined";
import VisibilityIcon from "@mui/icons-material/Visibility";
import VisibilityOffIcon from "@mui/icons-material/VisibilityOff";
import SportsCricketIcon from "@mui/icons-material/SportsCricket";
import CircularProgress from "@mui/material/CircularProgress";
import IconButton from "@mui/material/IconButton";
import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Link, useNavigate } from "react-router-dom";
import { login } from "../actions/userAction";
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

const LogoSection = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 40px;
  animation: ${fadeIn} 0.6s ease-out forwards;
  position: relative;
  z-index: 1;
`;

const LogoImage = styled.img`
  width: 80px;
  height: 80px;
  border-radius: 20px;
  object-fit: cover;
  box-shadow: 0 10px 40px rgba(16, 158, 56, 0.3);
  margin-bottom: 16px;
`;

const AppTitle = styled.h1`
  color: #ffffff;
  font-size: 28px;
  font-weight: 800;
  letter-spacing: 1px;
  margin: 0;
`;

const AppSubtitle = styled.p`
  color: rgba(255, 255, 255, 0.5);
  font-size: 13px;
  margin-top: 4px;
  letter-spacing: 0.5px;
`;

const FormCard = styled.div`
  width: 100%;
  max-width: 380px;
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 24px;
  padding: 36px 28px;
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
  margin: 0 0 28px 0;
`;

const InputGroup = styled.div`
  margin-bottom: 20px;
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

const LoginButton = styled.button`
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
  margin: 24px 0;

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
  margin-top: 20px;
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

const ForgotLink = styled(Link)`
  display: block;
  text-align: right;
  color: rgba(255, 255, 255, 0.5);
  text-decoration: none;
  font-size: 13px;
  margin-top: -8px;
  margin-bottom: 20px;
  transition: color 0.3s ease;

  &:hover {
    color: #109e38;
  }
`;

const CricketDecor = styled.div`
  position: absolute;
  top: 30px;
  right: 30px;
  color: rgba(16, 158, 56, 0.15);
  z-index: 0;

  svg {
    font-size: 80px;
    transform: rotate(-15deg);
  }
`;

export function Login() {
  const { user, isAuthenticated, error } = useSelector((state) => state.user);
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const alert = useAlert();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState({});
  const [focused, setFocused] = useState({ email: false, password: false });

  useEffect(() => {
    if (isAuthenticated && user) {
      navigate("/");
    }
    if (error) {
      alert.error(error);
    }
  }, [user, isAuthenticated, error, navigate]);

  const validate = () => {
    const newErrors = {};
    if (!email) newErrors.email = "Email is required";
    else if (!/\S+@\S+\.\S+/.test(email)) newErrors.email = "Enter a valid email";
    if (!password) newErrors.password = "Password is required";
    else if (password.length < 6) newErrors.password = "At least 6 characters";
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validate()) return;

    setIsLoading(true);
    const result = await dispatch(login({ email, password }));
    setIsLoading(false);

    if (result.success) {
      alert.success("Login successful!");
      navigate("/");
    } else {
      alert.error(result.message || "Login failed. Please try again.");
    }
  };

  return (
    <PageContainer>
      <CricketDecor>
        <SportsCricketIcon />
      </CricketDecor>

      <LogoSection>
        <LogoImage src="/dreamteam.jpeg" alt="Dream11" />
        <AppTitle>Dream11</AppTitle>
        <AppSubtitle>Fantasy Cricket Platform</AppSubtitle>
      </LogoSection>

      <FormCard>
        <FormTitle>Welcome Back</FormTitle>

        <form onSubmit={handleSubmit}>
          <InputGroup>
            <InputLabel>Email Address</InputLabel>
            <InputWrapper focused={focused.email} error={!!errors.email}>
              <EmailOutlinedIcon />
              <StyledInput
                type="email"
                placeholder="Enter your email"
                value={email}
                onChange={(e) => {
                  setEmail(e.target.value);
                  if (errors.email) setErrors({ ...errors, email: "" });
                }}
                onFocus={() => setFocused({ ...focused, email: true })}
                onBlur={() => setFocused({ ...focused, email: false })}
              />
            </InputWrapper>
            {errors.email && <ErrorText>{errors.email}</ErrorText>}
          </InputGroup>

          <InputGroup>
            <InputLabel>Password</InputLabel>
            <InputWrapper focused={focused.password} error={!!errors.password}>
              <LockOutlinedIcon />
              <StyledInput
                type={showPassword ? "text" : "password"}
                placeholder="Enter your password"
                value={password}
                onChange={(e) => {
                  setPassword(e.target.value);
                  if (errors.password) setErrors({ ...errors, password: "" });
                }}
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

          <ForgotLink to="/forgot-password">Forgot Password?</ForgotLink>

          <LoginButton type="submit" disabled={isLoading}>
            {isLoading ? (
              <CircularProgress size={22} style={{ color: "#fff" }} />
            ) : (
              "Log In"
            )}
          </LoginButton>
        </form>

        <Divider>
          <span>or</span>
        </Divider>

        <LinksContainer style={{ margin: 0, opacity: 1, animation: "none" }}>
          <StyledLink to="/register">
            New to Dream11? <span>Create Account</span>
          </StyledLink>
        </LinksContainer>
      </FormCard>

      <LinksContainer>
        <StyledLink to="/forgot-password" style={{ fontSize: 13 }}>
          Need help? Contact Support
        </StyledLink>
      </LinksContainer>
    </PageContainer>
  );
}

export default Login;

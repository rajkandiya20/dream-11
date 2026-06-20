import styled from "@emotion/styled";
import { keyframes } from "@emotion/react";

const fadeIn = keyframes`
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
`;

const pulse = keyframes`
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
`;

const shimmer = keyframes`
  0% {
    background-position: -200% center;
  }
  100% {
    background-position: 200% center;
  }
`;

const bounce = keyframes`
  0%, 80%, 100% {
    transform: scale(0);
  }
  40% {
    transform: scale(1);
  }
`;

const SplashContainer = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: linear-gradient(135deg, #1a1a1a 0%, #0d3d0d 50%, #1a1a1a 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  overflow: hidden;

  &::before {
    content: "";
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: radial-gradient(
      circle at center,
      rgba(16, 158, 56, 0.1) 0%,
      transparent 50%
    );
    animation: ${pulse} 3s ease-in-out infinite;
  }
`;

const LogoWrapper = styled.div`
  animation: ${fadeIn} 0.8s ease-out forwards;
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  z-index: 2;
`;

const LogoImage = styled.img`
  width: 120px;
  height: 120px;
  border-radius: 24px;
  object-fit: cover;
  box-shadow: 0 20px 60px rgba(16, 158, 56, 0.3),
    0 0 40px rgba(16, 158, 56, 0.1);
  animation: ${pulse} 2s ease-in-out infinite;
  animation-delay: 0.8s;
`;

const AppName = styled.h1`
  color: #ffffff;
  font-size: 36px;
  font-weight: 800;
  margin-top: 24px;
  letter-spacing: 2px;
  text-transform: uppercase;
  background: linear-gradient(90deg, #ffffff, #109e38, #ffffff);
  background-size: 200% auto;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: ${shimmer} 3s linear infinite;
  animation-delay: 0.5s;
`;

const Tagline = styled.p`
  color: rgba(255, 255, 255, 0.6);
  font-size: 14px;
  margin-top: 8px;
  letter-spacing: 1px;
  animation: ${fadeIn} 1s ease-out forwards;
  animation-delay: 0.5s;
  opacity: 0;
`;

const LoadingDots = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 48px;
  gap: 8px;
`;

const Dot = styled.div`
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background-color: #109e38;
  animation: ${bounce} 1.4s ease-in-out infinite both;
  animation-delay: ${(props) => props.delay || "0s"};
`;

const CricketIcon = styled.div`
  position: absolute;
  bottom: 60px;
  color: rgba(255, 255, 255, 0.3);
  font-size: 14px;
  letter-spacing: 1px;
  animation: ${fadeIn} 1.2s ease-out forwards;
  animation-delay: 1s;
  opacity: 0;
`;

export default function SplashScreen() {
  return (
    <SplashContainer>
      <LogoWrapper>
        <LogoImage src="/dreamteam.jpeg" alt="Dream11" />
        <AppName>Dream11</AppName>
        <Tagline>Fantasy Cricket at its Best</Tagline>
        <LoadingDots>
          <Dot delay="0s" />
          <Dot delay="0.2s" />
          <Dot delay="0.4s" />
        </LoadingDots>
      </LogoWrapper>
      <CricketIcon>Made with passion for cricket</CricketIcon>
    </SplashContainer>
  );
}

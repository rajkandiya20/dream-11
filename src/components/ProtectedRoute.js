import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

const ProtectedRoute = ({ children }) => {
  const navigate = useNavigate();
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [checking, setChecking] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem("token");
    const storedUser = localStorage.getItem("user");

    if (!token || token === "undefined") {
      setIsLoggedIn(false);
      setChecking(false);
      navigate("/login");
      return;
    }

    if (storedUser) {
      try {
        JSON.parse(storedUser);
        setIsLoggedIn(true);
      } catch {
        setIsLoggedIn(false);
        navigate("/login");
      }
    } else {
      setIsLoggedIn(false);
      navigate("/login");
    }
    setChecking(false);
  }, [navigate]);

  if (checking) return null;

  return <React.Fragment>{isLoggedIn ? children : null}</React.Fragment>;
};

export default ProtectedRoute;

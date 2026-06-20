import { useEffect } from "react";

const AdminLoginCheck = ({ children }) => {
  const checkAdminStatus = () => {
    const user = JSON.parse(localStorage.getItem("user") || "{}");
    const token = localStorage.getItem("token");
    if (user?.email === "rexoagency.in@gmail.com" && token) {
      return true;
    }
    return false;
  };

  useEffect(() => {
    if (!checkAdminStatus()) {
      localStorage.setItem("redirectToAdmin", "true");
    }
  }, []);

  return children;
};

export const isAdminEmail = (email) => email === "rexoagency.in@gmail.com";

export const ADMIN_CONFIG = {
  email: "rexoagency.in@gmail.com",
};

export default AdminLoginCheck;

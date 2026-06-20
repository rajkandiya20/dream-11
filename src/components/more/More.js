import "./More.css";

import styled from "@emotion/styled";
import PersonOutlineOutlinedIcon from "@mui/icons-material/PersonOutlineOutlined";
import AccountBalanceWalletOutlinedIcon from "@mui/icons-material/AccountBalanceWalletOutlined";
import AdminPanelSettingsOutlinedIcon from "@mui/icons-material/AdminPanelSettingsOutlined";
import PeopleOutlineOutlinedIcon from "@mui/icons-material/PeopleOutlineOutlined";
import HelpOutlineOutlinedIcon from "@mui/icons-material/HelpOutlineOutlined";
import LogoutOutlinedIcon from "@mui/icons-material/LogoutOutlined";
import ChevronRightIcon from "@mui/icons-material/ChevronRight";
import { useDispatch, useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";
import { logout } from "../../actions/userAction";
import Bottomnav from "../navbar/bottomnavbar";
import Navbar from "../navbar";

const MoreContainer = styled.div`
  padding: 10px 0;
  padding-bottom: 90px;
  min-height: 60vh;
`;

const MenuItem = styled.div`
  display: flex;
  align-items: center;
  padding: 16px 20px;
  cursor: pointer;
  border-bottom: 1px solid #f0f0f0;
  transition: background-color 0.2s;
  &:hover {
    background-color: #f9f9f9;
  }
  &:active {
    background-color: #f0f0f0;
  }
`;

const MenuIcon = styled.div`
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background-color: #f5f5f5;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
  color: #555;
`;

const MenuLabel = styled.span`
  flex: 1;
  font-size: 15px;
  font-weight: 500;
  color: #333;
`;

const MenuArrow = styled.div`
  color: #ccc;
`;

const LogoutItem = styled(MenuItem)`
  margin-top: 20px;
  border-top: 1px solid #f0f0f0;
`;

const LogoutLabel = styled(MenuLabel)`
  color: var(--red);
`;

export function More() {
  const { user } = useSelector((state) => state.user);
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const handleLogout = () => {
    dispatch(logout());
    navigate("/login");
  };

  const menuItems = [
    {
      icon: <PersonOutlineOutlinedIcon />,
      label: "My Info",
      path: "/my-info",
    },
    {
      icon: <AccountBalanceWalletOutlinedIcon />,
      label: "Transactions",
      path: "/transaction",
    },
    {
      icon: <PeopleOutlineOutlinedIcon />,
      label: "Find People",
      path: "/findpeople",
    },
    {
      icon: <HelpOutlineOutlinedIcon />,
      label: "Help & Support",
      path: null, // No route yet
    },
  ];

  // Add admin link if user is admin
  const ADMIN_EMAIL = 'rexoagency.in@gmail.com';
  const isAdmin = user?.isAdmin || user?.role === "admin" || user?.role === "super_admin" || user?.email === ADMIN_EMAIL;
  if (isAdmin) {
    menuItems.splice(2, 0, {
      icon: <AdminPanelSettingsOutlinedIcon />,
      label: "Admin Panel",
      path: "/admin",
    });
  }

  return (
    <>
      <Navbar />
      <MoreContainer>
        <h4 style={{ padding: "10px 20px", marginBottom: 5 }}>More</h4>
        {menuItems.map((item, index) => (
          <MenuItem
            key={index}
            onClick={() => item.path && navigate(item.path)}
          >
            <MenuIcon>{item.icon}</MenuIcon>
            <MenuLabel>{item.label}</MenuLabel>
            <MenuArrow>
              <ChevronRightIcon />
            </MenuArrow>
          </MenuItem>
        ))}
        <LogoutItem onClick={handleLogout}>
          <MenuIcon style={{ color: "var(--red)" }}>
            <LogoutOutlinedIcon />
          </MenuIcon>
          <LogoutLabel>Logout</LogoutLabel>
        </LogoutItem>
      </MoreContainer>
      <Bottomnav />
    </>
  );
}

export default More;

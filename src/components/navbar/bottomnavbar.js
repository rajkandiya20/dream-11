import EmojiEventsOutlinedIcon from "@mui/icons-material/EmojiEventsOutlined";
import FeedOutlinedIcon from "@mui/icons-material/FeedOutlined";
import GroupsOutlinedIcon from "@mui/icons-material/GroupsOutlined";
import HomeOutlinedIcon from "@mui/icons-material/HomeOutlined";
import MoreHorizOutlinedIcon from "@mui/icons-material/MoreHorizOutlined";
import { useSelector } from "react-redux";
import { useLocation, useNavigate } from "react-router-dom";
import "./bottomnavbar.css";

export function Bottomnav() {
  const { user, isAuthenticated } = useSelector((state) => state.user);
  const navigate = useNavigate();
  const location = useLocation();
  
  // Get user ID safely
  const userId = user?._id || user?.uid;
  
  return (
    <div className="bottomnav">
      <div
        onClick={() => navigate("/")}
        className={location.pathname === "/" ? "selectedrt" : "notselectedrt"}
      >
        <HomeOutlinedIcon style={{ fontSize: "28px" }} />
        <span>Home</span>
      </div>
      <div
        onClick={() => userId && navigate(`/completed/${userId}`)}
        className={
          location.pathname.includes("/completed") ? "selectedrt" : "notselectedrt"
        }
      >
        <EmojiEventsOutlinedIcon style={{ fontSize: "28px" }} />
        <span>My Matches</span>
      </div>
      <div
        onClick={() => navigate("/feed")}
        className={
          location.pathname === "/feed" ? "selectedrt" : "notselectedrt"
        }
      >
        <FeedOutlinedIcon style={{ fontSize: "28px" }} />
        <span>Feed</span>
      </div>
      <div
        onClick={() => navigate("/groups")}
        className={
          location.pathname === "/groups" ? "selectedrt" : "notselectedrt"
        }
      >
        <GroupsOutlinedIcon style={{ fontSize: "28px" }} />
        <span>Groups</span>
      </div>
      <div
        onClick={() => navigate("/more")}
        className={
          location.pathname === "/more" ? "selectedrt" : "notselectedrt"
        }
      >
        <MoreHorizOutlinedIcon style={{ fontSize: "28px" }} />
        <span>More</span>
      </div>
    </div>
  );
}

export default Bottomnav;

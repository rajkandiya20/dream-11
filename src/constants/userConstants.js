export const LOGIN_REQUEST = "LOGIN_REQUEST";
export const LOGIN_SUCCESS = "LOGIN_SUCCESS";
export const LOGIN_FAIL = "LOGIN_FAIL";

export const REGISTER_USER_REQUEST = "REGISTER_USER_REQUEST";
export const REGISTER_USER_SUCCESS = "REGISTER_USER_SUCCESS";
export const REGISTER_USER_FAIL = "REGISTER_USER_FAIL";

export const LOAD_USER_REQUEST = "LOAD_USER_REQUEST";
export const LOAD_USER_SUCCESS = "LOAD_USER_SUCCESS";
export const LOAD_USER_FAIL = "LOAD_USER_FAIL";

export const LOGOUT_SUCCESS = "LOGOUT_SUCCESS";
export const LOGOUT_FAIL = "LOGOUT_FAIL";
export const ADD_CONFETTI = "ADD_CONFETTI";
export const REMOVE_CONFETTI = "REMOVE_CONFETTI";

export const CLEAR_ERRORS = "CLEAR_ERRORS";

function geturl() {
  const current = process.env.REACT_APP_API;
  if (current == "local") {
    return "http://localhost:8000";
  }
  return "https://backendforpuand-dream11.onrender.com";
}

function getfrontendurl() {
  const current = process.env.REACT_APP_API;
  if (current == "local") {
    return "http://localhost:3000";
  }
  return "https://dream-11-clone-mern-stack.vercel.app";
}

export const URL = geturl();
export const FURL = getfrontendurl();

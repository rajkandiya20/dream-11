import { configureStore } from "@reduxjs/toolkit";
import { combineReducers } from "redux";
import thunk from "redux-thunk";
import { matchReducer } from "./reducers/matchReducer";
import { userReducer } from "./reducers/userReducer";

const reducer = combineReducers({
  user: userReducer,
  match: matchReducer,
});

const middleware = [thunk];

const store = configureStore({
  reducer,
  middleware,
});

export default store;

import { configureStore } from "@reduxjs/toolkit";
import { matchReducer } from "./reducers/matchReducer";
import { userReducer } from "./reducers/userReducer";

const store = configureStore({
  reducer: {
    user: userReducer,
    match: matchReducer,
  },
});

export default store;

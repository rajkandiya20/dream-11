import axios from "axios";

import {
  MATCH_FAIL,
  MATCH_LIVE_SUCCESS,
  MATCH_REQUEST,
  MATCH_SUCCESS,
} from "../constants/matchConstants";
import { URL } from "../constants/userConstants";

const API_TIMEOUT = 10000; // 10 seconds

const headers = {
  Accept: "application/json",
};

export const getmatch = (id) => async (dispatch) => {
  try {
    dispatch({ type: MATCH_REQUEST });

    const api = axios.create({ timeout: API_TIMEOUT });

    const [contestsResponse, matchResponse, matchLiveResponse] =
      await Promise.allSettled([
        api.get(`${URL}/getcontests/${id}`),
        api.get(`${URL}/getmatch/${id}`),
        api.get(`${URL}/getmatchlive/${id}`),
      ]);

    if (matchResponse.status === "fulfilled" && matchResponse.value?.data?.match) {
      dispatch({ type: MATCH_SUCCESS, payload: matchResponse.value.data.match });
    } else {
      console.error("Failed to fetch match data:", matchResponse.reason || "No data");
      dispatch({ type: MATCH_FAIL, payload: "Failed to load match data" });
    }

    if (matchLiveResponse.status === "fulfilled" && matchLiveResponse.value?.data?.match) {
      dispatch({ type: MATCH_LIVE_SUCCESS, payload: matchLiveResponse.value.data.match });
    }
  } catch (error) {
    console.error("Error in getmatch action:", error);
    dispatch({
      type: MATCH_FAIL,
      payload: error?.response?.data?.message || error.message || "Failed to load match",
    });
  }
};

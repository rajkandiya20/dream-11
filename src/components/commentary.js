import styled from "@emotion/styled";
import { useEffect, useRef, useState } from "react";
import { useDispatch, useSelector } from "react-redux";

import { addconfetti, removeconfetti } from "../actions/userAction";
import { subscribeToScoreboard } from "../services/realtimeService";

const CommentaryContainer = styled.div`
  padding: 15px 0;
  height: 100%;
  overflow-y: scroll;
`;
const Left = styled.div`
  font-size: 14px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding-right: 20px;
`;
const Comment = styled.div`
  display: flex;
  align-items: flex-start;
  font-family: "Open Sans" !important;
  padding: 5px 15px;
`;

const Event = styled.div`
  width: 30px;
  font-family: "Open Sans" !important;
  overflow: hidden;
  text-align: center;
  display: flex;
  justify-content: center;
`;

const Des = styled.p`
  text-align: left;
  width: 280px;
  line-height: 20px;
  line-break: break;
  font-size: 14px;
`;

const Wicket = styled.p`
  width: 18px;
  height: 18px;
  line-height: 20px;
  border-radius: 50%;
  background-color: var(--red);
  display: flex;
  align-items: center;
  font-size: 12px;
  justify-content: center;
  color: #ffffff;
`;

const Four = styled.p`
  width: 18px;
  height: 18px;
  line-height: 20px;
  font-size: 12px;
  border-radius: 50%;
  background-color: var(--black);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #ffffff;
`;

const Break = styled.div`
  padding: 4px 15px;
  background-color: #fafafa;
  border-top: 1px solid #ccc;
  border-bottom: 1px solid #ccc;
  p {
    max-width: 100px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    font-size: 14px;
  }
`;

const BreakBot = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
`;

export function Commentary({ matchdata }) {
  const [commentary, setCommentary] = useState([]);
  const scrollit = useRef();
  const dispatch = useDispatch();

  useEffect(() => {
    const matchId = matchdata?.matchId || matchdata?.id || matchdata?._id;
    if (!matchId) return;

    const unsubscribe = subscribeToScoreboard(matchId, (payload) => {
      const newData = payload.new;
      if (newData && newData.commentary) {
        // Transform scoreboard commentary data to the expected format
        const commentaryData = Array.isArray(newData.commentary)
          ? newData.commentary
          : [];
        setCommentary(commentaryData);
      } else if (newData) {
        // If the payload contains ball-by-ball data directly
        setCommentary((prev) => {
          const entry = {
            event: newData.event || '',
            overNumber: newData.over_number || newData.overNumber || '',
            commText: newData.comm_text || newData.commText || '',
            overSeparator: newData.over_separator || newData.overSeparator || null,
          };
          return [entry, ...prev];
        });
      }
    });

    return () => {
      unsubscribe();
    };
  }, [matchdata]);

  useEffect(() => {
    if (commentary[0]?.event == "SIX") {
      dispatch(addconfetti());
      setTimeout(() => {
        dispatch(removeconfetti());
      }, 4000);
    } else if (commentary[0]?.event == "FOUR") {
      dispatch(addconfetti());
      setTimeout(() => {
        dispatch(removeconfetti());
      }, 4000);
    } else if (
      commentary[0]?.event == "WICKET" ||
      commentary[0]?.event == "over-break,WICKET"
    ) {
      dispatch(addconfetti());
      setTimeout(() => {
        dispatch(removeconfetti());
      }, 4000);
    }
  }, [commentary]);

  return (
    <CommentaryContainer>
      {commentary?.map((p, idx) => (
        <div key={idx}>
          {p?.event == "over-break" ? (
            <>
              <Break>
                <h5>End of over {p?.overSeparator?.overNum}</h5>
                <BreakBot>
                  <p>{p?.overSeparator?.bowlNames?.[0]}</p>
                  <p>{p?.overSeparator?.runs} runs</p>
                  <p>{p?.overSeparator?.bowlwickets} wickets</p>
                  <p>{p?.overSeparator?.batTeamName}</p>
                  <p>
                    {p?.overSeparator?.score}/{p?.overSeparator?.wickets}
                  </p>
                </BreakBot>
              </Break>
              <Comment ref={scrollit}>
                <Left>
                  <Event>
                    {p?.event == "WICKET" || p?.event == "over-break,WICKET" ? (
                      <Wicket>w</Wicket>
                    ) : p?.event == "FOUR" ? (
                      <Four>4</Four>
                    ) : p?.event == "SIX" ? (
                      <Four>6</Four>
                    ) : null}
                  </Event>
                  {p?.overNumber}
                </Left>
                <Des>{p?.commText?.replace("$", "")}</Des>
              </Comment>
            </>
          ) : (
            <Comment ref={scrollit}>
              <Left>
                <Event>
                  {p?.event == "WICKET" ? (
                    <Wicket>w</Wicket>
                  ) : p?.event == "FOUR" ? (
                    <Four>4</Four>
                  ) : p?.event == "SIX" ? (
                    <Four>6</Four>
                  ) : null}
                </Event>
                {p?.overNumber}
              </Left>
              <Des>{p?.commText?.replace("$", "").replace("B0", "")}</Des>
            </Comment>
          )}
        </div>
      ))}
    </CommentaryContainer>
  );
}

export default Commentary;

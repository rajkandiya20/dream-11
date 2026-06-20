import styled from "@emotion/styled";
import {
  Button,
  Typography,
  Card,
  CardContent,
  Grid,
} from "@mui/material";
import CheckCircleIcon from "@mui/icons-material/CheckCircle";
import CancelIcon from "@mui/icons-material/Cancel";
import AccountBalanceWalletIcon from "@mui/icons-material/AccountBalanceWallet";
import { useState, useEffect } from "react";
import { useAlert } from "react-alert";
import {
  getPendingDeposits,
  approveDeposit,
  rejectDeposit,
} from "../../services/supabaseService";

const Container = styled.div`
  padding: 20px;
`;

const SectionTitle = styled.h2`
  font-size: 18px;
  margin: 20px 0 15px;
  color: var(--black);
  border-bottom: 2px solid var(--green);
  padding-bottom: 5px;
`;

const CardWrapper = styled(Card)`
  margin-bottom: 15px;
  border-radius: 10px;
`;

const AmountBadge = styled.span`
  display: inline-block;
  padding: 4px 12px;
  border-radius: 16px;
  font-size: 14px;
  font-weight: 700;
  background-color: #e8f5e9;
  color: #2e7d32;
`;

const EmptyState = styled.div`
  text-align: center;
  padding: 60px 20px;
  color: #888;
`;

export default function ADeposit() {
  const alert = useAlert();
  const [deposits, setDeposits] = useState([]);
  const [processing, setProcessing] = useState(null);

  useEffect(() => {
    fetchDeposits();
  }, []);

  const fetchDeposits = async () => {
    const data = await getPendingDeposits();
    setDeposits(data || []);
  };

  const handleApprove = async (deposit) => {
    setProcessing(deposit.id);
    try {
      await approveDeposit(deposit.id, deposit.user_id, deposit.amount);
      alert.success("Deposit approved and wallet credited");
      fetchDeposits();
    } catch (error) {
      alert.error("Failed to approve deposit");
    }
    setProcessing(null);
  };

  const handleReject = async (deposit) => {
    setProcessing(deposit.id);
    try {
      await rejectDeposit(deposit.id);
      alert.success("Deposit rejected");
      fetchDeposits();
    } catch (error) {
      alert.error("Failed to reject deposit");
    }
    setProcessing(null);
  };

  return (
    <Container>
      <SectionTitle>Pending Deposit Approvals</SectionTitle>

      {deposits.length === 0 ? (
        <EmptyState>
          <AccountBalanceWalletIcon style={{ fontSize: 48, color: "#ccc", marginBottom: 10 }} />
          <Typography variant="body1" color="text.secondary">
            No pending deposits
          </Typography>
        </EmptyState>
      ) : (
        <Grid container spacing={2}>
          {deposits.map((deposit) => (
            <Grid item xs={12} key={deposit.id}>
              <CardWrapper variant="outlined">
                <CardContent>
                  <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                    <div>
                      <Typography variant="subtitle1" style={{ fontWeight: 600 }}>
                        {deposit.user?.username || "User"}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        {deposit.user?.email || ""}
                      </Typography>
                      <div style={{ marginTop: "8px" }}>
                        <AmountBadge>Rs. {deposit.amount || 0}</AmountBadge>
                      </div>
                      {deposit.payment_method && (
                        <Typography variant="caption" color="text.secondary" style={{ display: "block", marginTop: "4px" }}>
                          Via: {deposit.payment_method}
                        </Typography>
                      )}
                      <Typography variant="caption" color="text.secondary" style={{ display: "block", marginTop: "2px" }}>
                        {deposit.created_at ? new Date(deposit.created_at).toLocaleString() : ""}
                      </Typography>
                    </div>
                    <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
                      <Button
                        variant="contained"
                        color="success"
                        size="small"
                        startIcon={<CheckCircleIcon />}
                        onClick={() => handleApprove(deposit)}
                        disabled={processing === deposit.id}
                      >
                        Approve
                      </Button>
                      <Button
                        variant="outlined"
                        color="error"
                        size="small"
                        startIcon={<CancelIcon />}
                        onClick={() => handleReject(deposit)}
                        disabled={processing === deposit.id}
                      >
                        Reject
                      </Button>
                    </div>
                  </div>
                </CardContent>
              </CardWrapper>
            </Grid>
          ))}
        </Grid>
      )}
    </Container>
  );
}

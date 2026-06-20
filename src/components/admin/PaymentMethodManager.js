import styled from "@emotion/styled";
import {
  Button,
  TextField,
  Typography,
  Card,
  CardContent,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  IconButton,
  Checkbox,
  FormControlLabel,
} from "@mui/material";
import DeleteIcon from "@mui/icons-material/Delete";
import StarIcon from "@mui/icons-material/Star";
import StarBorderIcon from "@mui/icons-material/StarBorder";
import AccountBalanceIcon from "@mui/icons-material/AccountBalance";
import PhoneAndroidIcon from "@mui/icons-material/PhoneAndroid";
import { useState, useEffect } from "react";
import { useAlert } from "react-alert";
import {
  getPaymentMethods,
  addPaymentMethod,
  deletePaymentMethod,
  updatePaymentMethod,
} from "../../services/supabaseService";

const Container = styled.div`
  padding: 15px 0;
`;

const MethodCard = styled(Card)`
  margin-bottom: 12px;
  border-radius: 10px;
`;

const SectionTitle = styled.h3`
  font-size: 16px;
  margin: 10px 0 12px;
  color: var(--black);
  border-bottom: 2px solid var(--green);
  padding-bottom: 5px;
`;

const AddForm = styled.div`
  padding: 15px;
  background-color: #f9f9f9;
  border-radius: 10px;
  margin-top: 12px;
`;

const METHOD_TYPES = [
  { value: "upi", label: "UPI" },
  { value: "bank_account", label: "Bank Account" },
  { value: "phonepe", label: "PhonePe" },
  { value: "gpay", label: "Google Pay" },
];

const getMethodIcon = (type) => {
  switch (type) {
    case "upi":
      return <PhoneAndroidIcon fontSize="small" style={{ color: "#4caf50" }} />;
    case "bank_account":
      return <AccountBalanceIcon fontSize="small" style={{ color: "#1565c0" }} />;
    case "phonepe":
      return <PhoneAndroidIcon fontSize="small" style={{ color: "#5f259f" }} />;
    case "gpay":
      return <PhoneAndroidIcon fontSize="small" style={{ color: "#4285f4" }} />;
    default:
      return <PhoneAndroidIcon fontSize="small" />;
  }
};

export default function PaymentMethodManager({ userId }) {
  const alert = useAlert();
  const [methods, setMethods] = useState([]);
  const [showForm, setShowForm] = useState(false);
  const [confirmingDelete, setConfirmingDelete] = useState(null);
  const [formData, setFormData] = useState({
    method_type: "upi",
    details: {},
    is_default: false,
  });

  useEffect(() => {
    if (userId) {
      fetchMethods();
    }
  }, [userId]);

  const fetchMethods = async () => {
    const data = await getPaymentMethods(userId);
    setMethods(data || []);
  };

  const handleAdd = async () => {
    if (!userId) {
      alert.error("User not identified");
      return;
    }

    // Validate details based on method type
    const { method_type, details } = formData;
    if (method_type === "upi" && !details.upi_id) {
      alert.error("UPI ID is required");
      return;
    }
    if (method_type === "bank_account" && (!details.account_number || !details.ifsc)) {
      alert.error("Account number and IFSC are required");
      return;
    }
    if ((method_type === "phonepe" || method_type === "gpay") && !details.phone_number) {
      alert.error("Phone number is required");
      return;
    }

    try {
      await addPaymentMethod({
        user_id: userId,
        method_type: formData.method_type,
        details: formData.details,
        is_default: formData.is_default,
      });
      alert.success("Payment method added");
      setShowForm(false);
      setFormData({ method_type: "upi", details: {}, is_default: false });
      fetchMethods();
    } catch (error) {
      alert.error("Failed to add payment method");
    }
  };

  const handleDelete = async (id) => {
    try {
      await deletePaymentMethod(id);
      alert.success("Payment method deleted");
      setConfirmingDelete(null);
      fetchMethods();
    } catch (error) {
      alert.error("Failed to delete");
    }
  };

  const handleSetDefault = async (id) => {
    try {
      // Unset all defaults first
      for (const m of methods) {
        if (m.is_default && m.id !== id) {
          await updatePaymentMethod(m.id, { is_default: false });
        }
      }
      await updatePaymentMethod(id, { is_default: true });
      alert.success("Default updated");
      fetchMethods();
    } catch (error) {
      alert.error("Failed to update default");
    }
  };

  const renderDetailsFields = () => {
    switch (formData.method_type) {
      case "upi":
        return (
          <TextField
            label="UPI ID"
            value={formData.details.upi_id || ""}
            onChange={(e) =>
              setFormData({ ...formData, details: { upi_id: e.target.value } })
            }
            fullWidth
            margin="normal"
            size="small"
            placeholder="e.g. name@paytm"
          />
        );
      case "bank_account":
        return (
          <>
            <TextField
              label="Account Number"
              value={formData.details.account_number || ""}
              onChange={(e) =>
                setFormData({
                  ...formData,
                  details: { ...formData.details, account_number: e.target.value },
                })
              }
              fullWidth
              margin="normal"
              size="small"
            />
            <TextField
              label="IFSC Code"
              value={formData.details.ifsc || ""}
              onChange={(e) =>
                setFormData({
                  ...formData,
                  details: { ...formData.details, ifsc: e.target.value },
                })
              }
              fullWidth
              margin="normal"
              size="small"
            />
            <TextField
              label="Bank Name"
              value={formData.details.bank_name || ""}
              onChange={(e) =>
                setFormData({
                  ...formData,
                  details: { ...formData.details, bank_name: e.target.value },
                })
              }
              fullWidth
              margin="normal"
              size="small"
            />
          </>
        );
      case "phonepe":
      case "gpay":
        return (
          <TextField
            label="Phone Number"
            value={formData.details.phone_number || ""}
            onChange={(e) =>
              setFormData({ ...formData, details: { phone_number: e.target.value } })
            }
            fullWidth
            margin="normal"
            size="small"
            placeholder="e.g. 9876543210"
          />
        );
      default:
        return null;
    }
  };

  return (
    <Container>
      <SectionTitle>Payment Methods</SectionTitle>

      {methods.map((method) => (
        <MethodCard key={method.id} variant="outlined">
          <CardContent style={{ padding: "12px 16px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            <div style={{ display: "flex", alignItems: "center" }}>
              {getMethodIcon(method.method_type)}
              <div style={{ marginLeft: "10px" }}>
                <Typography variant="body1" style={{ fontWeight: 500, textTransform: "capitalize" }}>
                  {method.method_type === "bank_account" ? "Bank Account" : method.method_type}
                </Typography>
                <Typography variant="body2" color="text.secondary" style={{ fontSize: "12px" }}>
                  {method.method_type === "upi" && method.details?.upi_id}
                  {method.method_type === "bank_account" && `${method.details?.bank_name || ""} - ****${(method.details?.account_number || "").slice(-4)}`}
                  {(method.method_type === "phonepe" || method.method_type === "gpay") && method.details?.phone_number}
                </Typography>
              </div>
            </div>
            <div style={{ display: "flex", alignItems: "center" }}>
              <IconButton size="small" onClick={() => handleSetDefault(method.id)}>
                {method.is_default ? (
                  <StarIcon fontSize="small" style={{ color: "#ffc107" }} />
                ) : (
                  <StarBorderIcon fontSize="small" />
                )}
              </IconButton>
              {confirmingDelete === method.id ? (
                <span style={{ fontSize: "11px" }}>
                  <Button size="small" color="error" onClick={() => handleDelete(method.id)}>Yes</Button>
                  <Button size="small" onClick={() => setConfirmingDelete(null)}>No</Button>
                </span>
              ) : (
                <IconButton size="small" onClick={() => setConfirmingDelete(method.id)}>
                  <DeleteIcon fontSize="small" />
                </IconButton>
              )}
            </div>
          </CardContent>
        </MethodCard>
      ))}

      {!showForm ? (
        <Button
          variant="outlined"
          onClick={() => setShowForm(true)}
          fullWidth
          style={{ marginTop: "10px" }}
        >
          Add New Method
        </Button>
      ) : (
        <AddForm>
          <Typography variant="subtitle2" style={{ marginBottom: "8px" }}>
            Add Payment Method
          </Typography>
          <FormControl fullWidth margin="normal" size="small">
            <InputLabel>Method Type</InputLabel>
            <Select
              value={formData.method_type}
              onChange={(e) =>
                setFormData({ method_type: e.target.value, details: {}, is_default: false })
              }
              label="Method Type"
            >
              {METHOD_TYPES.map((type) => (
                <MenuItem key={type.value} value={type.value}>
                  {type.label}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
          {renderDetailsFields()}
          <FormControlLabel
            control={
              <Checkbox
                checked={formData.is_default}
                onChange={(e) =>
                  setFormData({ ...formData, is_default: e.target.checked })
                }
                size="small"
              />
            }
            label="Set as default"
          />
          <div style={{ display: "flex", justifyContent: "space-between", marginTop: "10px" }}>
            <Button size="small" onClick={() => setShowForm(false)}>
              Cancel
            </Button>
            <Button size="small" variant="contained" onClick={handleAdd}>
              Save
            </Button>
          </div>
        </AddForm>
      )}
    </Container>
  );
}

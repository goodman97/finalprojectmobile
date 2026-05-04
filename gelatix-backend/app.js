require("dotenv").config();
const express = require("express");
const cors = require("cors");
const path = require("path");

const app = express();

app.use(cors());
app.use(express.json());
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// routes
app.use("/api/auth", require("./src/routes/authRoutes"));
app.use("/api/events", require("./src/routes/eventRoutes"));
app.use("/api/tickets", require("./src/routes/ticketRoutes"));
app.use("/api/market", require("./src/routes/marketRoutes"));
app.use("/api/minigame", require("./src/routes/minigameRoutes"));
app.use("/api/chat", require("./src/routes/chatRoutes"));
app.use("/api/admin", require("./src/routes/adminRoutes"));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
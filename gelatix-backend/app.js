require("dotenv").config();
const express = require("express");
const cors = require("cors");

const app = express();
const eventRoutes = require('./src/routes/eventRoutes');

app.use(cors());
app.use(express.json());

// routes
app.use("/api/auth", require("./src/routes/authRoutes"));
app.use("/uploads", require("express").static("uploads"));
app.use('/api/events', eventRoutes);
//app.use("/api/tickets", require("./src/routes/userTicketsRoutes"));
app.use("/api/market", require("./src/routes/marketRoutes"));
app.use("/api/minigame", require("./src/routes/minigameRoutes"));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

//ticket routes
const ticketRoutes = require('./src/routes/ticketRoutes');

app.use('/api/tickets', ticketRoutes);
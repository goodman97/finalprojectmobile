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

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
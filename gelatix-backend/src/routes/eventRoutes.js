const express = require("express");
const router = express.Router();
const eventController = require("../controllers/eventController");
const upload = require("../middleware/uploadMiddleware");
const authMiddleware = require("../middleware/authMiddleware");

// PUBLIC
router.get("/", eventController.getAllEvents);

// PRIVATE (CREATE EVENT)
router.post(
  "/create",
  authMiddleware,
  upload.single("image"),
  eventController.createEvent
);

module.exports = router;
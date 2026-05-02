const express = require("express");
const router = express.Router();
const eventController = require("../controllers/eventController");
const upload = require("../middleware/uploadMiddleware");
const authMiddleware = require("../middleware/authMiddleware");

// PUBLIC
router.get("/", eventController.getAllEvents);
router.get("/:id", eventController.getEventById);
router.get("/:id/ticket-types", eventController.getTicketTypes);

// PRIVATE (CREATE EVENT)
router.post(
  "/create",
  authMiddleware,
  upload.single("image"),
  eventController.createEvent
);

module.exports = router;
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
const router  = express.Router();
const eventController = require("../controllers/eventController");

router.get("/", eventController.getAllEvents);
router.get("/:id", eventController.getEventById);
router.get("/:id/ticket-types", eventController.getTicketTypes);


module.exports = router;

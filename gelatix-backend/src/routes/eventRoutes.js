const express = require("express");
const router  = express.Router();
const eventController = require("../controllers/eventController");

router.get("/", eventController.getAllEvents);
router.get("/:id", eventController.getEventById);
router.get("/:id/ticket-types", eventController.getTicketTypes);

module.exports = router;

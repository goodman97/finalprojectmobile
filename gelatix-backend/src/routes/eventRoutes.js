const express = require("express");
const router = express.Router();

const ctrl = require("../controllers/eventController");
const auth = require("../middleware/authMiddleware");
const role = require("../middleware/roleMiddleware");
const upload = require("../middleware/uploadMiddleware");

// EO PRIVATE ROUTES

// dashboard
router.get(
  "/eo/dashboard",
  auth,
  role(["organizer", "admin"]),
  ctrl.getEoDashboard
);

// my events
router.get(
  "/eo/my-events",
  auth,
  role(["organizer", "admin"]),
  ctrl.getMyEvents
);

// detail event eo
router.get(
  "/eo/:id",
  auth,
  role(["organizer", "admin"]),
  ctrl.getEoEventDetail
);

// create event
router.post(
  "/eo/create",
  auth,
  role(["organizer", "admin"]),
  upload.single("event_image"),
  ctrl.createEvent
);

// edit event
router.put(
  "/eo/:id/edit",
  auth,
  role(["organizer", "admin"]),
  upload.single("event_image"),
  ctrl.editEvent
);

// create ticket type
router.post(
  "/eo/:id/ticket-types",
  auth,
  role(["organizer", "admin"]),
  ctrl.createTicketType
);

router.put(
  "/eo/ticket-types/:ticketTypeId",
  auth,
  role(["organizer", "admin"]),
  ctrl.updateTicketType
);

// download report
router.get(
  "/eo/download-report",
  auth,
  role(["organizer", "admin"]),
  ctrl.downloadAnalyticsCSV
);

// validation
router.get(
  "/tickets/validation-stats", 
  auth, 
  ctrl.getValidationStats
);

// PUBLIC ROUTES

router.get("/", ctrl.getAllEvents);
router.get("/:id", ctrl.getEventById);
router.get("/:id/ticket-types", ctrl.getTicketTypes);

module.exports = router;
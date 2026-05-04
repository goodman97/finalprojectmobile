const express = require("express");
const router = express.Router();

const ctrl = require("../controllers/eventController");
const auth = require("../middleware/authMiddleware");
const role = require("../middleware/roleMiddleware");
const upload = require("../middleware/uploadMiddleware");


// ── EO / Organizer routes ─────────────────────────

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

// IMPORTANT:
// harus di atas /eo/:id
router.get(
  "/eo/download-report",
  auth,
  role(["organizer", "admin"]),
  ctrl.downloadAnalyticsCSV
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

// update ticket type
router.put(
  "/eo/ticket-types/:ticketTypeId",
  auth,
  role(["organizer", "admin"]),
  ctrl.updateTicketType
);

// detail event
// taruh paling bawah agar route spesifik di atas aman
router.get(
  "/eo/:id",
  auth,
  role(["organizer", "admin"]),
  ctrl.getEoEventDetail
);


// ── Admin routes ─────────────────────────

router.get(
  "/admin/all",
  auth,
  role(["admin"]),
  ctrl.adminGetAllEvents
);

router.patch(
  "/admin/:id/status",
  auth,
  role(["admin"]),
  ctrl.adminToggleStatus
);

router.delete(
  "/admin/:id",
  auth,
  role(["admin"]),
  ctrl.adminDeleteEvent
);


// ── Validation ─────────────────────────

router.get(
  "/tickets/validation-stats",
  auth,
  ctrl.getValidationStats
);


// ── Public routes ─────────────────────────

router.get("/", ctrl.getAllEvents);
router.get("/:id", ctrl.getEventById);
router.get("/:id/ticket-types", ctrl.getTicketTypes);

module.exports = router;
const express = require("express");
const router = express.Router();

const ctrl = require("../controllers/eventController");
const auth = require("../middleware/authMiddleware");
const role = require("../middleware/roleMiddleware");
const upload = require("../middleware/uploadMiddleware");

// ── EO / Organizer routes ─────────────────────────────────────────────────────

router.get(
  "/eo/dashboard",
  auth,
  role(["organizer", "admin"]),
  ctrl.getEoDashboard
);

router.get(
  "/eo/my-events",
  auth,
  role(["organizer", "admin"]),
  ctrl.getMyEvents
);

// download-report harus sebelum /eo/:id agar tidak tertangkap sebagai :id
router.get(
  "/eo/download-report",
  auth,
  role(["organizer", "admin"]),
  ctrl.downloadAnalyticsCSV
);

router.post(
  "/eo/create",
  auth,
  role(["organizer", "admin"]),
  upload.single("event_image"),
  ctrl.createEvent
);

router.put(
  "/eo/:id/edit",
  auth,
  role(["organizer", "admin"]),
  upload.single("event_image"),
  ctrl.editEvent
);

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

// /eo/:id harus paling bawah dari grup /eo agar tidak "menelan" route spesifik di atas
router.get(
  "/eo/:id",
  auth,
  role(["organizer", "admin"]),
  ctrl.getEoEventDetail
);


// ── Admin only ────────────────────────────────────────────────────────────────

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

// ── Public ────────────────────────────────────────────────────────────────────

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
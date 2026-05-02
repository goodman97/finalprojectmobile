const express = require("express");
const router = express.Router();
const ctrl = require("../controllers/eventController");
const auth = require("../middleware/authMiddleware");
const role = require("../middleware/roleMiddleware");
const upload = require("../middleware/uploadMiddleware");

router.get("/eo/dashboard", auth, role(["organizer","admin"]), ctrl.getEoDashboard);
router.get("/eo/my-events", auth, role(["organizer","admin"]), ctrl.getMyEvents);
router.get("/eo/download-report",auth,role(["organizer", "admin"]),ctrl.downloadAnalyticsCSV);
router.get("/eo/:id", auth, role(["organizer","admin"]), ctrl.getEoEventDetail);
router.post("/eo/create", auth, role(["organizer","admin"]), upload.single("event_image"), ctrl.createEvent);
router.put("/eo/:id/edit", auth, role(["organizer","admin"]), upload.single("event_image"), ctrl.editEvent);

router.get("/", ctrl.getAllEvents);
router.get("/:id", ctrl.getEventById);
router.get("/:id/ticket-types", ctrl.getTicketTypes);

module.exports = router;

const express = require("express");
const router = express.Router();
const ctrl = require("../controllers/eventController");
const auth = require("../middleware/authMiddleware");
const role = require("../middleware/roleMiddleware");
const upload = require("../middleware/uploadMiddleware");

<<<<<<< HEAD
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
=======
router.get ("/eo/dashboard", auth, role(["organizer","admin"]), ctrl.getEoDashboard);
router.get ("/eo/my-events", auth, role(["organizer","admin"]), ctrl.getMyEvents);
router.get ("/eo/:id", auth, role(["organizer","admin"]), ctrl.getEoEventDetail);
router.post("/eo/create", auth, role(["organizer","admin"]), upload.single("event_image"), ctrl.createEvent);
router.put ("/eo/:id/edit", auth, role(["organizer","admin"]), upload.single("event_image"), ctrl.editEvent);

router.get("/", ctrl.getAllEvents);
router.get("/:id", ctrl.getEventById);
router.get("/:id/ticket-types", ctrl.getTicketTypes);

module.exports = router;
>>>>>>> d18f6b2ec332fe09622106878c3fad4416d061cd

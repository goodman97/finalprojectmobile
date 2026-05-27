const express = require("express");
const router = express.Router();
const ticketController = require("../controllers/ticketController");
const auth = require("../middleware/authMiddleware");
const role = require("../middleware/roleMiddleware");

// Semua role bisa purchase, buy, transfer, dan lihat tiket sendiri
router.post("/purchase", auth, role(["user", "organizer", "admin"]), ticketController.purchaseTicket);

router.post("/buy", auth, role(["user", "organizer", "admin"]), ticketController.buyTicket);

router.post("/transfer", auth, role(["user", "organizer", "admin"]), ticketController.transferTicket);

router.get("/notifications/unread-count",auth,ticketController.getUnreadNotificationCount);

// Scan hanya untuk organizer (eo) dan admin
router.post("/scan", auth, role(["organizer", "eo", "admin"]), ticketController.scanTicket);

router.get("/mytickets", auth, role(["user", "organizer", "admin"]), ticketController.getMyTickets);

module.exports = router;
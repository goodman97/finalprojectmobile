const express = require("express");
const router  = express.Router();
const ticketController = require("../controllers/ticketController");
const auth = require("../middleware/authMiddleware");

router.post("/purchase", auth, ticketController.purchaseTicket);

router.post("/buy", auth, ticketController.buyTicket);
router.post("/transfer", auth, ticketController.transferTicket);
router.post("/scan", auth, ticketController.scanTicket);
router.get("/mytickets", auth, ticketController.getMyTickets);

module.exports = router;
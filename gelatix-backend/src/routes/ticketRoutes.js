const express = require("express");
const router = express.Router();
const ticketController = require("../controllers/ticketController");
const auth = require("../middleware/authMiddleware");
const role = require("../middleware/roleMiddleware");

router.post("/purchase", auth, role(["user"]), ticketController.purchaseTicket);

router.post("/buy", auth, role(["user"]), ticketController.buyTicket);

router.post("/transfer", auth, role(["user"]), ticketController.transferTicket);

router.post("/scan", auth, role(["eo", "admin"]), ticketController.scanTicket);

router.get("/mytickets", auth, role(["user"]), ticketController.getMyTickets);

module.exports = router;
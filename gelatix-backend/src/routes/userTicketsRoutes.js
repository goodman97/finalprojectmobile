const router = require("express").Router();
const ticketController = require("../controllers/userTicketsController");
const authMiddleware = require("../middleware/authMiddleware");

router.get("/mytickets", authMiddleware, ticketController.getMyTickets);

module.exports = router;
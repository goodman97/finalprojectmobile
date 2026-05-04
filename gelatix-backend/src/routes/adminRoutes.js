const express = require("express");
const router = express.Router();
const ctrl = require("../controllers/adminController");
const auth = require("../middleware/authMiddleware");
const role = require("../middleware/roleMiddleware");

router.get("/dashboard", auth, role(["admin"]), ctrl.getDashboard);
router.get("/transactions", auth, role(["admin"]), ctrl.getTransactions);
router.get("/users", auth, role(["admin"]), ctrl.getUsers);
router.patch("/users/:id/suspend", auth, role(["admin"]), ctrl.updateUserStatus);

module.exports = router;
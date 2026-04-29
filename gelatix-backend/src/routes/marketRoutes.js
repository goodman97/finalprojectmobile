const router = require("express").Router();
const marketController = require("../controllers/marketController");

router.get("/", marketController.getMarketEvents);

module.exports = router;
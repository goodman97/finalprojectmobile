const router = require("express").Router();
const minigameController = require("../controllers/minigameController");
const authMiddleware = require("../middleware/authMiddleware");

router.get("/", authMiddleware, minigameController.getGameData);
router.post("/spin", authMiddleware, minigameController.spin);

module.exports = router;
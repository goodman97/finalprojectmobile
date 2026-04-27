const pool = require("../config/db");
const router = require("express").Router();
const auth = require("../controllers/authController");
const authMiddleware = require("../middleware/authMiddleware");

router.post("/register", auth.register);
router.post("/login", auth.login);

router.get("/profile", authMiddleware, async (req, res) => {
  const user = await pool.query(
    "SELECT id, name, email, role, created_at FROM users WHERE id = $1",
    [req.user.id]
  );

  res.json(user.rows[0]);
});

module.exports = router;
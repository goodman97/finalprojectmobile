const jwt = require("jsonwebtoken");
const pool = require("../config/db");

module.exports = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    // 🔹 1. cek header ada & format benar
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ message: "Token tidak valid" });
    }

    const token = authHeader.split(" ")[1];

    // 🔹 2. verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // 🔹 3. ambil user dari DB
    const { rows } = await pool.query(
      "SELECT id, role FROM users WHERE id = $1",
      [decoded.id]
    );

    if (rows.length === 0) {
      return res.status(401).json({ message: "User tidak ditemukan" });
    }

    // 🔥 4. inject user ke request
    req.user = rows[0];

    next();
  } catch (err) {
    console.error("Auth error:", err.message);
    return res.status(401).json({ message: "Unauthorized" });
  }
};
const pool = require("../config/db");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

exports.register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // 1. Validasi
    if (!name || !email || !password) {
      return res.status(400).json({
        message: "Semua field wajib diisi",
      });
    }

    // 2. Cek email
    const checkUser = await pool.query(
      "SELECT id FROM users WHERE email = $1",
      [email]
    );

    if (checkUser.rows.length > 0) {
      return res.status(400).json({
        message: "Email sudah terdaftar",
      });
    }

    // 3. Hash password
    const hashed = await bcrypt.hash(password, 10);

    // 4. Insert (biarkan DB handle default field)
    const result = await pool.query(
      `INSERT INTO users (name, email, password)
       VALUES ($1, $2, $3)
       RETURNING id, name, email, role, created_at`,
      [name, email, hashed]
    );

    res.status(201).json({
      message: "Register berhasil",
      user: result.rows[0],
    });

  } catch (err) {
    console.error("REGISTER ERROR:", err);

    res.status(500).json({
      message: "Server error",
    });
  }
};

exports.login = async (req, res) => {
  const { email, password } = req.body;

  const user = await pool.query(
    "SELECT * FROM users WHERE email=$1",
    [email]
  );

  if (user.rows.length === 0) {
    return res.status(400).json({ message: "User not found" });
  }

  const valid = await bcrypt.compare(password, user.rows[0].password);

  if (!valid) {
    return res.status(400).json({ message: "Wrong password" });
  }

  const token = jwt.sign(
    { id: user.rows[0].id },
    process.env.JWT_SECRET
  );

  res.json({ token, user: user.rows[0] });
};
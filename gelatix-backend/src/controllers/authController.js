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

    // 4. Insert
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

exports.getProfile = async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT 
        id, 
        name, 
        email, 
        role, 
        telephone, 
        profile_image,
        TO_CHAR(created_at, 'DD Mon YYYY') AS created_at
      FROM users 
      WHERE id = $1`,
      [userId]
    );

    res.json(result.rows[0]);

  } catch (err) {
    console.error("GET PROFILE ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { name, email, telephone } = req.body;

    const userId = req.user.id;

    const result = await pool.query(
      `UPDATE users 
       SET name = $1, email = $2, telephone = $3
       WHERE id = $4
       RETURNING id, name, email, telephone`,
      [name, email, telephone, userId]
    );

    res.json({
      message: "Profile berhasil diupdate",
      user: result.rows[0],
    });

  } catch (err) {
    console.error("UPDATE PROFILE ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};

exports.changePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;

    const userId = req.user.id;

    const user = await pool.query(
      "SELECT password FROM users WHERE id = $1",
      [userId]
    );

    const valid = await bcrypt.compare(oldPassword, user.rows[0].password);

    if (!valid) {
      return res.status(400).json({ message: "Password lama salah" });
    }

    const hashed = await bcrypt.hash(newPassword, 10);

    await pool.query(
      "UPDATE users SET password = $1 WHERE id = $2",
      [hashed, userId]
    );

    res.json({ message: "Password berhasil diubah" });

  } catch (err) {
    console.error("CHANGE PASSWORD ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};

exports.uploadPhoto = async (req, res) => {
  try {
    const userId = req.user.id;

    const filePath = req.file.path;

    await pool.query(
      "UPDATE users SET profile_image = $1 WHERE id = $2",
      [filePath, userId]
    );

    res.json({
      message: "Foto berhasil diupload",
      photo: filePath,
    });

  } catch (err) {
    console.error("UPLOAD ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};
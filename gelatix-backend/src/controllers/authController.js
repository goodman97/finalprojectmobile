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

  // Check if user is suspended (using status column if exists, fallback to is_suspended)
  const status = user.rows[0].status || (user.rows[0].is_suspended ? 'suspended' : 'active');
  if (status === 'suspended') {
    return res.status(403).json({ message: "Akun Anda telah di-suspend. Hubungi admin untuk informasi lebih lanjut." });
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

    // profile user
    const userResult = await pool.query(
      `SELECT 
        id, 
        name, 
        email, 
        role, 
        telephone, 
        profile_image,
        biometric_enabled,
        TO_CHAR(created_at, 'DD Mon YYYY') AS created_at
      FROM users 
      WHERE id = $1`,
      [userId]
    );

    // total tickets bought
    const ticketResult = await pool.query(
      `
      SELECT COUNT(*) AS total_tickets
      FROM tickets
      WHERE user_id = $1
      `,
      [userId]
    );

    // total events attended
    const attendedResult = await pool.query(
      `
      SELECT COUNT(*) AS total_attended
      FROM tickets
      WHERE user_id = $1
      AND status = 'used'
      `,
      [userId]
    );

    res.json({
      id: userResult.rows[0].id,
      name: userResult.rows[0].name,
      email: userResult.rows[0].email,
      role: userResult.rows[0].role,
      telephone: userResult.rows[0].telephone,
      profile_image: userResult.rows[0].profile_image,
      biometric_enabled: userResult.rows[0].biometric_enabled,
      created_at: userResult.rows[0].created_at,

      total_tickets: ticketResult.rows[0].total_tickets,
      total_attended: attendedResult.rows[0].total_attended,
    });

  } catch (err) {
    console.error("GET PROFILE ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { name, email, telephone, timezone } = req.body;

    const userId = req.user.id;

    const result = await pool.query(
      `UPDATE users 
       SET name = $1, email = $2, telephone = $3, timezone = COALESCE($5, timezone)
       WHERE id = $4
       RETURNING id, name, email, telephone, timezone`,
      [name, email, telephone, userId, timezone || null]
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

exports.getNotifications = async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await pool.query(`
      SELECT *
      FROM notifications
      WHERE user_id = $1
      ORDER BY created_at DESC
    `, [userId]);

    res.json(result.rows);

  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: "Failed load notifications"
    });
  }
};

exports.readNotifications = async (req, res) => {
  try {
    const userId = req.user.id;

    await pool.query(
      `
      UPDATE notifications
      SET is_read = true
      WHERE user_id = $1
      `,
      [userId]
    );

    res.json({
      message: "Notifications marked as read"
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: "Server error"
    });
  }
};

exports.updateBiometric = async (req, res) => {
  try {
    const userId = req.user.id;
    const { enabled } = req.body;

    await pool.query(
      `
      UPDATE users
      SET biometric_enabled = $1
      WHERE id = $2
      `,
      [enabled, userId]
    );

    res.json({
      message: "Biometric updated successfully"
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: "Server error"
    });
  }
};

exports.biometricLogin = async (req, res) => {
  try {
    const user = await pool.query(
      `
      SELECT * FROM users
      WHERE biometric_enabled = true
      LIMIT 1
      `
    );

    if (user.rows.length === 0) {
      return res.status(400).json({
        message: "No biometric account found"
      });
    }

    const token = jwt.sign(
      { id: user.rows[0].id },
      process.env.JWT_SECRET
    );

    res.json({
      token,
      user: user.rows[0]
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({
      message: "Server error"
    });
  }
};
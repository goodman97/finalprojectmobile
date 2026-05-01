const db = require("../config/db");

// =======================
// GET ALL EVENTS (PUBLIC)
// =======================
exports.getAllEvents = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT 
        e.id,
        e.name,
        e.description,
        e.address,
        e.start_date,
        e.end_date,
        e.price,
        e.quota,
        e.event_image,
        e.created_at,
        u.name as organizer_name
      FROM events e
      LEFT JOIN users u ON e.organizer_id = u.id
      ORDER BY e.created_at DESC
    `);

    res.json(result.rows);

  } catch (err) {
    console.error("GET EVENTS ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};


// =======================
// CREATE EVENT (PRIVATE)
// =======================
exports.createEvent = async (req, res) => {
  try {
    console.log("BODY:", req.body);
    console.log("FILE:", req.file);

    // 🔥 ANTISIPASI req.body UNDEFINED
    const {
      name,
      description,
      address,
      start_date,
      end_date,
      price,
      quota,
    } = req.body || {};

    // 🔥 VALIDASI WAJIB
    if (!name || !address || !start_date || !end_date) {
      return res.status(400).json({
        message: "Field wajib belum lengkap (name, address, start_date, end_date)"
      });
    }

    // 🔥 AMBIL USER
    const organizer_id = req.user?.id;

    if (!organizer_id) {
      return res.status(401).json({ message: "Unauthorized" });
    }

    // 🔥 HANDLE IMAGE
    let imagePath = null;
    if (req.file) {
      imagePath = `uploads/events/${req.file.filename}`;
    }

    const result = await db.query(
      `INSERT INTO events 
      (name, description, address, start_date, end_date, price, quota, event_image, organizer_id)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
      RETURNING *`,
      [
        name,
        description,
        address,
        start_date,
        end_date,
        price,
        quota,
        imagePath,
        organizer_id,
      ]
    );

    res.json({
      message: "Event berhasil dibuat",
      event: result.rows[0],
    });

  } catch (err) {
    console.error("CREATE EVENT ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};
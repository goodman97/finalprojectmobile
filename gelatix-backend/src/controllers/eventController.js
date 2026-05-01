const db = require("../config/db");

// =======================
// GET ALL EVENTS (PUBLIC)
// =======================
exports.getAllEvents = async (req, res) => {
  try {
    const result = await db.query(`
      //iki sing tak tambahi
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
      //iki wekmu tin
      SELECT
        e.*,
        u.name AS organizer_name,
        COUNT(t.id) AS sold
      FROM events e
      LEFT JOIN users u ON e.organizer_id = u.id
      LEFT JOIN tickets t ON t.event_id = e.id
      WHERE e.status = 'active'
      GROUP BY e.id, u.name
      ORDER BY e.start_date ASC

    `);
    res.json(result.rows);
  } catch (err) {
    console.error("GET ALL EVENTS ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};

exports.getEventById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(`
      SELECT
        e.*,
        u.name AS organizer_name,
        COUNT(t.id) AS sold
      FROM events e
      LEFT JOIN users u ON e.organizer_id = u.id
      LEFT JOIN tickets t ON t.event_id = e.id
      WHERE e.id = $1
      GROUP BY e.id, u.name
    `, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Event not found" });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error("GET EVENT BY ID ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};

exports.getTicketTypes = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(`
      SELECT
        tt.id,
        tt.name,
        tt.price,
        tt.quota,
        tt.created_at,
        -- Remaining quota = quota - sold
        tt.quota - COUNT(t.id) AS available
      FROM ticket_types tt
      LEFT JOIN tickets t ON t.ticket_type_id = tt.id AND t.status != 'cancelled'
      WHERE tt.event_id = $1
      GROUP BY tt.id
      ORDER BY tt.price ASC
    `, [id]);

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

    console.error("GET TICKET TYPES ERROR:", err);

    res.status(500).json({ message: err.message });
  }
};

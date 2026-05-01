const db = require("../config/db");

exports.getAllEvents = async (req, res) => {
  try {
    const result = await db.query(`
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
    console.error("GET TICKET TYPES ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};

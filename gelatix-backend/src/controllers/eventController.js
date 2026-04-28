const db = require('../config/db');

exports.getAllEvents = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT e.*, u.name as organizer_name
      FROM events e
      JOIN users u ON e.organizer_id = u.id
      ORDER BY e.created_at DESC
    `);

    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
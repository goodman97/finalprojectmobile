const db = require("../config/db");

exports.getMyTickets = async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await db.query(`
      SELECT 
        t.id AS ticket_id,
        e.name AS event_name,
        e.start_date AS event_date,
        e.address AS location,
        e.event_image AS image,
        t.ticket_type_id AS ticket_type,
        t.status
      FROM transactions tr
      JOIN tickets t ON tr.ticket_id = t.id
      JOIN events e ON t.event_id = e.id
      WHERE tr.user_id = $1
      ORDER BY e.date ASC
    `, [userId]);

    const upcoming = [];
    const past = [];

    result.rows.forEach(item => {
      if (item.status === "active") {
        upcoming.push(item);
      } else {
        past.push(item);
      }
    });

    res.json({
      upcoming,
      past
    });

  } catch (err) {
    console.error("GET MY TICKETS ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};
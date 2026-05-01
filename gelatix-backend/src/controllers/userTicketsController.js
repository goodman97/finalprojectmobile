const db = require("../config/db");

//  GET /api/tickets/mytickets
exports.getMyTickets = async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await db.query(`
      SELECT
        t.id          AS ticket_id,
        t.qr_code,
        t.status,
        tt.name       AS ticket_type,
        tt.price,
        e.id          AS event_id,
        e.name        AS event_name,
        e.start_date  AS event_date,
        e.end_date,
        e.address     AS location,
        e.event_image AS image,
        e.description
      FROM tickets t
      JOIN ticket_types tt ON tt.id = t.ticket_type_id
      JOIN events e        ON e.id  = t.event_id
      WHERE t.current_owner_id = $1
      ORDER BY e.start_date ASC
    `, [userId]);

    const now      = new Date();
    const upcoming = [];
    const past     = [];

    result.rows.forEach(item => {
      const eventDate = item.event_date ? new Date(item.event_date) : null;
      if (item.status === "active" && eventDate && eventDate >= now) {
        upcoming.push(item);
      } else {
        past.push(item);
      }
    });

    res.json({ upcoming, past });

  } catch (err) {
    console.error("GET MY TICKETS ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};

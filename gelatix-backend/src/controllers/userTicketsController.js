const db = require("../config/db");

//  GET /api/tickets/mytickets
exports.getMyEvents = async (req, res) => {
  try {
    const organizerId = req.user.id;
    const q = req.query.q || "";

    const result = await db.query(`
      SELECT
        e.*,

        -- total tiket terjual per event
        (
          SELECT COUNT(*)
          FROM tickets t
          WHERE t.event_id = e.id
          AND t.status IN ('active', 'used', 'resale')
        ) AS sold,

        -- total revenue per event
        (
          SELECT COALESCE(SUM(tr.amount),0)
          FROM transactions tr
          JOIN tickets t ON t.id = tr.ticket_id
          WHERE t.event_id = e.id
          AND tr.status = 'success'
        ) AS revenue

      FROM events e
      WHERE e.organizer_id = $1
        AND LOWER(e.name) LIKE LOWER($2)

      ORDER BY e.created_at DESC
    `, [
      organizerId,
      `%${q}%`
    ]);

    res.json(result.rows);

  } catch (error) {
    console.log("GET MY EVENTS ERROR:", error);

    res.status(500).json({
      message: error.message
    });
  }
};
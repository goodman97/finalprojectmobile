const db = require("../config/db");

//  GET /api/market
exports.getMarketEvents = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT
        e.id,
        e.name,
        e.start_date   AS date,
        e.price,
        e.address,
        e.event_image  AS image,
        e.quota,
        e.status,
        e.description,
        e.latitude,
        e.longitude,
        u.name         AS organizer_name,
        COUNT(t.id)    AS sold
      FROM events e
      LEFT JOIN users u    ON e.organizer_id = u.id
      LEFT JOIN tickets t  ON t.event_id = e.id
      WHERE e.status = 'active'
      GROUP BY e.id, u.name
      ORDER BY e.start_date ASC
    `);

    res.json(result.rows);
  } catch (err) {
    console.error("MARKET ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};

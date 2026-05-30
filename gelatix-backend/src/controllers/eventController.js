const db = require("../config/db");
const path = require("path");

// ─── HELPER FUNCTIONS ─────────────────────────────────────────────────────
// Get user's timezone preference (default: 'Asia/Jakarta')
const getUserTimezone = async (userId) => {
  try {
    if (!userId) return 'Asia/Jakarta';

    const result = await db.query(
      "SELECT timezone FROM users WHERE id = $1 LIMIT 1",
      [userId]
    );

    return result.rows[0]?.timezone || 'Asia/Jakarta';
  } catch (err) {
    console.error("GET USER TIMEZONE ERROR:", err);
    return 'Asia/Jakarta';
  }
};

// GET /api/events/eo/dashboard
exports.getEoDashboard = async (req, res) => {
  try {
    const organizerId = req.user.id;

    const statsRes = await db.query(`
      SELECT
        COUNT(DISTINCT e.id) AS total_events,
        COUNT(t.id) AS total_sold,
        COALESCE(SUM(tr.amount), 0) AS total_revenue
      FROM events e
      LEFT JOIN tickets t 
        ON t.event_id = e.id 
        AND t.status IN ('active', 'used', 'resale')
      LEFT JOIN transactions tr
        ON tr.ticket_id = t.id 
        AND tr.status = 'success'
      WHERE e.organizer_id = $1
    `, [organizerId]);

    const upcomingRes = await db.query(`
      SELECT
        e.id,
        e.name,
        TO_CHAR(e.start_date,'YYYY-MM-DD"T"HH24:MI:SS') AS start_date,
        e.address,
        e.event_image,
        e.quota,
        e.price,
        COUNT(DISTINCT t.id) AS sold,
        COALESCE(SUM(DISTINCT tr.amount), 0) AS revenue,
        COALESCE(
          ROUND(
            (
              COUNT(DISTINCT t.id)::numeric / NULLIF(e.quota, 0)
            ) * 100,
            1
          ),
          0
        ) AS fill_percent
      FROM events e
      LEFT JOIN tickets t
        ON t.event_id = e.id
        AND t.status IN ('active', 'used', 'resale')
      LEFT JOIN transactions tr
        ON tr.ticket_id = t.id
        AND tr.status = 'success'
      WHERE e.organizer_id = $1
        AND e.status = 'active'
        AND e.start_date >= NOW()
      GROUP BY e.id
      ORDER BY sold DESC, e.start_date ASC
      LIMIT 3
    `, [organizerId]);

    const salesRes = await db.query(`
      SELECT
        e.name AS event_name,
        COUNT(t.id) AS ticket_count,
        SUM(tr.amount) AS amount,
        MAX(tr.created_at) AS last_sold
      FROM transactions tr
      JOIN tickets t ON t.id = tr.ticket_id
      JOIN events e ON e.id = t.event_id
      WHERE e.organizer_id = $1
        AND tr.status = 'success'
      GROUP BY e.id, e.name
      ORDER BY last_sold DESC
      LIMIT 5
    `, [organizerId]);

    res.json({
      stats: statsRes.rows[0],
      upcomingEvents: upcomingRes.rows,
      recentSales: salesRes.rows,
    });

  } catch (err) {
    console.error("EO DASHBOARD ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};

// GET /api/events/eo/my-events
exports.getMyEvents = async (req, res) => {
  try {
    const organizerId = req.user.id;
    const q = req.query.q || "";

    const result = await db.query(`
      SELECT
        e.id,
        e.name,
        e.genre,
        e.address,
        e.date,
        e.price,
        e.quota,
        e.description,
        e.organizer_id,
        e.status,
        e.event_image,
        e.latitude,
        e.longitude,
        e.created_at,

        TO_CHAR(
          e.start_date,
          'YYYY-MM-DD"T"HH24:MI:SS'
        ) AS start_date,

        TO_CHAR(
          e.end_date,
          'YYYY-MM-DD"T"HH24:MI:SS'
        ) AS end_date,

        (
          SELECT COUNT(*)
          FROM tickets t
          WHERE t.event_id = e.id
          AND t.status IN ('active', 'used', 'resale')
        ) AS sold,

        (
          SELECT COALESCE(SUM(tr.amount), 0)
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

// GET /api/events/eo/:id
exports.getEoEventDetail = async (req, res) => {
  try {
    const { id } = req.params;
    const organizerId = req.user.id;

    const result = await db.query(`
      SELECT
        e.id,
        e.name,
        e.genre,
        e.address,
        e.date,
        e.price,
        e.quota,
        e.description,
        e.organizer_id,
        e.status,
        e.event_image,
        e.latitude,
        e.longitude,
        e.created_at,
        TO_CHAR(e.start_date,'YYYY-MM-DD"T"HH24:MI:SS') AS start_date,
        TO_CHAR(e.end_date,'YYYY-MM-DD"T"HH24:MI:SS') AS end_date,
        u.name AS organizer_name,

        (
          SELECT COUNT(*)
          FROM tickets t
          WHERE t.event_id = e.id
          AND t.status IN ('active', 'used', 'resale')
        ) AS sold,

        (
          SELECT COALESCE(SUM(tr.amount), 0)
          FROM transactions tr
          JOIN tickets t ON t.id = tr.ticket_id
          WHERE t.event_id = e.id
          AND tr.status = 'success'
        ) AS revenue,

        (
          SELECT COALESCE(
            ROUND(
              (
                COUNT(*) FILTER (
                  WHERE t.status IN ('active', 'used', 'resale')
                )::numeric
                /
                NULLIF(e.quota, 0)
              ) * 100
            ),
            0
          )
          FROM tickets t
          WHERE t.event_id = e.id
        ) AS fill_percent

      FROM events e
      LEFT JOIN users u ON e.organizer_id = u.id

      WHERE e.id = $1
        AND e.organizer_id = $2

      GROUP BY e.id, u.name
    `, [id, organizerId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Event not found" });
    }

    const txRes = await db.query(`
      SELECT
        u.name AS buyer_name,
        tr.amount,
        tr.created_at
      FROM transactions tr
      JOIN tickets t ON t.id = tr.ticket_id
      JOIN users u ON u.id = tr.user_id
      WHERE t.event_id = $1
        AND tr.status = 'success'
      ORDER BY tr.created_at DESC
      LIMIT 10
    `, [id]);

    res.json({
      event: result.rows[0],
      transactions: txRes.rows,
    });

  } catch (err) {
    console.error("EO EVENT DETAIL ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};

// POST /api/events/eo/create
exports.createEvent = async (req, res) => {
  try {
    const organizerId = req.user.id;
    const userTz = await getUserTimezone(organizerId);

    // Ambil timezone user 
    const {
      name,
      genre,
      address,
      start_date,
      end_date,
      start_time,
      price,
      quota,
      description,
      latitude,
      longitude,
    } = req.body;

    if (!name || !genre || !address || !start_date || !price || !quota) {
      return res.status(400).json({ message: "Semua field wajib diisi" });
    }

    let startDateTime = start_time
      ? `${start_date} ${start_time}:00`
      : `${start_date} 00:00:00`;

    let endDateTime = end_date ? `${end_date} 00:00:00` : null;

    const imageName = req.file
      ? req.file.destination.replace(/^\/+/, '') + req.file.filename
      : null;

    const result = await db.query(`
      INSERT INTO events (
        name,
        genre,
        address,
        date,
        start_date,
        end_date,
        price,
        quota,
        description,
        organizer_id,
        status,
        event_image,
        latitude,
        longitude
      )
      VALUES (
        $1, $2, $3, $4,
        ($5::timestamp AT TIME ZONE $15),
        ($6::timestamp AT TIME ZONE $15),
        $7, $8, $9, $10, $11, $12, $13, $14
      )
      RETURNING *
    `, [
      name,
      genre,
      address,
      startDateTime,         // $3  — kolom date (legacy)
      startDateTime,         // $4  — start_date, dikonversi ke UTC
      endDateTime,           // $5  — end_date, dikonversi ke UTC
      price,
      quota,
      description || null,
      organizerId,
      "active",
      imageName,
      latitude || null,
      longitude || null,
      userTz,                // $14 — timezone user, misal 'Asia/Jakarta'
    ]);

    const newEvent = result.rows[0];

    await db.query(`
      INSERT INTO ticket_types (event_id, name, price, quota)
      VALUES ($1, 'General Admission', $2, $3)
    `, [newEvent.id, price, quota]);

    res.status(201).json({
      message: "Event berhasil dibuat",
      event: newEvent,
    });

  } catch (err) {
    console.error("CREATE EVENT ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};

// PUT /api/events/eo/:id/edit
exports.editEvent = async (req, res) => {
  try {
    const { id } = req.params;
    const organizerId = req.user.id;
    const userTz = await getUserTimezone(organizerId);

    // Ambil timezone user 

    const own = await db.query(
      "SELECT id, event_image FROM events WHERE id = $1 AND organizer_id = $2",
      [id, organizerId]
    );

    if (own.rows.length === 0) {
      return res.status(403).json({ message: "Tidak diizinkan" });
    }

    const {
      name,
      genre,
      address,
      start_date,
      end_date,
      start_time,
      price,
      quota,
      description,
      latitude,
      longitude,
      status,
    } = req.body;

    // ── Gabungkan tanggal + jam tanpa asumsi UTC ─────────────────────────────
    let startDateTime = null;
    if (start_date) {
      startDateTime = start_time
        ? `${start_date} ${start_time}:00`
        : `${start_date} 00:00:00`;
    }

    let endDateTime = end_date ? `${end_date} 00:00:00` : null;

    const imageName = req.file
      ? req.file.destination.replace(/^\/+/, '') + req.file.filename
      : own.rows[0].event_image;

    // ── UPDATE: konversi waktu lokal → UTC via AT TIME ZONE ─────────────────
    const result = await db.query(`
      UPDATE events SET
      name = COALESCE($1, name),
      genre = COALESCE($2, genre),
      address = COALESCE($3, address),
      start_date = COALESCE(($4::timestamp AT TIME ZONE $15), start_date),
      end_date = COALESCE(($5::timestamp AT TIME ZONE $15), end_date),
      price = COALESCE($6, price),
      quota = COALESCE($7, quota),
      description = COALESCE($8, description),
      event_image = $9,
      latitude = COALESCE($10, latitude),
      longitude = COALESCE($11, longitude),
      status = COALESCE($12, status)
    WHERE id = $13
      AND organizer_id = $14
    RETURNING *
    `, [
        name || null,      // $1
        genre || null,     // $2
        address || null,   // $3
        startDateTime,     // $4
        endDateTime,       // $5
        price || null,     // $6
        quota || null,     // $7
        description || null,// $8
        imageName,         // $9
        latitude || null,  // $10
        longitude || null, // $11
        status || null,    // $12
        id,                // $13
        organizerId,       // $14
        userTz,            // $15
      ]);

    res.json({
      message: "Event berhasil diupdate",
      event: result.rows[0],
    });

  } catch (err) {
    console.error("EDIT EVENT ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};

// GET /api/events
exports.getAllEvents = async (req, res) => {
  try {
    const tz = req.query.tz || 'Asia/Jakarta';

    const result = await db.query(`
      SELECT
        e.id,
        e.name,
        e.genre,
        e.address,
        e.date,
        e.price,
        e.quota,
        e.description,
        e.organizer_id,
        e.status,
        e.event_image,
        e.latitude,
        e.longitude,
        e.created_at,
        TO_CHAR(e.start_date,'YYYY-MM-DD"T"HH24:MI:SS') AS start_date,
        TO_CHAR(e.end_date,'YYYY-MM-DD"T"HH24:MI:SS') AS end_date,
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
    res.status(500).json({ message: err.message });
  }
};

// GET /api/events/:id
exports.getEventById = async (req, res) => {
  try {
    const { id } = req.params;
    const tz = req.query.tz || 'Asia/Jakarta';

    const result = await db.query(`
      SELECT
        e.id,
        e.name,
        e.genre,
        e.address,
        e.date,
        e.price,
        e.quota,
        e.description,
        e.organizer_id,
        e.status,
        e.event_image,
        e.latitude,
        e.longitude,
        e.created_at,
        TO_CHAR(e.start_date,'YYYY-MM-DD"T"HH24:MI:SS') AS start_date,
        TO_CHAR(e.end_date,'YYYY-MM-DD"T"HH24:MI:SS') AS end_date,
        u.name AS organizer_name,
        COUNT(t.id) AS sold
      FROM events e
      LEFT JOIN users u ON u.id = e.organizer_id
      LEFT JOIN tickets t ON t.event_id = e.id
      WHERE e.id = $1
      GROUP BY e.id, u.name
    `, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Not found" });
    }

    res.json(result.rows[0]);

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET /api/events/:id/ticket-types
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
        tt.quota - COUNT(t.id) AS available
      FROM ticket_types tt
      LEFT JOIN tickets t
        ON t.ticket_type_id = tt.id
        AND t.status = 'active'
      WHERE tt.event_id = $1
      GROUP BY tt.id
      ORDER BY tt.price ASC
    `, [id]);

    if (result.rows.length === 0) {
      const eventRes = await db.query(
        `SELECT id, price, quota FROM events WHERE id = $1`, [id]
      );

      if (eventRes.rows.length === 0) {
        return res.status(404).json({ message: "Event not found" });
      }

      const event = eventRes.rows[0];

      const inserted = await db.query(`
        INSERT INTO ticket_types (event_id, name, price, quota)
        VALUES ($1, 'General Admission', $2, $3)
        RETURNING id, name, price, quota, created_at,
                  quota AS available
      `, [event.id, event.price, event.quota]);

      return res.json(inserted.rows);
    }

    res.json(result.rows);

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.downloadAnalyticsCSV = async (req, res) => {
  try {
    const organizerId = req.user.id;

    console.log("DOWNLOAD CSV USER:", organizerId);

    const result = await db.query(`
      SELECT 
        e.name,
        e.start_date,
        e.address,
        e.price,
        e.quota,
        COUNT(t.id) AS tickets_sold,
        COALESCE(SUM(tr.amount),0) AS revenue
      FROM events e
      LEFT JOIN tickets t ON t.event_id = e.id
      LEFT JOIN transactions tr
        ON tr.ticket_id = t.id
        AND tr.status = 'success'
      WHERE e.organizer_id = $1
      GROUP BY e.id
    `, [organizerId]);

    console.log("CSV DATA:", result.rows);

    let csv = "Event Name,Start Date,Location,Price,Quota,Tickets Sold,Revenue\n";

    result.rows.forEach((row) => {
      csv += `"${row.name}","${row.start_date}","${row.address}",${row.price},${row.quota},${row.tickets_sold},${row.revenue}\n`;
    });

    res.setHeader("Content-Type", "text/csv");
    res.setHeader("Content-Disposition", "attachment; filename=analytics_report.csv");
    res.status(200).send(csv);

  } catch (err) {
    console.error("DOWNLOAD CSV ERROR:", err);

    res.status(500).json({
      message: err.message
    });
  }
};

// ── ADMIN ENDPOINTS ───────────────────────────────────────────────────────────

// GET /api/events/admin/all
exports.adminGetAllEvents = async (req, res) => {
  try {
    const q = req.query.q ? `%${req.query.q}%` : "%";
    const status = req.query.status;
    const tz = req.query.tz || 'Asia/Jakarta';

    const result = await db.query(`
      SELECT
        e.id,
        e.name,
        e.genre,
        TO_CHAR(e.start_date,'YYYY-MM-DD"T"HH24:MI:SS') AS start_date,
        e.address,
        e.status,
        e.price,
        e.quota,
        e.event_image,
        u.name AS organizer_name,
        COUNT(t.id) AS sold
      FROM events e
      LEFT JOIN users u ON u.id = e.organizer_id
      LEFT JOIN tickets t ON t.event_id = e.id AND t.status = 'active'
      WHERE
        (LOWER(e.name) LIKE LOWER($1) OR LOWER(e.address) LIKE LOWER($1))
        ${status ? "AND e.status = $2" : ""}
      GROUP BY e.id, u.name
      ORDER BY e.start_date DESC
    `, status ? [q, status] : [q]);

    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// PATCH /api/events/admin/:id/status
exports.adminToggleStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const result = await db.query(
      `UPDATE events SET status = $1 WHERE id = $2 RETURNING id, name, status`,
      [status, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Event not found" });
    }

    res.json({ message: "Status updated", event: result.rows[0] });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// DELETE /api/events/admin/:id
exports.adminDeleteEvent = async (req, res) => {
  try {
    const { id } = req.params;

    await db.query(`DELETE FROM events WHERE id = $1`, [id]);

    res.json({ message: "Event deleted" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// POST /api/events/eo/:id/ticket-types
exports.createTicketType = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, price, quota } = req.body;

    if (!name || !price || !quota) {
      return res.status(400).json({ message: "name, price, quota wajib diisi" });
    }

    const result = await db.query(`
      INSERT INTO ticket_types (event_id, name, price, quota)
      VALUES ($1, $2, $3, $4)
      RETURNING *
    `, [id, name, price, quota]);

    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// PUT /api/events/eo/ticket-types/:ticketTypeId
exports.updateTicketType = async (req, res) => {
  try {
    const { ticketTypeId } = req.params;
    const { name, price, quota } = req.body;

    const result = await db.query(`
      UPDATE ticket_types
      SET
        name  = COALESCE($1, name),
        price = COALESCE($2, price),
        quota = COALESCE($3, quota)
      WHERE id = $4
      RETURNING *
    `, [name || null, price || null, quota || null, ticketTypeId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Ticket type not found" });
    }

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET /api/tickets/validation-stats
exports.getValidationStats = async (req, res) => {
  try {
    const organizerId = req.user.id;

    const statsRes = await db.query(`
      SELECT
        COUNT(*) FILTER (
          WHERE t.updated_at::date = CURRENT_DATE
          AND t.status = 'used'
        ) AS today,

        COUNT(*) FILTER (
          WHERE t.updated_at >= NOW() - INTERVAL '7 days'
          AND t.status = 'used'
        ) AS this_week,

        COUNT(*) FILTER (
          WHERE t.status = 'used'
        ) AS total

      FROM tickets t
      JOIN events e ON e.id = t.event_id
      WHERE e.organizer_id = $1
    `, [organizerId]);

    const recentRes = await db.query(`
      SELECT
        t.id,
        t.qr_code,
        t.status,
        t.updated_at,
        e.name AS event_name,
        u.name AS holder_name
      FROM tickets t
      JOIN events e ON e.id = t.event_id
      LEFT JOIN users u ON u.id = t.current_owner_id
      WHERE e.organizer_id = $1
        AND t.status = 'used'
      ORDER BY t.updated_at DESC
      LIMIT 10
    `, [organizerId]);

    res.json({
      stats: statsRes.rows[0],
      recentValidations: recentRes.rows,
    });

  } catch (err) {
    console.error("VALIDATION STATS ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};
const db = require("../config/db");
const path = require("path");

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
        AND t.status = 'active'
      LEFT JOIN transactions tr
        ON tr.ticket_id = t.id 
        AND tr.status = 'success'
      WHERE e.organizer_id = $1
    `, [organizerId]);

    const upcomingRes = await db.query(`
      SELECT
        e.id,
        e.name,
        e.start_date,
        e.address,
        e.event_image,
        e.quota,
        e.price,
        COUNT(t.id) AS sold,
        COALESCE(SUM(tr.amount), 0) AS revenue,
        COALESCE(
          ROUND(COUNT(t.id)::numeric / NULLIF(e.quota,0) * 100),
          0
        ) AS fill_percent
      FROM events e
      LEFT JOIN tickets t
        ON t.event_id = e.id 
        AND t.status = 'active'
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
    const q = req.query.q ? `%${req.query.q}%` : "%";

    const result = await db.query(`
      SELECT
        e.id,
        e.name,
        e.start_date,
        e.end_date,
        e.address,
        e.price,
        e.quota,
        e.status,
        e.event_image,
        e.description,
        e.latitude,
        e.longitude,
        COUNT(t.id) AS sold,
        COALESCE(SUM(tr.amount), 0) AS revenue
      FROM events e
      LEFT JOIN tickets t
        ON t.event_id = e.id 
        AND t.status = 'active'
      LEFT JOIN transactions tr
        ON tr.ticket_id = t.id 
        AND tr.status = 'success'
      WHERE e.organizer_id = $1
        AND (
          LOWER(e.name) LIKE LOWER($2)
          OR LOWER(e.address) LIKE LOWER($2)
          OR TO_CHAR(e.start_date, 'DD/MM/YYYY') LIKE $2
          OR TO_CHAR(e.start_date, 'YYYY-MM-DD') LIKE $2
        )
      GROUP BY e.id
      ORDER BY e.start_date DESC
    `, [organizerId, q]);

    res.json(result.rows);

  } catch (err) {
    console.error("MY EVENTS ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};

// GET /api/events/eo/:id
exports.getEoEventDetail = async (req, res) => {
  try {
    const { id } = req.params;
    const organizerId = req.user.id;

    const result = await db.query(`
      SELECT
        e.*,
        u.name AS organizer_name,
        COUNT(t.id) AS sold,
        COALESCE(SUM(tr.amount), 0) AS revenue,
        COALESCE(
          ROUND(COUNT(t.id)::numeric / NULLIF(e.quota,0) * 100),
          0
        ) AS fill_percent
      FROM events e
      LEFT JOIN users u 
        ON e.organizer_id = u.id
      LEFT JOIN tickets t
        ON t.event_id = e.id 
        AND t.status = 'active'
      LEFT JOIN transactions tr
        ON tr.ticket_id = t.id 
        AND tr.status = 'success'
      WHERE e.id = $1 
        AND e.organizer_id = $2
      GROUP BY e.id, u.name
    `, [id, organizerId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Event not found"
      });
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

    const {
      name,
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

    if (!name || !address || !start_date || !price || !quota) {
      return res.status(400).json({
        message: "Semua field wajib diisi"
      });
    }

    let startDateTime = start_date;

    if (start_time) {
      startDateTime = `${start_date}T${start_time}:00`;
    }

    const imageName = req.file
      ? req.file.destination.replace(/^\/+/, '') + req.file.filename
      : null;

    const result = await db.query(`
      INSERT INTO events (
        name,
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
        $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13
      )
      RETURNING *
    `, [
      name,
      address,
      startDateTime,
      startDateTime,
      end_date || null,
      price,
      quota,
      description || null,
      organizerId,
      "active",
      imageName,
      latitude || null,
      longitude || null
    ]);

    const createdEvent = result.rows[0];

    await db.query(`
      INSERT INTO ticket_types (
        event_id,
        name,
        price,
        quota
      )
      VALUES ($1,$2,$3,$4)
    `, [
      createdEvent.id,
      "Regular Ticket",
      createdEvent.price,
      createdEvent.quota
    ]);

    res.status(201).json({
      message: "Event berhasil dibuat",
      event: newEvent
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

    const own = await db.query(
      "SELECT id, event_image FROM events WHERE id = $1 AND organizer_id = $2",
      [id, organizerId]
    );

    if (own.rows.length === 0) {
      return res.status(403).json({
        message: "Tidak diizinkan"
      });
    }

    const {
      name,
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

    let startDateTime = start_date;

    if (start_time) {
      startDateTime = `${start_date}T${start_time}:00`;
    }

    const imageName = req.file
      ? req.file.destination.replace(/^\/+/, '') + req.file.filename
      : own.rows[0].event_image;

    const result = await db.query(`
      UPDATE events SET
        name = COALESCE($1, name),
        address = COALESCE($2, address),
        start_date = COALESCE($3, start_date),
        end_date = COALESCE($4, end_date),
        price = COALESCE($5, price),
        quota = COALESCE($6, quota),
        description = COALESCE($7, description),
        event_image = $8,
        latitude = COALESCE($9, latitude),
        longitude = COALESCE($10, longitude),
        status = COALESCE($11, status)
      WHERE id = $12
        AND organizer_id = $13
      RETURNING *
    `, [
      name || null,
      address || null,
      startDateTime || null,
      end_date || null,
      price || null,
      quota || null,
      description || null,
      imageName,
      latitude || null,
      longitude || null,
      status || null,
      id,
      organizerId
    ]);

    res.json({
      message: "Event berhasil diupdate",
      event: result.rows[0]
    });

  } catch (err) {
    console.error("EDIT EVENT ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};

// GET /api/events
exports.getAllEvents = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT
        e.*,
        u.name AS organizer_name,
        COUNT(t.id) AS sold
      FROM events e
      LEFT JOIN users u
        ON e.organizer_id = u.id
      LEFT JOIN tickets t
        ON t.event_id = e.id
      WHERE e.status = 'active'
      GROUP BY e.id, u.name
      ORDER BY e.start_date ASC
    `);

    res.json(result.rows);

  } catch (err) {
    res.status(500).json({
      message: err.message
    });
  }
};

// GET /api/events/:id
exports.getEventById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(`
      SELECT
        e.*,
        u.name AS organizer_name,
        COUNT(t.id) AS sold
      FROM events e
      LEFT JOIN users u
        ON u.id = e.organizer_id
      LEFT JOIN tickets t
        ON t.event_id = e.id
      WHERE e.id = $1
      GROUP BY e.id, u.name
    `, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Not found"
      });
    }

    res.json(result.rows[0]);

  } catch (err) {
    res.status(500).json({
      message: err.message
    });
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

    // Jika ticket_types kosong, auto-generate dari data event
    if (result.rows.length === 0) {
      const eventRes = await db.query(
        `SELECT id, price, quota FROM events WHERE id = $1`, [id]
      );

      if (eventRes.rows.length === 0) {
        return res.status(404).json({ message: "Event not found" });
      }

      const event = eventRes.rows[0];

      // Insert ticket type default
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
    res.status(500).json({
      message: err.message
    });
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
      LEFT JOIN tickets t
        ON t.event_id = e.id
      LEFT JOIN transactions tr
        ON tr.ticket_id = t.id
        AND tr.status = 'success'
      WHERE e.organizer_id = $1
      GROUP BY e.id
    `, [organizerId]);

    console.log("CSV DATA:", result.rows);

    let csv =
      "Event Name,Start Date,Location,Price,Quota,Tickets Sold,Revenue\n";

    result.rows.forEach((row) => {
      csv += `"${row.name}","${row.start_date}",
      "${row.address}",${row.price},
      ${row.quota},${row.tickets_sold},
      ${row.revenue}\n`;
    });

    res.setHeader(
      "Content-Type",
      "text/csv"
    );

    res.setHeader(
      "Content-Disposition",
      "attachment; filename=analytics_report.csv"
    );

    res.status(200).send(csv);

  } catch (err) {
    console.error("CSV ERROR:", err);
    res.status(500).json({
      message: err.message
    });
  }
};

// POST /api/events/eo/:id/ticket-types
exports.createTicketType = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, price, quota } = req.body;

    if (!name || !price || !quota) {
      return res.status(400).json({
        message: "Semua field wajib diisi"
      });
    }

    const result = await db.query(`
      INSERT INTO ticket_types (
        event_id,
        name,
        price,
        quota
      )
      VALUES ($1,$2,$3,$4)
      RETURNING *
    `, [
      id,
      name,
      price,
      quota
    ]);

    res.status(201).json({
      message: "Ticket type berhasil dibuat",
      ticket: result.rows[0]
    });

  } catch (err) {
    console.error("CREATE TICKET TYPE ERROR:", err);

    res.status(500).json({
      message: err.message
    });
  }
};

exports.updateTicketType = async (req, res) => {
  try {
    const { ticketTypeId } = req.params;
    const { name, price, quota } = req.body;

    const result = await db.query(`
      UPDATE ticket_types
      SET
        name = COALESCE($1, name),
        price = COALESCE($2, price),
        quota = COALESCE($3, quota)
      WHERE id = $4
      RETURNING *
    `, [
      name || null,
      price || null,
      quota || null,
      ticketTypeId
    ]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "Ticket type not found"
      });
    }

    res.json({
      message: "Ticket type updated",
      ticket: result.rows[0]
    });

  } catch (err) {
    console.error(err);

    res.status(500).json({
      message: err.message
    });
  }
};
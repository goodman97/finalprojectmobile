const db = require("../config/db");

// GET /api/admin/dashboard
exports.getDashboard = async (req, res) => {
  try {
    // 🔥 FILTER RANGE (hanya untuk transaksi)
    const range = req.query.range || "all";

    let dateFilter = "";
    if (range === "1d") {
      dateFilter = "AND tr.created_at >= NOW() - INTERVAL '1 day'";
    } else if (range === "7d") {
      dateFilter = "AND tr.created_at >= NOW() - INTERVAL '7 days'";
    } else if (range === "1m") {
      dateFilter = "AND tr.created_at >= NOW() - INTERVAL '1 month'";
    } else if (range === "3m") {
      dateFilter = "AND tr.created_at >= NOW() - INTERVAL '3 months'";
    }

    // 🔥 STATS (TIDAK TERPENGARUH FILTER)
    const [usersRes, eventsRes, ticketsRes, revenueRes] = await Promise.all([
      db.query(`SELECT COUNT(*) AS total FROM users`),
      db.query(`SELECT COUNT(*) AS total FROM events WHERE status = 'active'`),
      db.query(`SELECT COUNT(*) AS total FROM tickets WHERE status IN ('active','used')`),
      db.query(`SELECT COALESCE(SUM(amount), 0) AS total FROM transactions WHERE status = 'success'`),
    ]);

    // 🔥 RECENT TRANSACTIONS (PAKAI FILTER)
    const txRes = await db.query(`
      SELECT
        tr.id,
        u.name  AS user_name,
        e.name  AS event_name,
        tr.amount,
        tr.status,
        tr.created_at
      FROM transactions tr
      JOIN users u  ON u.id  = tr.user_id
      JOIN tickets t ON t.id = tr.ticket_id
      JOIN events e  ON e.id = t.event_id
      WHERE 1=1 ${dateFilter}
      ORDER BY tr.created_at DESC
      LIMIT 10
    `);

    // 🔥 RECENT ACTIVITY (TETAP GLOBAL)
    const activityRes = await db.query(`
      SELECT
        u.name   AS user_name,
        'Purchased ticket' AS action,
        e.name   AS event_name,
        t.created_at AS time
      FROM tickets t
      JOIN users u  ON u.id = t.current_owner_id
      JOIN events e ON e.id = t.event_id
      ORDER BY t.created_at DESC
      LIMIT 10
    `);

    res.json({
      stats: {
        total_users:    parseInt(usersRes.rows[0].total),
        total_events:   parseInt(eventsRes.rows[0].total),
        tickets_sold:   parseInt(ticketsRes.rows[0].total),
        total_revenue:  parseFloat(revenueRes.rows[0].total),
      },
      recentTransactions: txRes.rows,
      recentActivity:     activityRes.rows,
    });

  } catch (err) {
    console.error("ADMIN DASHBOARD ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};

// GET /api/admin/transactions
exports.getTransactions = async (req, res) => {
  try {
    const { status, search } = req.query;

    let query = `
      SELECT
        tr.id,
        tr.id AS transaction_id,
        u.name  AS user_name,
        e.name  AS event_name,
        t.id    AS ticket_id,
        tr.amount,
        tr.status,
        tr.created_at
      FROM transactions tr
      JOIN users u  ON u.id  = tr.user_id
      JOIN tickets t ON t.id = tr.ticket_id
      JOIN events e  ON e.id = t.event_id
      WHERE 1=1
    `;

    const params = [];

    if (status && status !== 'all') {
      query += ` AND tr.status = $${params.length + 1}`;
      params.push(status);
    }

    if (search) {
      query += ` AND (LOWER(tr.id) LIKE LOWER($${params.length + 1}) OR LOWER(u.name) LIKE LOWER($${params.length + 2}))`;
      params.push(`%${search}%`, `%${search}%`);
    }

    query += ` ORDER BY tr.created_at DESC LIMIT 50`;

    const result = await db.query(query, params);

    res.json({
      success: true,
      data: result.rows.map(row => ({
        id: row.transaction_id,
        user: row.user_name,
        event: row.event_name,
        ticketId: row.ticket_id,
        amount: parseFloat(row.amount),
        status: row.status,
        time: new Date(row.created_at).toLocaleString(),
      })),
    });

  } catch (err) {
    console.error("GET TRANSACTIONS ERROR:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

// GET /api/admin/users
exports.getUsers = async (req, res) => {
  try {
    const q = req.query.q ? `%${req.query.q}%` : "%";

    const result = await db.query(`
      SELECT
        u.id,
        u.name,
        u.email,
        u.role,
        u.is_suspended,
        CASE 
          WHEN u.is_suspended THEN 'suspended' 
          ELSE 'active' 
        END AS status,
        u.created_at,
        COUNT(DISTINCT t.id)  AS tickets_owned,
        COUNT(DISTINCT e.id)  AS events_created
      FROM users u
      LEFT JOIN tickets t ON t.current_owner_id = u.id
      LEFT JOIN events  e ON e.organizer_id = u.id
      WHERE LOWER(u.name)  LIKE LOWER($1)
         OR LOWER(u.email) LIKE LOWER($1)
      GROUP BY u.id
      ORDER BY u.created_at DESC
    `, [q]);

    res.json(result.rows);

  } catch (err) {
    console.error("GET USERS ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};

// PATCH /api/admin/users/:id/suspend
exports.updateUserStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { suspend } = req.body;

    if (typeof suspend !== "boolean") {
      return res.status(400).json({ message: "Format suspend tidak valid" });
    }

    const result = await db.query(`
      UPDATE users 
      SET is_suspended = $1 
      WHERE id = $2 
      RETURNING id, name, is_suspended
    `, [suspend, id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User tidak ditemukan" });
    }

    res.json({
      success: true,
      message: suspend ? "User berhasil di-suspend" : "User berhasil diaktifkan",
      user: result.rows[0],
    });

  } catch (err) {
    console.error("UPDATE STATUS ERROR:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};
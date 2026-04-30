const pool = require("../config/db");

//
// 🎫 BUY TICKET
//
exports.buyTicket = async (req, res) => {
  try {
    const { ticketTypeId, price } = req.body;
    const userId = req.user.id;

    const qr = "QR-" + Date.now();

    const result = await pool.query(
      `SELECT buy_ticket($1, $2, $3, $4) AS ticket_id`,
      [userId, ticketTypeId, qr, price]
    );

    res.json({
      message: "Berhasil beli tiket",
      ticketId: result.rows[0].ticket_id,
      qr,
    });
  } catch (err) {
    console.error("BUY ERROR:", err);
    res.status(400).json({ error: err.message });
  }
};

//
// 🔄 TRANSFER TICKET
//
exports.transferTicket = async (req, res) => {
  try {
    const { ticketId, toUser } = req.body;
    const fromUser = req.user.id;

    await pool.query(
      `SELECT transfer_ticket($1, $2, $3)`,
      [ticketId, fromUser, toUser]
    );

    res.json({ message: "Transfer berhasil" });
  } catch (err) {
    console.error("TRANSFER ERROR:", err);
    res.status(400).json({ error: err.message });
  }
};

//
// 📷 SCAN TICKET (VALIDASI REAL)
//
exports.scanTicket = async (req, res) => {
  try {
    const { qr } = req.body;

    if (!qr) {
      return res
        .status(400)
        .json({ status: "error", message: "QR is required" });
    }

    const result = await pool.query(
      `SELECT t.*, u.name, u.email
       FROM tickets t
       LEFT JOIN users u ON u.id = t.current_owner_id
       WHERE t.qr_code = $1`,
      [qr]
    );

    // ❌ tidak ditemukan
    if (result.rows.length === 0) {
      return res.json({ status: "invalid" });
    }

    const ticket = result.rows[0];

    // ❌ sudah digunakan
    if (ticket.status === "used") {
      return res.json({
        status: "already_used",
        ticket,
      });
    }

    // ✅ VALID → update jadi used
    await pool.query(
      `UPDATE tickets SET status = 'used' WHERE qr_code = $1`,
      [qr]
    );

    // 🔥 insert history
    await pool.query(
      `INSERT INTO ticket_history (ticket_id, owner_id, transfer_type)
       VALUES ($1, $2, 'scan')`,
      [ticket.id, ticket.current_owner_id]
    );

    return res.json({
      status: "valid",
      ticket,
    });
  } catch (err) {
    console.error("SCAN ERROR:", err);
    res.status(500).json({ status: "error", message: "Server error" });
  }
};

//
// 🎟️ GET MY TICKETS
//
exports.getMyTickets = async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT 
        t.id,
        t.qr_code,
        t.status,
        tt.name AS ticket_type,
        e.name AS event_name
       FROM tickets t
       JOIN ticket_types tt ON tt.id = t.ticket_type_id
       JOIN events e ON e.id = tt.event_id
       WHERE t.current_owner_id = $1
       ORDER BY t.created_at DESC`,
      [userId]
    );

    res.json(result.rows);
  } catch (err) {
    console.error("GET TICKETS ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};
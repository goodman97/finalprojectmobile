const pool = require("../config/db");

//  POST /api/tickets/purchase
exports.purchaseTicket = async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const userId = req.user.id;
    const {
      ticket_type_id,
      quantity = 1,
      voucher_id,
      points_used = 0,
    } = req.body;

    if (!ticket_type_id) {
      return res.status(400).json({ message: "ticket_type_id is required" });
    }
    if (quantity < 1 || quantity > 10) {
      return res.status(400).json({ message: "Quantity must be between 1 and 10" });
    }

    // 1. Get ticket type + price
    const ttRes = await client.query(
      `SELECT tt.*, e.name AS event_name, e.id AS event_id
       FROM ticket_types tt
       JOIN events e ON e.id = tt.event_id
       WHERE tt.id = $1`,
      [ticket_type_id]
    );
    if (ttRes.rows.length === 0) {
      await client.query("ROLLBACK");
      return res.status(404).json({ message: "Ticket type not found" });
    }
    const ticketType = ttRes.rows[0];

    // 2. Check availability
    const soldRes = await client.query(
      `SELECT COUNT(*) FROM tickets
       WHERE ticket_type_id = $1 AND status != 'cancelled'`,
      [ticket_type_id]
    );
    const sold = parseInt(soldRes.rows[0].count);
    const available = ticketType.quota - sold;

    if (available < quantity) {
      await client.query("ROLLBACK");
      return res.status(400).json({
        message: `Only ${available} ticket(s) left`,
      });
    }

    let userPoints = 0;

    const pointRes = await client.query(
      `SELECT total_points
      FROM game_users
      WHERE user_id = $1`,
      [userId]
    );

    if (pointRes.rows.length > 0) {
      userPoints = parseInt(pointRes.rows[0].total_points);
    }

    if (points_used < 0) {
      await client.query("ROLLBACK");
      return res.status(400).json({
        message: "Invalid points usage",
      });
    }

    if (points_used > userPoints) {
      await client.query("ROLLBACK");
      return res.status(400).json({
        message: "Poin kamu tidak mencukupi",
      });
    }

    // 3. Apply voucher discount
    let discountPercent = 0;
    if (voucher_id) {
      const vRes = await client.query(
        `SELECT * FROM user_rewards
         WHERE id = $1 AND user_id = $2 AND used = false AND type = 'discount'`,
        [voucher_id, userId]
      );
      if (vRes.rows.length > 0) {
        discountPercent = vRes.rows[0].value;
        // Mark voucher as used
        await client.query(
          "UPDATE user_rewards SET used = true WHERE id = $1",
          [voucher_id]
        );
      }
    }

    const basePrice = parseFloat(ticketType.price);

    // voucher discount
    const voucherDiscount = (basePrice * discountPercent) / 100;
    const afterVoucherPrice = basePrice - voucherDiscount;

    // total sebelum poin
    const subtotal = afterVoucherPrice * quantity;

    // points = nominal reduction
    let pointsDiscount = points_used;

    // prevent minus
    if (pointsDiscount > subtotal) {
      pointsDiscount = subtotal;
    }

    const serviceFee = 5;
    const totalAmount = (subtotal - pointsDiscount) + serviceFee;

    const pricePerUnit = afterVoucherPrice;

    // 4. Create tickets + transactions
    const createdTickets = [];
    for (let i = 0; i < quantity; i++) {
      const qrCode = `QR-${Date.now()}-${Math.random().toString(36).slice(2, 8).toUpperCase()}`;

      const ticketRes = await client.query(
        `INSERT INTO tickets
           (event_id, ticket_type_id, current_owner_id, user_id, qr_code, status)
         VALUES ($1, $2, $3, $3, $4, 'active')
         RETURNING id`,
        [ticketType.event_id, ticket_type_id, userId, qrCode]
      );
      const ticketId = ticketRes.rows[0].id;

      await client.query(
        `INSERT INTO transactions
           (user_id, ticket_id, amount, status)
         VALUES ($1, $2, $3, 'completed')`,
        [userId, ticketId, pricePerUnit + (i === 0 ? serviceFee : 0)]
      );

      // Ticket history
      await client.query(
        `INSERT INTO ticket_history (ticket_id, owner_id, transfer_type)
         VALUES ($1, $2, 'purchase')`,
        [ticketId, userId]
      );

      createdTickets.push({ ticketId, qrCode });
    }

    if (points_used > 0) {
      await client.query(
        `UPDATE game_users
        SET total_points = total_points - $1
        WHERE user_id = $2`,
        [points_used, userId]
      );
    }

    await client.query("COMMIT");

    res.status(201).json({
      message: "Purchase successful",
      eventName: ticketType.event_name,
      ticketTypeName: ticketType.name,
      quantity,
      discountPercent,
      pointsUsed: points_used,
      pricePerUnit,
      totalAmount,
      tickets: createdTickets,
    });

  } catch (err) {
    await client.query("ROLLBACK");
    console.error("PURCHASE ERROR:", err);
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
  }
};

//  POST /api/tickets/buy
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
      message:  "Berhasil beli tiket",
      ticketId: result.rows[0].ticket_id,
      qr,
    });
  } catch (err) {
    console.error("BUY ERROR:", err);
    res.status(400).json({ error: err.message });
  }
};

//  POST /api/tickets/transfer
exports.transferTicket = async (req, res) => {
  try {
    const { ticketId, toUser } = req.body;
    const fromUser             = req.user.id;

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

//  POST /api/tickets/scan
exports.scanTicket = async (req, res) => {
  try {
    const { qr } = req.body;

    if (!qr) {
      return res.status(400).json({ status: "error", message: "QR is required" });
    }

    const result = await pool.query(
      `SELECT t.*, u.name, u.email
       FROM tickets t
       LEFT JOIN users u ON u.id = t.current_owner_id
       WHERE t.qr_code = $1`,
      [qr]
    );

    if (result.rows.length === 0) {
      return res.json({ status: "invalid" });
    }

    const ticket = result.rows[0];

    if (ticket.status === "used") {
      return res.json({ status: "already_used", ticket });
    }

    await pool.query(
      "UPDATE tickets SET status = 'used' WHERE qr_code = $1",
      [qr]
    );

    await pool.query(
      `INSERT INTO ticket_history (ticket_id, owner_id, transfer_type)
       VALUES ($1, $2, 'scan')`,
      [ticket.id, ticket.current_owner_id]
    );

    return res.json({ status: "valid", ticket });
  } catch (err) {
    console.error("SCAN ERROR:", err);
    res.status(500).json({ status: "error", message: "Server error" });
  }
};

//  GET /api/tickets/mytickets
exports.getMyTickets = async (req, res) => {
  try {
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT
         t.id AS ticket_id,
         t.qr_code,
         t.status,
         tt.name AS ticket_type,
         e.name  AS event_name,
         e.start_date AS event_date,
         e.address AS location,
         e.event_image AS image
       FROM tickets t
       JOIN ticket_types tt ON tt.id = t.ticket_type_id
       JOIN events e ON e.id = t.event_id
       WHERE t.current_owner_id = $1
       ORDER BY e.start_date ASC`,
      [userId]
    );

    const upcoming = [];
    const past     = [];

    result.rows.forEach(item => {
      if (item.status === "active") upcoming.push(item);
      else past.push(item);
    });

    res.json({ upcoming, past });
  } catch (err) {
    console.error("GET MY TICKETS ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};

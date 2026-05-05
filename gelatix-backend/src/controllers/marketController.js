const db = require("../config/db");

// GET /api/market — daftar tiket resale yang available
exports.getResaleListings = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT
        rm.id            AS listing_id,
        rm.price         AS resale_price,
        rm.created_at,
        t.id             AS ticket_id,
        t.qr_code,
        COALESCE(tt.name, 'General Admission') AS ticket_type,
        COALESCE(tt.price, 0)                  AS original_price,
        e.id             AS event_id,
        e.name           AS event_name,
        e.start_date,
        e.address,
        e.description,
        CASE
          WHEN e.event_image IS NULL THEN NULL
          WHEN e.event_image LIKE 'http%'      THEN e.event_image
          WHEN e.event_image LIKE 'uploads/%'  THEN '/' || e.event_image
          WHEN e.event_image LIKE '/uploads/%' THEN e.event_image
          ELSE '/uploads/events/' || e.event_image
        END AS image,
        e.latitude,
        e.longitude,
        u.id             AS seller_id,
        u.name           AS seller_name
      FROM resale_market rm
      JOIN tickets      t  ON t.id        = rm.ticket_id
      LEFT JOIN ticket_types tt ON tt.id  = t.ticket_type_id
      JOIN events       e  ON e.id        = t.event_id
      JOIN users        u  ON u.id        = rm.seller_id
      WHERE rm.status = 'available'
        AND e.status  = 'active'
      ORDER BY rm.created_at DESC
    `);

    res.json(result.rows);
  } catch (err) {
    console.error("GET RESALE ERROR:", err);
    res.status(500).json({ message: err.message });
  }
};

// POST /api/market/list — user jual tiketnya
// Body: { ticket_id, price }
exports.listTicketForSale = async (req, res) => {
  const client = await db.connect();
  try {
    const sellerId = req.user.id;
    const { ticket_id, price } = req.body;

    if (!ticket_id || !price) {
      return res.status(400).json({ message: "ticket_id dan price wajib diisi" });
    }

    // Validasi tiket milik seller dan masih active
    const ticketRes = await client.query(
      `SELECT t.id, t.current_owner_id, t.status,
              COALESCE(tt.price, 0) AS original_price
       FROM tickets t
       LEFT JOIN ticket_types tt ON tt.id = t.ticket_type_id
       WHERE t.id = $1`,
      [ticket_id]
    );

    if (ticketRes.rows.length === 0) {
      return res.status(404).json({ message: "Tiket tidak ditemukan" });
    }

    const ticket = ticketRes.rows[0];

    if (ticket.current_owner_id !== sellerId) {
      return res.status(403).json({ message: "Bukan tiket milik kamu" });
    }

    if (ticket.status !== "active") {
      return res.status(400).json({ message: "Tiket tidak bisa dijual (status bukan active)" });
    }

    // Harga jual HARUS lebih tinggi dari harga beli
    const originalPrice = parseFloat(ticket.original_price);
    const resalePrice   = parseFloat(price);

    if (resalePrice <= originalPrice) {
      return res.status(400).json({
        message: `Harga jual harus lebih dari harga beli (Rp ${originalPrice.toLocaleString('id-ID')})`
      });
    }

    // Cek apakah tiket sudah listed
    const existingRes = await client.query(
      `SELECT id FROM resale_market WHERE ticket_id = $1 AND status = 'available'`,
      [ticket_id]
    );

    if (existingRes.rows.length > 0) {
      return res.status(400).json({ message: "Tiket sudah dalam daftar jual" });
    }

    await client.query("BEGIN");

    // Insert ke resale_market
    const listing = await client.query(
      `INSERT INTO resale_market (ticket_id, seller_id, price)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [ticket_id, sellerId, resalePrice]
    );

    // Update status tiket jadi resale
    await client.query(
      `UPDATE tickets SET status = 'resale' WHERE id = $1`,
      [ticket_id]
    );

    await client.query("COMMIT");

    res.status(201).json({
      message: "Tiket berhasil didaftarkan untuk dijual",
      listing: listing.rows[0],
    });

  } catch (err) {
    await client.query("ROLLBACK");
    console.error("LIST TICKET ERROR:", err);
    res.status(500).json({ message: err.message });
  } finally {
    client.release();
  }
};

// POST /api/market/:listingId/buy — user beli tiket resale
exports.buyResaleTicket = async (req, res) => {
  const client = await db.connect();
  try {
    const buyerId   = req.user.id;
    const { listingId } = req.params;

    // Ambil data listing
    const listingRes = await client.query(
      `SELECT rm.*, t.current_owner_id, tt.price AS original_price
       FROM resale_market rm
       JOIN tickets      t  ON t.id  = rm.ticket_id
       JOIN ticket_types tt ON tt.id = t.ticket_type_id
       WHERE rm.id = $1 AND rm.status = 'available'`,
      [listingId]
    );

    if (listingRes.rows.length === 0) {
      return res.status(404).json({ message: "Listing tidak tersedia" });
    }

    const listing = listingRes.rows[0];

    if (listing.seller_id === buyerId) {
      return res.status(400).json({ message: "Tidak bisa membeli tiket sendiri" });
    }

    await client.query("BEGIN");

    // Update kepemilikan tiket ke buyer
    await client.query(
      `UPDATE tickets
       SET current_owner_id = $1, status = 'active', updated_at = NOW()
       WHERE id = $2`,
      [buyerId, listing.ticket_id]
    );

    // Tandai listing sebagai sold
    await client.query(
      `UPDATE resale_market SET status = 'sold' WHERE id = $1`,
      [listingId]
    );

    // Catat transaksi
    await client.query(
      `INSERT INTO transactions (user_id, ticket_id, amount, status)
       VALUES ($1, $2, $3, 'success')`,
      [buyerId, listing.ticket_id, listing.price]
    );

    // Catat di ticket_history (transfer resale)
    await client.query(
      `INSERT INTO ticket_history (ticket_id, owner_id, transfer_type)
       VALUES ($1, $2, 'resale')`,
      [listing.ticket_id, buyerId]
    );

    await client.query("COMMIT");

    res.json({ message: "Tiket berhasil dibeli", ticket_id: listing.ticket_id });

  } catch (err) {
    await client.query("ROLLBACK");
    console.error("BUY RESALE ERROR:", err);
    res.status(500).json({ message: err.message });
  } finally {
    client.release();
  }
};

// DELETE /api/market/:listingId/cancel — seller batalkan listing
exports.cancelListing = async (req, res) => {
  const client = await db.connect();
  try {
    const sellerId    = req.user.id;
    const { listingId } = req.params;

    const listingRes = await client.query(
      `SELECT * FROM resale_market WHERE id = $1 AND status = 'available'`,
      [listingId]
    );

    if (listingRes.rows.length === 0) {
      return res.status(404).json({ message: "Listing tidak ditemukan" });
    }

    const listing = listingRes.rows[0];

    if (listing.seller_id !== sellerId) {
      return res.status(403).json({ message: "Bukan listing milik kamu" });
    }

    await client.query("BEGIN");

    await client.query(
      `UPDATE resale_market SET status = 'cancelled' WHERE id = $1`,
      [listingId]
    );

    await client.query(
      `UPDATE tickets SET status = 'active' WHERE id = $1`,
      [listing.ticket_id]
    );

    await client.query("COMMIT");

    res.json({ message: "Listing berhasil dibatalkan" });

  } catch (err) {
    await client.query("ROLLBACK");
    res.status(500).json({ message: err.message });
  } finally {
    client.release();
  }
};

// GET /api/market/my-listings — tiket yang sedang dijual oleh user
exports.getMyListings = async (req, res) => {
  try {
    const sellerId = req.user.id;

    const result = await db.query(`
      SELECT
        rm.id            AS listing_id,
        rm.price         AS resale_price,
        rm.status        AS listing_status,
        rm.created_at,
        tt.price         AS original_price,
        tt.name          AS ticket_type,
        e.name           AS event_name,
        e.start_date,
        e.address,
        e.event_image    AS image
      FROM resale_market rm
      JOIN tickets      t  ON t.id  = rm.ticket_id
      JOIN ticket_types tt ON tt.id = t.ticket_type_id
      JOIN events       e  ON e.id  = t.event_id
      WHERE rm.seller_id = $1
      ORDER BY rm.created_at DESC
    `, [sellerId]);

    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
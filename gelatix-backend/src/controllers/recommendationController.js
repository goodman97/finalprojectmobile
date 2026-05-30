const db   = require('../config/db');
const http = require('http');

const ML_HOST = process.env.ML_HOST || 'localhost';
const ML_PORT = process.env.ML_PORT || 5001;

/**
 * Panggil Python ML service
 */
function callMlService(userId) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify({ user_id: userId });

    const options = {
      hostname: ML_HOST,
      port    : ML_PORT,
      path    : '/recommend',
      method  : 'POST',
      headers : {
        'Content-Type'  : 'application/json',
        'Content-Length': Buffer.byteLength(body),
      },
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve(JSON.parse(data)); }
        catch (e) { reject(new Error('ML service parse error')); }
      });
    });

    req.on('error', reject);
    req.setTimeout(5000, () => {
      req.destroy();
      reject(new Error('ML service timeout'));
    });

    req.write(body);
    req.end();
  });
}

// GET /api/recommendations
exports.getRecommendations = async (req, res) => {
  try {
    const userId = req.user.id;

    // Panggil ML service
    let mlResult;
    let source = 'popularity';

    try {
      mlResult = await callMlService(userId);
      source   = mlResult.source || 'content_based';
    } catch (mlErr) {
      console.warn('ML service unavailable, fallback to popularity:', mlErr.message);
      mlResult = null;
    }

    let eventIds = mlResult?.recommended_ids || [];

    // Fallback: kalau ML service mati atau hasilnya kosong → ambil event populer
    if (eventIds.length === 0) {
      source = 'popularity_fallback';
      const fallback = await db.query(`
        SELECT e.id::text
        FROM events e
        LEFT JOIN tickets t ON t.event_id = e.id AND t.status IN ('active','used','resale')
        WHERE e.status = 'active'
          AND e.id NOT IN (
            SELECT DISTINCT t2.event_id
            FROM tickets t2
            JOIN transactions tr ON tr.ticket_id = t2.id
            WHERE t2.user_id = $1 AND tr.status = 'success'
          )
        GROUP BY e.id
        ORDER BY COUNT(t.id) DESC
        LIMIT 10
      `, [userId]);

      eventIds = fallback.rows.map(r => r.id);
    }

    if (eventIds.length === 0) {
      return res.json({ source, events: [] });
    }

    // Fetch detail event berdasarkan ID yang direkomendasikan
    // Pertahankan urutan dari ML (ORDER BY ARRAY POSITION)
    const placeholders = eventIds.map((_, i) => `$${i + 1}`).join(',');
    const result = await db.query(`
      SELECT
        e.id,
        e.name,
        e.genre,
        e.address,
        e.price,
        e.quota,
        e.event_image,
        e.status,
        e.latitude,
        e.longitude,
        e.start_date,
        e.end_date,
        u.name AS organizer_name,
        COUNT(t.id) AS sold
      FROM events e
      LEFT JOIN users u  ON u.id  = e.organizer_id
      LEFT JOIN tickets t ON t.event_id = e.id AND t.status IN ('active','used','resale')
      WHERE e.id::text IN (${placeholders})
        AND e.status = 'active'
      GROUP BY e.id, u.name
    `, eventIds);

    // Urutkan sesuai rekomendasi ML
    const eventMap = {};
    result.rows.forEach(e => { eventMap[e.id] = e; });
    const ordered = eventIds
      .map(id => eventMap[id])
      .filter(Boolean);

    console.log("RECOMMEND SOURCE:", source);

    res.json({ source, events: ordered });

  } catch (err) {
    console.error('RECOMMENDATION ERROR:', err);
    res.status(500).json({ message: err.message });
  }
};
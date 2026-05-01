const db = require("../config/db");

const rewards = [
  { type: "points",   value: 1000, chance: 1  },
  { type: "points",   value: 500,  chance: 3  },
  { type: "points",   value: 250,  chance: 5  },
  { type: "points",   value: 100,  chance: 11 },
  { type: "points",   value: 25,   chance: 20 },
  { type: "points",   value: 10,   chance: 45 },
  { type: "discount", value: 15,   chance: 3  },
  { type: "discount", value: 10,   chance: 5  },
  { type: "discount", value: 5,    chance: 7  },
];

const allowFreeSpin = process.env.ALLOW_FREE_SPIN === "true";

function getRandomReward() {
  const total = rewards.reduce((sum, r) => sum + r.chance, 0);
  const rand  = Math.random() * total;
  let cumulative = 0;
  for (const r of rewards) {
    cumulative += r.chance;
    if (rand <= cumulative) return r;
  }
  return rewards[rewards.length - 1];
}

// ─────────────────────────────────────────────────────────────────────────────
//  GET /api/minigame  →  { points, spins, vouchers, tickets }
// ─────────────────────────────────────────────────────────────────────────────
exports.getGameData = async (req, res) => {
  try {
    const userId = req.user.id;

    // Ensure game_users row exists
    const existing = await db.query(
      "SELECT id FROM game_users WHERE user_id = $1",
      [userId]
    );
    if (existing.rows.length === 0) {
      await db.query(
        "INSERT INTO game_users (user_id, total_points, total_spins) VALUES ($1, 0, 0)",
        [userId]
      );
    }

    // Points
    const pointsRes = await db.query(
      "SELECT total_points FROM game_users WHERE user_id = $1",
      [userId]
    );

    // Vouchers (only unused)
    const vouchersRes = await db.query(
      "SELECT id, value, used, created_at FROM user_rewards WHERE user_id = $1 ORDER BY created_at DESC",
      [userId]
    );

    // Spins available = number of transactions (purchases)
    const trxRes = await db.query(
      "SELECT COUNT(*) FROM transactions WHERE user_id = $1",
      [userId]
    );
    let totalSpins = parseInt(trxRes.rows[0].count);
    if (allowFreeSpin) totalSpins = 999;

    // Ticket count owned by user
    const ticketRes = await db.query(
      "SELECT COUNT(*) FROM tickets WHERE current_owner_id = $1 AND status = 'active'",
      [userId]
    );
    const ticketCount = parseInt(ticketRes.rows[0].count);

    res.json({
      points:   pointsRes.rows[0].total_points,
      spins:    totalSpins,
      vouchers: vouchersRes.rows,
      tickets:  ticketCount,
    });

  } catch (err) {
    console.error("GET GAME ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// ─────────────────────────────────────────────────────────────────────────────
//  POST /api/minigame/spin  →  { type, value, totalPoints, usedSpins, spinsLeft }
// ─────────────────────────────────────────────────────────────────────────────
exports.spin = async (req, res) => {
  try {
    const userId = req.user.id;

    // Total spins available
    const trxRes = await db.query(
      "SELECT COUNT(*) FROM transactions WHERE user_id = $1",
      [userId]
    );
    const totalSpins = parseInt(trxRes.rows[0].count);

    // Spins already used
    const usedRes = await db.query(
      "SELECT total_spins FROM game_users WHERE user_id = $1",
      [userId]
    );

    let used = 0;
    if (usedRes.rows.length > 0) {
      used = usedRes.rows[0].total_spins;
    } else {
      await db.query(
        "INSERT INTO game_users (user_id, total_points, total_spins) VALUES ($1, 0, 0)",
        [userId]
      );
    }

    if (!allowFreeSpin && used >= totalSpins) {
      return res.status(400).json({ message: "Spin habis" });
    }

    // Pick reward
    const reward = getRandomReward();

    // Increment spin counter
    if (!allowFreeSpin) {
      await db.query(
        "UPDATE game_users SET total_spins = total_spins + 1 WHERE user_id = $1",
        [userId]
      );
    }

    // Apply reward
    if (reward.type === "points") {
      await db.query(
        "UPDATE game_users SET total_points = total_points + $1 WHERE user_id = $2",
        [reward.value, userId]
      );
    }

    if (reward.type === "discount") {
      await db.query(
        `INSERT INTO user_rewards (user_id, type, value, used)
         VALUES ($1, 'discount', $2, false)`,
        [userId, reward.value]
      );
    }

    // Fresh data
    const updated = await db.query(
      "SELECT total_points, total_spins FROM game_users WHERE user_id = $1",
      [userId]
    );

    const newUsed = updated.rows[0].total_spins;
    const spinsLeft = allowFreeSpin ? 999 : totalSpins - newUsed;

    res.json({
      type:        reward.type,
      value:       reward.value,
      totalPoints: updated.rows[0].total_points,
      usedSpins:   newUsed,
      spinsLeft:   spinsLeft,
    });

  } catch (err) {
    console.error("SPIN ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};
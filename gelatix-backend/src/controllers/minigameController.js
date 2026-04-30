const db = require("../config/db");

const rewards = [
  { type: "points", value: 1000, chance: 1 },
  { type: "points", value: 500, chance: 3 },
  { type: "points", value: 250, chance: 5 },
  { type: "points", value: 100, chance: 11 },
  { type: "points", value: 25, chance: 20 },
  { type: "points", value: 10, chance: 45 },

  { type: "discount", value: 15, chance: 3 },
  { type: "discount", value: 10, chance: 5 },
  { type: "discount", value: 5, chance: 7 },
];

const allowFreeSpin = process.env.ALLOW_FREE_SPIN === "true";

// weighted random
function getRandomReward() {
  const total = rewards.reduce((sum, r) => sum + r.chance, 0);
  const rand = Math.random() * total;

  let cumulative = 0;

  for (let r of rewards) {
    cumulative += r.chance;
    if (rand <= cumulative) return r;
  }
}

exports.getGameData = async (req, res) => {
  try {
    const userId = req.user.id;

    const userGame = await db.query(
      "SELECT total_points FROM game_users WHERE user_id = $1",
      [userId]
    );

    if (userGame.rows.length === 0) {
      await db.query(
        "INSERT INTO game_users (user_id) VALUES ($1)",
        [userId]
      );
    }

    const pointsRes = await db.query(
      "SELECT total_points FROM game_users WHERE user_id = $1",
      [userId]
    );

    const vouchers = await db.query(
      "SELECT id, value, used FROM user_rewards WHERE user_id = $1",
      [userId]
    );

    const trx = await db.query(
      "SELECT COUNT(*) FROM transactions WHERE user_id = $1",
      [userId]
    );

     let totalSpins = parseInt(trx.rows[0].count);

    if (allowFreeSpin) {
      totalSpins = 999;
    }

    res.json({
      points: pointsRes.rows[0].total_points,
      spins: totalSpins,
      vouchers: vouchers.rows,
    });

  } catch (err) {
    console.error("GET GAME ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};

exports.spin = async (req, res) => {
  try {
    const userId = req.user.id;

    const trx = await db.query(
      "SELECT COUNT(*) FROM transactions WHERE user_id = $1",
      [userId]
    );

    const totalSpins = parseInt(trx.rows[0].count);

    const usedSpin = await db.query(
      "SELECT total_spins FROM game_users WHERE user_id = $1",
      [userId]
    );

    let used = 0;

    if (usedSpin.rows.length > 0) {
      used = usedSpin.rows[0].total_spins;
    } else {
      await db.query(
        "INSERT INTO game_users (user_id) VALUES ($1)",
        [userId]
      );
    }

    if (!allowFreeSpin && used >= totalSpins) {
      return res.status(400).json({
        message: "Spin habis",
      });
    }

    // random reward
    const reward = getRandomReward();

    // update spin
    if (!allowFreeSpin) {
      await db.query(
        "UPDATE game_users SET total_spins = total_spins + 1 WHERE user_id = $1",
        [userId]
      );
    }

    // POINT
    if (reward.type === "points") {
      await db.query(
        "UPDATE game_users SET total_points = total_points + $1 WHERE user_id = $2",
        [reward.value, userId]
      );
    }

    // DISCOUNT
    if (reward.type === "discount") {
      await db.query(
        `INSERT INTO user_rewards (user_id, type, value, used)
         VALUES ($1, 'discount', $2, false)`,
        [userId, reward.value]
      );
    }

    // ambil data terbaru
    const updated = await db.query(
      "SELECT total_points, total_spins FROM game_users WHERE user_id = $1",
      [userId]
    );

    res.json({
      type: reward.type,
      value: reward.value,
      totalPoints: updated.rows[0].total_points,
      usedSpins: updated.rows[0].total_spins,
      spinsLeft: totalSpins - updated.rows[0].total_spins,
    });

  } catch (err) {
    console.error("SPIN ERROR:", err);
    res.status(500).json({ message: "Server error" });
  }
};
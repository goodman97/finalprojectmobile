module.exports = (roles) => {
  return (req, res, next) => {
    try {
      // 🔹 pastikan req.user ada
      if (!req.user) {
        return res.status(401).json({
          message: "Unauthorized (user tidak ditemukan)",
        });
      }

      // 🔹 pastikan role ada
      if (!req.user.role) {
        return res.status(403).json({
          message: "Role tidak ditemukan",
        });
      }

      // 🔹 cek role
      if (!roles.includes(req.user.role)) {
        return res.status(403).json({
          message: `Akses ditolak untuk role: ${req.user.role}`,
        });
      }

      next();
    } catch (err) {
      console.error("Role middleware error:", err.message);
      return res.status(500).json({
        message: "Internal server error",
      });
    }
  };
};

const role = require('../middleware/roleMiddleware');

router.post('/buy', auth, role(['user']), ticketController.buyTicket);
router.post('/transfer', auth, role(['user']), ticketController.transferTicket);
router.post('/scan', auth, role(['eo', 'admin']), ticketController.scanTicket);
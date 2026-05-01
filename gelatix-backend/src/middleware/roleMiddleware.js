module.exports = (roles) => {
  return (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          message: "Unauthorized (user tidak ditemukan)",
        });
      }

      if (!req.user.role) {
        return res.status(403).json({
          message: "Role tidak ditemukan",
        });
      }

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
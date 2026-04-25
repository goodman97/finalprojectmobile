const jwt = require("jsonwebtoken");

module.exports = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      return res.status(401).json({ message: "Token tidak ada" });
    }

    const token = authHeader.split(" ")[1]; // Bearer TOKEN

    const verified = jwt.verify(token, process.env.JWT_SECRET);

    req.user = verified; // { id: ... }

    next();
  } catch (err) {
    return res.status(401).json({ message: "Token tidak valid" });
  }
};
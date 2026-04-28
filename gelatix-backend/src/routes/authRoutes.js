const router = require("express").Router();
const auth = require("../controllers/authController");
const authMiddleware = require("../middleware/authMiddleware");
const upload = require("../middleware/uploadMiddleware");

// AUTH
router.post("/register", auth.register);
router.post("/login", auth.login);

// PROFILE
router.get("/profile", authMiddleware, auth.getProfile);
router.put("/profile", authMiddleware, auth.updateProfile);

// PASSWORD
router.put("/change-password", authMiddleware, auth.changePassword);

// UPLOAD
router.post(
  "/upload-photo",
  authMiddleware,
  upload.single("photo"),
  auth.uploadPhoto
);

module.exports = router;
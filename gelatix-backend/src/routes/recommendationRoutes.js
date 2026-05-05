const express = require('express');
const router  = express.Router();
const ctrl    = require('../controllers/recommendationController');
const auth    = require('../middleware/authMiddleware');

// GET /api/recommendations
router.get('/', auth, ctrl.getRecommendations);

module.exports = router;
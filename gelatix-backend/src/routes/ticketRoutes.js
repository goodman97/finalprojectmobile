const express = require('express');
const router = express.Router();

const ticketController = require('../controllers/ticketController');
const auth = require('../middleware/authMiddleware');

// routes
router.post('/buy', auth, ticketController.buyTicket);
router.post('/transfer', auth, ticketController.transferTicket);
router.post('/scan', auth, ticketController.scanTicket);

// export router
module.exports = router;    

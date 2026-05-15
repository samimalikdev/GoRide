const express = require('express');
const chatController = require('../controllers/chatController');
const { protect } = require('../middlewares/authMiddleware');

const router = express.Router();

router.use(protect);

router.get('/conversations', chatController.getConversations);
router.get('/history/:otherUserId', chatController.getChatHistory);

module.exports = router;

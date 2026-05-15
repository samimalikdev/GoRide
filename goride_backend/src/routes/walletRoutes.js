const express = require('express');
const router = express.Router();
const walletController = require('../controllers/walletController');

router.get('/balance', walletController.getBalance);
router.get('/history', walletController.getTransactionHistory);
router.post('/topup', walletController.topup);
router.post('/payout', walletController.payout);

module.exports = router;

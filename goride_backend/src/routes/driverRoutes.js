const express = require('express');
const router = express.Router();
const driverController = require('../controllers/driverController');
const { protect } = require('../middlewares/authMiddleware');

const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() });

router.post('/submit-verification', protect, driverController.submitVerification);
router.get('/status', protect, driverController.getDriverStatus);
router.post('/upload-document', protect, upload.single('document'), driverController.uploadDocument);
router.post('/toggle-online', protect, driverController.toggleOnline);

module.exports = router;

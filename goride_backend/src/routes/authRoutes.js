const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { protect } = require('../middlewares/authMiddleware');

router.post('/update-profile', protect, authController.updateProfile);

router.post('/signup', authController.signup);
router.post('/login', authController.login);

router.post('/mfa/enroll', authController.enrollMfa);
router.post('/mfa/challenge', authController.challengeMfa);
router.post('/mfa/verify', authController.verifyMfa);
router.get('/mfa/factors', authController.listMfaFactors);
router.delete('/mfa/factors/:factorId', authController.unenrollMfa);
router.post('/update-fcm-token', authController.updateFcmToken);
router.post('/logout', authController.logout);

module.exports = router;

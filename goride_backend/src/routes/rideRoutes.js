const express = require('express');
const router = express.Router();
const rideController = require('../controllers/rideController');

const { protect } = require('../middlewares/authMiddleware');

router.get('/explore/data', protect, rideController.getExploreData);
router.post('/rides/request', rideController.requestRide);
router.post('/rides/accept', rideController.acceptRide);
router.post('/rides/confirm', rideController.confirmRide);
router.post('/rides/reject', rideController.rejectDriver);
router.post('/rides/cancel', rideController.cancelRide);
router.post('/rides/arrive', rideController.notifyArrived);
router.post('/rides/start', rideController.startRide);
router.post('/rides/complete', rideController.completeRide);
router.get('/rides/active', rideController.getActiveRide);
router.get('/rides/history', rideController.getRideHistory);


module.exports = router;

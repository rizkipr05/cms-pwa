const express = require('express');
const router = express.Router();
const attendanceController = require('../controllers/attendanceController');
const { protect, adminOnly } = require('../middleware/authMiddleware');

router.post('/check-in', protect, attendanceController.checkIn);
router.post('/check-out', protect, attendanceController.checkOut);
router.get('/history', protect, attendanceController.getHistory);
router.get('/all', protect, adminOnly, attendanceController.getAllAttendances);

module.exports = router;

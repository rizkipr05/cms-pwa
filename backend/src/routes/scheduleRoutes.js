const express = require('express');
const router = express.Router();
const scheduleController = require('../controllers/scheduleController');
const { protect, adminOnly } = require('../middleware/authMiddleware');

router.get('/', protect, adminOnly, scheduleController.getAllSchedules);
router.post('/', protect, adminOnly, scheduleController.createSchedule);
router.get('/user/:userId', protect, scheduleController.getScheduleByUserId);
router.put('/:id', protect, adminOnly, scheduleController.updateSchedule);
router.delete('/:id', protect, adminOnly, scheduleController.deleteSchedule);

module.exports = router;

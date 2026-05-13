const Schedule = require('../models/Schedule');

exports.getAllSchedules = async (req, res) => {
  try {
    const schedules = await Schedule.findAll({ include: 'user' });
    res.json(schedules);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching schedules', error: error.message });
  }
};

exports.getScheduleByUserId = async (req, res) => {
  try {
    const schedules = await Schedule.findAll({ where: { userId: req.params.userId }, include: 'user' });
    res.json(schedules);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching user schedules', error: error.message });
  }
};

exports.createSchedule = async (req, res) => {
  try {
    const { userId, dayOfWeek, startTime, endTime } = req.body;
    const schedule = await Schedule.create({ userId, dayOfWeek, startTime, endTime });
    res.status(201).json({ message: 'Schedule created', schedule });
  } catch (error) {
    res.status(500).json({ message: 'Error creating schedule', error: error.message });
  }
};

exports.updateSchedule = async (req, res) => {
  try {
    const { id } = req.params;
    const { dayOfWeek, startTime, endTime } = req.body;
    
    const schedule = await Schedule.findByPk(id);
    if (!schedule) return res.status(404).json({ message: 'Schedule not found' });

    schedule.dayOfWeek = dayOfWeek || schedule.dayOfWeek;
    schedule.startTime = startTime || schedule.startTime;
    schedule.endTime = endTime || schedule.endTime;

    await schedule.save();
    res.json({ message: 'Schedule updated', schedule });
  } catch (error) {
    res.status(500).json({ message: 'Error updating schedule', error: error.message });
  }
};

exports.deleteSchedule = async (req, res) => {
  try {
    const { id } = req.params;
    const schedule = await Schedule.findByPk(id);
    if (!schedule) return res.status(404).json({ message: 'Schedule not found' });

    await schedule.destroy();
    res.json({ message: 'Schedule deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting schedule', error: error.message });
  }
};

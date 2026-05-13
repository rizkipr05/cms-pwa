const Attendance = require('../models/Attendance');
const haversine = require('haversine-distance');

// Example Office Coordinates (Replace with actual)
const OFFICE_LAT = process.env.OFFICE_LAT || -6.200000;
const OFFICE_LNG = process.env.OFFICE_LNG || 106.816666;
const MAX_DISTANCE_METERS = process.env.MAX_DISTANCE || 50;
const APP_TIMEZONE = process.env.APP_TIMEZONE || 'Asia/Jakarta';

const getToday = () =>
  new Intl.DateTimeFormat('en-CA', {
    timeZone: APP_TIMEZONE,
  }).format(new Date());

const parseCoordinates = (lat, lng) => {
  const latitude = Number(lat);
  const longitude = Number(lng);

  if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
    return null;
  }

  return { latitude, longitude };
};

exports.checkIn = async (req, res) => {
  try {
    const { lat, lng } = req.body;
    const userId = req.user.id;

    const coordinates = parseCoordinates(lat, lng);
    if (!coordinates) {
      return res.status(400).json({ message: 'Location is required' });
    }

    const userLocation = coordinates;
    const officeLocation = { latitude: OFFICE_LAT, longitude: OFFICE_LNG };
    
    const distance = haversine(userLocation, officeLocation);
    if (distance > MAX_DISTANCE_METERS) {
      return res.status(403).json({ message: `You are too far from the office. Distance: ${Math.round(distance)}m` });
    }

    // Check if already checked in today
    const today = getToday();
    const existing = await Attendance.findOne({ where: { userId, date: today } });
    if (existing && existing.checkInTime) {
      return res.status(400).json({ message: 'Already checked in today' });
    }

    let attendance = existing;
    if (!attendance) {
        attendance = await Attendance.create({
            userId,
            date: today,
            checkInTime: new Date(),
            checkInLocationLat: coordinates.latitude,
            checkInLocationLng: coordinates.longitude,
            status: 'present'
        });
    } else {
        attendance.checkInTime = new Date();
        attendance.checkInLocationLat = coordinates.latitude;
        attendance.checkInLocationLng = coordinates.longitude;
        attendance.status = 'present';
        await attendance.save();
    }

    res.json({ message: 'Checked in successfully', attendance });
  } catch (error) {
    res.status(500).json({ message: 'Error during check-in', error: error.message });
  }
};

exports.checkOut = async (req, res) => {
    try {
        const { lat, lng } = req.body;
        const userId = req.user.id;
    
        const coordinates = parseCoordinates(lat, lng);
        if (!coordinates) {
          return res.status(400).json({ message: 'Location is required' });
        }
    
        const userLocation = coordinates;
        const officeLocation = { latitude: OFFICE_LAT, longitude: OFFICE_LNG };
        
        const distance = haversine(userLocation, officeLocation);
        if (distance > MAX_DISTANCE_METERS) {
          return res.status(403).json({ message: `You are too far from the office. Distance: ${Math.round(distance)}m` });
        }
    
        const today = getToday();
        const attendance = await Attendance.findOne({ where: { userId, date: today } });
        if (!attendance || !attendance.checkInTime) {
          return res.status(400).json({ message: 'You must check in first' });
        }
        if (attendance.checkOutTime) {
            return res.status(400).json({ message: 'Already checked out today' });
        }
    
        attendance.checkOutTime = new Date();
        attendance.checkOutLocationLat = coordinates.latitude;
        attendance.checkOutLocationLng = coordinates.longitude;
        await attendance.save();
    
        res.json({ message: 'Checked out successfully', attendance });
      } catch (error) {
        res.status(500).json({ message: 'Error during check-out', error: error.message });
      }
};

exports.getHistory = async (req, res) => {
    try {
        const attendances = await Attendance.findAll({
          where: { userId: req.user.id },
          order: [
            ['date', 'DESC'],
            ['createdAt', 'DESC'],
          ],
        });
        res.json(attendances);
    } catch(err) {
        res.status(500).json({ message: 'Error fetching history', error: err.message });
    }
}

exports.getAllAttendances = async (req, res) => {
    try {
        const attendances = await Attendance.findAll({ include: 'user' });
        res.json(attendances);
    } catch(err) {
        res.status(500).json({ message: 'Error fetching attendances', error: err.message });
    }
}

const bcrypt = require('bcryptjs');
const User = require('../models/User');
const Schedule = require('../models/Schedule');
const sequelize = require('../config/database');

const seedUser = async () => {
  try {
    await sequelize.authenticate();
    
    let user = await User.findOne({ where: { email: 'user@presensi.com' } });
    if (!user) {
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash('user123', salt);

      user = await User.create({
        name: 'Karyawan Demo',
        email: 'user@presensi.com',
        password: hashedPassword,
        role: 'user'
      });
      console.log('User employee seeded successfully');

      // Add dummy schedule
      await Schedule.create({
        userId: user.id,
        dayOfWeek: 'Monday',
        startTime: '08:00:00',
        endTime: '17:00:00'
      });
      console.log('Dummy schedule added for user');
    } else {
      console.log('User employee already exists');
    }
    process.exit(0);
  } catch (error) {
    console.error('Error seeding user:', error);
    process.exit(1);
  }
};

seedUser();

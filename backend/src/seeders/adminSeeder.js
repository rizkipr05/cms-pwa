const bcrypt = require('bcryptjs');
const User = require('../models/User');
const sequelize = require('../config/database');

const seedAdmin = async () => {
  try {
    await sequelize.authenticate();
    
    const adminExists = await User.findOne({ where: { email: 'admin@presensi.com' } });
    if (!adminExists) {
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash('admin123', salt);

      await User.create({
        name: 'Super Admin',
        email: 'admin@presensi.com',
        password: hashedPassword,
        role: 'admin'
      });
      console.log('Admin user seeded successfully');
    } else {
      console.log('Admin user already exists');
    }
    process.exit(0);
  } catch (error) {
    console.error('Error seeding admin:', error);
    process.exit(1);
  }
};

seedAdmin();

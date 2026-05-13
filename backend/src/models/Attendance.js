const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const User = require('./User');

const Attendance = sequelize.define('Attendance', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  userId: {
    type: DataTypes.INTEGER,
    references: {
      model: User,
      key: 'id'
    }
  },
  date: {
    type: DataTypes.DATEONLY,
    allowNull: false,
  },
  checkInTime: {
    type: DataTypes.DATE, // Storing full timestamp for check-in
    allowNull: true,
  },
  checkOutTime: {
    type: DataTypes.DATE, // Storing full timestamp for check-out
    allowNull: true,
  },
  checkInLocationLat: {
      type: DataTypes.DOUBLE,
      allowNull: true,
  },
  checkInLocationLng: {
      type: DataTypes.DOUBLE,
      allowNull: true,
  },
  checkOutLocationLat: {
      type: DataTypes.DOUBLE,
      allowNull: true,
  },
  checkOutLocationLng: {
      type: DataTypes.DOUBLE,
      allowNull: true,
  },
  status: {
      type: DataTypes.ENUM('present', 'late', 'absent'),
      defaultValue: 'absent'
  }
}, {
  tableName: 'attendances',
  timestamps: true,
});

// Associations
User.hasMany(Attendance, { foreignKey: 'userId', as: 'attendances' });
Attendance.belongsTo(User, { foreignKey: 'userId', as: 'user' });

module.exports = Attendance;

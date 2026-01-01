const mongoose = require('mongoose');

const gradeSchema = new mongoose.Schema({
  studentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  classId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Class',
    required: true
  },
  adminId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  gradesData: {
    type: Object, // empty JSON for now
    default: {}
  }
});

module.exports = mongoose.model('Grade', gradeSchema);

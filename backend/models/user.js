const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    lowercase: true
  },
  role: {
    type: String,
    required: true,
    enum: ['admin', 'teacher', 'student']
  },
  email: {
    type: String,
    required: true,
    unique: true,
    match: /.+\@.+\..+/ // simple email validation
  },
  classId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Class' // only for students
  }
});

module.exports = mongoose.model('User', userSchema);
    
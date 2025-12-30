const mongoose = require('mongoose');

const classSchema = new mongoose.Schema({
  grade: {
    type: Number,
    required: true,
    max: 12
  },
  section: {
    type: String,
    required: true,
    uppercase: true
  }
});

module.exports = mongoose.model('Class', classSchema);

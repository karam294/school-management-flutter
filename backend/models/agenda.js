const mongoose = require('mongoose');

const agendaSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    uppercase: true
  },
  type: {
    type: String,
    required: true,
    enum: ['homework', 'test', 'other']
  },
  description: {
    type: String,
    required: true
  },
  dueDate: {
    type: Date,
    required: true
  },
  teacherId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  classId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Class',
    required: true
  },
  materials: {
    type: [String] // array of file URLs / links
  }
});

module.exports = mongoose.model('Agenda', agendaSchema);

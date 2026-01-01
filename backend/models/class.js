const mongoose = require("mongoose");

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
  },

  // ✅ Foreign key + Array (for populate)
  students: [
    { type: mongoose.Schema.Types.ObjectId, ref: "User" }
  ],

  // ✅ JSON field (optional but nice for requirements)
  meta: { type: Object }
});

module.exports = mongoose.model("Class", classSchema);

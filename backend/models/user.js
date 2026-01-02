const mongoose = require('mongoose');
const bcrypt = require('bcrypt'); // make sure you installed it

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
  password: {
    type: String,
    required: true
  },
  isActive: { type: Boolean, default: true },
  classId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Class' // only for students
  }
});

// Pre-save hook to hash the password automatically
userSchema.pre('save', async function() {
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 10);
  }
});


// Method to compare passwords for login
userSchema.methods.comparePassword = async function(inputPassword) {
  return bcrypt.compare(inputPassword, this.password);
};

module.exports = mongoose.model('User', userSchema);

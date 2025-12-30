const mongoose = require('mongoose');
const connectDB = require('./config/db');
const User = require('./models/user');

const insertUser = async () => {
  try {
    // Connect to MongoDB
 

    // Create a new user
    const user = new User({
      name: 'alice',
      role: 'student',
      email: 'alice@example.com'
    });

    await user.save(); // insert into MongoDB
    console.log('User created successfully');

    mongoose.connection.close(); // close connection
  } catch (err) {
    console.error(err);
  }
};

insertUser();

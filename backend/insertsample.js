const mongoose = require('mongoose');
const connectDB = require('./config/db'); // your DB connection file
const User = require('./models/user');

const insertUser = async () => {
  try {
    // Connect to MongoDB
    await connectDB();

    // Create a new user
    const user = new User({
      name: 'Alice',
      role: 'student',
      email: 'alice@example.com',
      password: 'Karam123!' // plain text here, will be hashed automatically
    });

    await user.save(); // insert into MongoDB
    console.log('User created successfully:', user);

    await mongoose.connection.close(); // close connection
  } catch (err) {
    console.error(err);
  }
};

insertUser();

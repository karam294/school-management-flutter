const express = require('express');
const connectDB = require('./config/db');
const userRoutes =require("./routes/userRoutes");
const classRoutes = require("./routes/classRoutes");
const app = express();
const  cors = require ("cors");

app.use(express.json());

app.use(cors());

// Connect to MongoDB
connectDB();

app.get('/', (req, res) => res.send('API running'));
app.use("/users", userRoutes);
app.use("/classes", classRoutes);
const PORT = 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

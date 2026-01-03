const express = require('express');
const connectDB = require('./config/db');
const userRoutes = require("./routes/userRoutes");
const classRoutes = require("./routes/classRoutes");
const agendaRoutes = require("./routes/agendaRoutes");
const gradeRoutes = require("./routes/gradeRoutes");
const cors = require("cors");

const app = express();

app.use(express.json());
app.use(cors());

// Connect to MongoDB
connectDB();

app.get('/', (req, res) => res.send('API running'));

app.use("/users", userRoutes);
app.use("/classes", classRoutes);
app.use("/agendas", agendaRoutes);
app.use("/grades", gradeRoutes);

const PORT = 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

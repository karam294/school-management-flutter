const User = require("../models/user");
const bcrypt = require("bcrypt");
const ClassModel = require("../models/class");

/* ---------------- REGISTER ---------------- */
exports.createUser = async (req, res) => {
  try {
    const { name, email, password, role, classId } = req.body;

    if (!name || !email || !password || !role) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const user = await User.create({
      name,
      email,
      password,
      role,
      classId,
    });

    res.status(201).json(user);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

/* ---------------- LOGIN (EMAIL + PASSWORD) ---------------- */
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: "Email and password required" });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const ok = await user.comparePassword(password);
    if (!ok) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ---------------- UPDATE ---------------- */
exports.updateUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    res.json(user);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

/* ---------------- GET USERS ---------------- */
exports.getUsersByCriteria = async (req, res) => {
  try {
    const filter = {};
    if (req.query.role) filter.role = req.query.role;
    if (req.query.email) filter.email = req.query.email;
    if (req.query.name) filter.name = req.query.name;

    const users = await User.find(filter);
    res.json(users);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

/* ---------------- DELETE ---------------- */
exports.deleteUser = async (req, res) => {
  try {
    const u = await User.findById(req.params.id);
    if (!u) return res.status(404).json({ error: "User not found" });

    if (u.role === "student" && u.classId) {
      await ClassModel.findByIdAndUpdate(u.classId, {
        $pull: { students: u._id },
      });
    }

    await User.findByIdAndDelete(req.params.id);
    res.json({ message: "User deleted" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

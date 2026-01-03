const User = require("../models/user");
const ClassModel = require("../models/class"); // only if you use it in deleteUser

/* ---------------- REGISTER / CREATE ---------------- */
exports.createUser = async (req, res) => {
  try {
    const user = await User.create(req.body);
    res.status(201).json(user);
  } catch (err) {
    return res.status(400).json({ error: err.message });
  }
};

/* ---------------- LOGIN (OLD) ---------------- */
exports.login = async (req, res) => {
  try {
    const { email, role } = req.body;

    if (!email || !role) {
      return res.status(400).json({ error: "Missing credentials" });
    }

    const user = await User.findOne({ email, role });
    if (!user) {
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
    const { role, name, email } = req.query;

    const filter = {};
    if (role) filter.role = role;
    if (name) filter.name = name;
    if (email) filter.email = email;

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

    // if student remove from class list
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

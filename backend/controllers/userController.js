const User = require("../models/user");

/* ---------------- REGISTER ---------------- */
exports.createUser = async (req, res) => {
  try {
    const user = await User.create(req.body);

    const userObj = user.toObject();
    delete userObj.password;

    res.status(201).json(userObj);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

/* ---------------- LOGIN ---------------- */
exports.login = async (req, res) => {
  try {
    const { email, password, role } = req.body;

    if (!email || !password || !role) {
      return res.status(400).json({ error: "Missing credentials" });
    }

    const user = await User.findOne({ email, role });
    if (!user) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const userObj = user.toObject();
    delete userObj.password;

    res.json(userObj);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/* ---------------- OTHER ---------------- */
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

exports.getUsersByCriteria = async (req, res) => {
  try {
    const { role, name, email } = req.query;

    const filter = {};
    if (role) filter.role = role;
    if (name) filter.name = name;
    if (email) filter.email = email;

    const users = await User.find(filter).select("-password");
    res.json(users);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

exports.deleteUser = async (req, res) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.json({ message: "User deleted" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

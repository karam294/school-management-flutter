const User = require("../models/user");

// CREATE (insert)
exports.createUser = async (req, res) => {
  try {
    const user = await User.create(req.body);
    res.status(201).json(user);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// UPDATE
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

// FIND with 2 criteria (example: role + email OR role + name)
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
exports.deleteUser = async (req, res) => {
  try {
    await User.findByIdAndDelete(req.params.id);
    res.json({ message: "User deleted" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};
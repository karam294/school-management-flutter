const ClassModel = require("../models/class");

// CREATE class
exports.createClass = async (req, res) => {
  try {
    const created = await ClassModel.create(req.body);
    res.status(201).json(created);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// ✅ POPULATE: get class with students
exports.getClassWithStudents = async (req, res) => {
  try {
    const data = await ClassModel.findById(req.params.id).populate("students");
    res.json(data);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// ✅ AGGREGATE: stats (number of students per class)
exports.classStats = async (req, res) => {
  try {
    const stats = await ClassModel.aggregate([
      { $project: { grade: 1, section: 1, totalStudents: { $size: "$students" } } },
      { $sort: { totalStudents: -1 } }
    ]);
    res.json(stats);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};
exports.getAllClasses = async (req, res) => {
  try {
    const data = await ClassModel.find();
    res.json(data);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};
exports.deleteClass = async (req, res) => {
  try {
    await ClassModel.findByIdAndDelete(req.params.id);
    res.json({ message: "Class deleted" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};
const Grade = require("../models/grade");

// CREATE
exports.createGrade = async (req, res) => {
  try {
    const created = await Grade.create(req.body);
    res.status(201).json(created);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// UPDATE
exports.updateGrade = async (req, res) => {
  try {
    const updated = await Grade.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// FIND by criteria (2 criteria)
exports.getGradesByCriteria = async (req, res) => {
  try {
    const { studentId, classId } = req.query;

    const filter = {};
    if (studentId) filter.studentId = studentId;
    if (classId) filter.classId = classId;

    const data = await Grade.find(filter)
      .populate("studentId", "name email role")
      .populate("classId", "grade section")
      .populate("adminId", "name email role");

    res.json(data);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

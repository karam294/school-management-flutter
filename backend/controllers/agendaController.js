const Agenda = require("../models/agenda");

// CREATE (insert)
exports.createAgenda = async (req, res) => {
  try {
    const agenda = await Agenda.create(req.body);
    res.status(201).json(agenda);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// FIND by criteria (2+ criteria)
exports.getAgendaByCriteria = async (req, res) => {
  try {
    const { classId, teacherId, type, dueDate } = req.query;

    const filter = {};
    if (classId) filter.classId = classId;
    if (teacherId) filter.teacherId = teacherId;
    if (type) filter.type = type;

    // dueDate: accept "2026-01-02" and match same day
    if (dueDate) {
      const start = new Date(dueDate);
      const end = new Date(dueDate);
      end.setDate(end.getDate() + 1);
      filter.dueDate = { $gte: start, $lt: end };
    }

    // populate foreign keys to show data
    const data = await Agenda.find(filter)
      .populate("teacherId", "name email role")
      .populate("classId", "grade section");

    res.json(data);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

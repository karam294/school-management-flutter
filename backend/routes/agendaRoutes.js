const router = require("express").Router();
const {
  createAgenda,
  getAgendaByCriteria,
} = require("../controllers/agendaController");

// create agenda
router.post("/", createAgenda);

// find agenda by criteria (ex: classId + dueDate OR teacherId + type)
router.get("/", getAgendaByCriteria);

module.exports = router;


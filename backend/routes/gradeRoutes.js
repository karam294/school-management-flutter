const router = require("express").Router();
const {
  createGrade,
  updateGrade,
  getGradesByCriteria,
} = require("../controllers/gradeController");

// create
router.post("/", createGrade);

// update
router.put("/:id", updateGrade);

// find (studentId + classId)
router.get("/", getGradesByCriteria);

module.exports = router;

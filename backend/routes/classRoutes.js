const router = require("express").Router();
const {
  createClass,
  getClassWithStudents,
  classStats,
  getAllClasses,
  addStudentToClass,
  removeStudentFromClass,
  deleteClass,
} = require("../controllers/classController");

router.post("/", createClass);

router.get("/stats/all", classStats);
router.get("/", getAllClasses);

// student management
router.post("/:id/addStudent", addStudentToClass);
router.post("/:id/removeStudent", removeStudentFromClass);

// populate
router.get("/:id", getClassWithStudents);

router.delete("/:id", deleteClass);

module.exports = router;

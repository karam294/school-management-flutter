const router = require("express").Router();
const { createClass, getClassWithStudents, classStats , getAllClasses, deleteClass} = require("../controllers/classController");

router.post("/", createClass);

// ✅ populate


// ✅ aggregate
router.get("/stats/all", classStats);
router.get("/",getAllClasses);
router.get("/:id", getClassWithStudents);
router.delete("/:id", deleteClass);

module.exports = router;
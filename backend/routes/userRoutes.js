const router = require("express").Router();
const {
  createUser,
  updateUser,
  getUsersByCriteria,
  deleteUser,
} = require("../controllers/userController");

router.post("/", createUser);
router.put("/:id", updateUser);
router.get("/", getUsersByCriteria);
router.delete("/:id", deleteUser);

module.exports = router;

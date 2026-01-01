const router = require("express").Router();
const {
  createUser,
  updateUser,
  getUsersByCriteria,
  deleteUser,
} = require("../controllers/userController");

// create/insert
router.post("/", createUser);

// update
router.put("/:id", updateUser);

// find with criteria
// example: /users?role=student&name=alice
router.get("/", getUsersByCriteria);
router.delete("/:id", deleteUser);
module.exports = router;
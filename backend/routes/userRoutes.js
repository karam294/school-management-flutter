const router = require("express").Router();
const {
  createUser,
  updateUser,
  getUsersByCriteria,
  deleteUser,
  login, // ✅ now exists
} = require("../controllers/userController");

// register
router.post("/", createUser);

// login
router.post("/login", login);

// update
router.put("/:id", updateUser);

// find users
router.get("/", getUsersByCriteria);

// delete
router.delete("/:id", deleteUser);

module.exports = router;

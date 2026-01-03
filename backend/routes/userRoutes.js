const router = require("express").Router();
const {
  createUser,
  updateUser,
  getUsersByCriteria,
  deleteUser,
  login,
} = require("../controllers/userController");

// create user
router.post("/", createUser);

// login (email + role)
router.post("/login", login);

// update
router.put("/:id", updateUser);

// find users
router.get("/", getUsersByCriteria);

// delete
router.delete("/:id", deleteUser);

module.exports = router;

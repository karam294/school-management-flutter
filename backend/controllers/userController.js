const User = require("../models/user");
const ClassModel = require("../models/class");

/*
  CREATE user
  - If role = student: requires grade + section, auto-assign classId and add user to Class.students
  - If role = teacher/admin: normal create
*/
exports.createUser = async (req, res) => {
  try {
    const { name, email, role, grade, section } = req.body;

    if (!name || !email || !role) {
      return res.status(400).json({ error: "name, email, role are required" });
    }

    // STUDENT REGISTER → need grade + section
    if (role === "student") {
      if (grade == null || !section) {
        return res
          .status(400)
          .json({ error: "For student: grade and section are required" });
      }

      // Find or create the class
      let cls = await ClassModel.findOne({
        grade: Number(grade),
        section: String(section).toUpperCase(),
      });

      if (!cls) {
        cls = await ClassModel.create({
          grade: Number(grade),
          section: String(section).toUpperCase(),
          students: [],
          meta: {},
        });
      }

      // Create student with classId
      const student = await User.create({
        name,
        email,
        role,
        classId: cls._id,
      });

      // Add student to class.students
      await ClassModel.findByIdAndUpdate(
        cls._id,
        { $addToSet: { students: student._id } },
        { new: true }
      );

      return res.status(201).json(student);
    }

    // TEACHER / ADMIN
    const user = await User.create({ name, email, role });
    return res.status(201).json(user);
  } catch (err) {
    return res.status(400).json({ error: err.message });
  }
};

// UPDATE
exports.updateUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    res.json(user);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// FIND with criteria
// example: /users?role=student&name=alice OR /users?role=student&email=a@b.com
exports.getUsersByCriteria = async (req, res) => {
  try {
    const { role, name, email } = req.query;

    const filter = {};
    if (role) filter.role = role;
    if (name) filter.name = name;
    if (email) filter.email = email;

    const users = await User.find(filter);
    res.json(users);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// DELETE user
// if student: also remove from class.students
exports.deleteUser = async (req, res) => {
  try {
    const u = await User.findById(req.params.id);
    if (!u) return res.status(404).json({ error: "User not found" });

    // if student remove from class list
    if (u.role === "student" && u.classId) {
      await ClassModel.findByIdAndUpdate(u.classId, {
        $pull: { students: u._id },
      });
    }

    await User.findByIdAndDelete(req.params.id);
    res.json({ message: "User deleted" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// routes/index.js

// modules
const express = require("express");
const router = express.Router();

// local modules
const indexController = require("../controllers/index.js");

// default AsciiDoc preview page
router.get("/", indexController.page);

// modul export
module.exports = router;

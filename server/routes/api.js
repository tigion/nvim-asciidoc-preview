// routes/api.js

// modules
const express = require("express");
const router = express.Router();

// local modules
const apiController = require("../controllers/api.js");

// --- resource: server ---

// get server
router.get("/server", apiController.getServer);

// --- resource: file ---

// get file
router.get("/file", apiController.getFile);

// set or update file
router.put("/file", apiController.setFile);

// --- resource: hi ---

// hi
router.get("/hi", apiController.hi);

// --- actions ---

// subscribe client
router.get("/actions/subscribe", apiController.subscribe);

// notify all registered clients to update
router.post("/actions/notify", apiController.notify);

// stop server
router.post("/actions/stop", apiController.stop);

// module export
module.exports = router;

// routes/api.js

// modules
const express = require("express");
const router = express.Router();

// local modules
const apiController = require("../controllers/api.js");

// --- resource: server ---

// get server
router.get("/server", apiController.getServer);

// --- resource: options ---

// get options
router.get("/options", apiController.getOptions);

// set or update options
router.put("/options", apiController.setOptions);

// --- resource: file ---

// get preview
router.get("/preview", apiController.getPreview);

// set or update preview
router.put("/preview", apiController.setPreview);

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

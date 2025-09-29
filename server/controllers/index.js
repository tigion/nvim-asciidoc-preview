// controllers/index.js

// modules
const path = require("path");

// local modules
const data = require("../data.js");
const asciidoc = require("../controllers/asciidoc.js");

// The sendFile options
const options = {
  dotfiles: "allow",
};

// send page templates or AsciiDoc preview to clients
exports.page = (_req, res) => {
  if (data.preview.isFinished) {
    // send server has stopped HTML template
    res.sendFile(path.join(__dirname, "../templates/stop.html"), options);
  } else if (data.preview.filepath) {
    // send AsciiDoc file converted to HTML
    res.send(
      asciidoc.convertAsciidocToHtml(
        data.config.asciidoc.converter,
        data.preview.filepath,
        data.config.cachedir,
      ),
    );
  } else {
    // send server has started HTML template
    res.sendFile(path.join(__dirname, "../templates/wait.html"), options);
  }
};

// controllers/index.js

// modules
const path = require('path')

// local modules
const data = require('../data.js')
const asciidoc = require('../controllers/asciidoc.js')

// send page templates or AsciiDoc preview to clients
exports.page = (req, res) => {
  if (data.asciidoc.file === 'stop') {
    // send server has stopped HTML template
    res.sendFile(path.join(__dirname, '../templates/stop.html'))
  } else if (data.asciidoc.file) {
    // send AsciiDoc file converted to HTML
    res.send(asciidoc.convertAsciidocToHtml(data.asciidoc.converter, data.asciidoc.file))
  } else {
    // send server has started HTML template
    res.sendFile(path.join(__dirname, '../templates/wait.html'))
  }
}

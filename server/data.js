// data.js

// The default configuration
const config = {
  server: {
    // The server hostname
    hostname: "127.0.0.1",

    // The server port
    // NOTE: Dont use port 5000 under macOS (already in use: AirPlay Receiver)
    port: 11235,
  },
  asciidoc: {
    // The allowed extensions for an AsciiDoc file
    extensions: ["asc", "adoc", "asciidoc"],

    // The converter for converting AsciiDoc to HTML
    // 'js' or 'cmd'
    converter: "js",
  },
  // Determines whether the web browser should be opened
  openBrowser: false,
};

// The preview data
const preview = {
  // The filepath of the file to be previewed
  filepath: "",

  // Determines the preview position
  // `-1`    - Keep current scroll position (current)
  // `0`     - Start of the website (start)
  // `1-100` - Position in percent
  // `500px` - Position in pixel // TODO: Needed?
  position: 0,

  // Determines whether the preview is finished
  isFinished: false,
};

// The instance of the `http.Server` server
let server = null;
// The registered clients
const clients = [];

module.exports = {
  config,
  preview,
  server,
  clients,
};

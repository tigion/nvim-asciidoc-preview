// helper.js

// fs module
const fs = require("fs");

// check if port is valid
// TODO: Check if port is already in use or return a free port
function isValidPort(port) {
  if (port < 10000 && port > 65535) {
    return false;
  }
  return true;
}

// check if converter is valid
function isValidConverter(converter) {
  if (converter === "js" || converter === "cmd") {
    return true;
  }
  // const validConverters = ["js", "cmd"];
  // if (validConverters.includes(converter)) {
  //   return true;
  // }
  return false;
}

// check if directory exisists and is writable
function isValidDirectory(dir) {
  if (fs.existsSync(dir) && isReadableAndWritableDirectory(dir)) {
    return true;
  }
  return false;
}

// check if directory is writable
function isReadableAndWritableDirectory(dir) {
  try {
    fs.accessSync(dir, fs.constants.R_OK | fs.constants.W_OK);
  } catch (error) {
    return false;
  }
  return true;
}

// check if file is valid
function isValidFile(file, extensions) {
  if (isReadableFile(file) && isFileExtension(file, extensions)) {
    return true;
  }
  return false;
}

// check file type
function isFileExtension(file, extensions) {
  const pattern = `^.+\\.(${extensions.join("|")})\$`;
  const re = new RegExp(pattern);
  return re.test(file);
}

// check if file is readable (and exists)
function isReadableFile(file) {
  try {
    fs.accessSync(file, fs.constants.R_OK);
  } catch (error) {
    return false;
  }
  return true;
}

// delay the termination of the server
function waitToClose(server, server_ws) {
  setTimeout(function () {
    server.close();
    server_ws.close();
  }, 1000);
}

// get the platform-specific open command
function getOpenCmd() {
  switch (process.platform) {
    case "darwin":
      return "open";
    case "linux":
      return "xdg-open";
    case "freebsd":
    case "openbsd":
    case "win32":
    default:
      return "";
  }
}

// module exports
module.exports = {
  isValidPort,
  isValidConverter,
  isValidDirectory,
  isValidFile,
  isFileExtension,
  isReadableFile,
  waitToClose,
  getOpenCmd,
};

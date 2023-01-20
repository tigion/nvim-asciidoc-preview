// helper.js

// fs module
const fs = require('fs')

// module exports
module.exports = {
  isValidFile,
  isFileExtension,
  isReadableFile,
  waitToClose,
  getOpenCmd,
}

// check if file is valid
function isValidFile(file, extensions) {
  if (isReadableFile(file) && isFileExtension(file, extensions)) {
    return true
  }
  return false
}

// check file type
function isFileExtension(file, extensions) {
  const pattern = `^.+\\.(${extensions.join('|')})\$`
  const re = new RegExp(pattern);
  return re.test(file)
}

// check if file is readable (and exists)
function isReadableFile(file) {
  try {
    fs.accessSync(file, fs.constants.R_OK)
  } catch (error) {
    return false
  }
  return true
}

// delay the termination of the server
function waitToClose(server) {
  setTimeout(function() {
    server.close()
  }, 1000);
}

// get the platform-specific open command
function getOpenCmd() {
  switch (process.platform) {
    case 'darwin':
      return 'open'
    case 'linux':
      return 'xdg-open'
    case 'freebsd': case 'openbsd': case 'win32':
    default:
      return ''
  }
}

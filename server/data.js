// data.js

const data = {
  config: {
    hostname: '127.0.0.1',
    port: 11235, // dont use port 5000 under macOS (already in use: AirPlay Receiver)
    openBrowser: false,
  },
  asciidoc: {
    extensions: ['asc', 'adoc', 'asciidoc'],
    converter: 'js', // 'js' or 'cmd'
    file: '',
  },
  server: null,
  clients: [],
}

module.exports = data

// controller/asciidoc.js

// set reload script
const reloadScript = '<script src="script.js"></script>'

// convert AsciiDoc to HTML
function convertAsciidocToHtml(processor, file) {
  switch (processor) {
    case 'js':
      return convertWithAsciidoctorJs(file)
    case 'cmd':
      return convertWithAsciidoctorCmd(file)
    default:
      return '<p>Invalid converter!</p>'
  }
}

// convert with Asciidoctor.js
function convertWithAsciidoctorJs(file) {
  // needed Asciidoctor modules
  const Asciidoctor = require('asciidoctor')
  const asciidoctor = Asciidoctor()
  const kroki = require('asciidoctor-kroki')
  kroki.register(asciidoctor.Extensions)
  const registry = asciidoctor.Extensions.create()

  // add script for client registration and refresh event
  registry.docinfoProcessor(function() {
    var self = this
    self.atLocation('head')
    self.process(function() {
      return reloadScript
    })
  })

  // convert file with Asciidoctor.js to html
  return asciidoctor.convertFile(file, {
    to_file: false,
    standalone: true,
    safe: 'unsafe', // unsafe: access files outside of the parent directory
    attributes: {
      webfonts: '', // use webfonts
      'data-uri': '', // embed images (base64)
    },
    //'base_dir': '',
    'extension_registry': registry
  })
}

// convert with local installed Asciidoctor tools
function convertWithAsciidoctorCmd(file) {
  // -a ... set document attributes (overwrites source attributes)
  //        - webfonts ... use webfonts
  //        - toc=auto ... theme of content
  //        - data-uri ... embedd images as base64
  // -e ... for embedded documents
  // -o ... output target (`-` stdout)
  var attributes= '-a toc=auto -a data-uri'
  var resources = '-r asciidoctor-diagram'
  var cmd = 'asciidoctor'
  cmd = `${cmd} ${resources} ${attributes} -o - "${file}"`

  // convert mit Asciidoctor command
  const childProcess = require('child_process')
  const stdout = childProcess.execSync(cmd)

  // add script for client registration and refresh event
  // (not perfect, but it works)
  return stdout.toString() + reloadScript
}

// module exports
module.exports = {
  convertAsciidocToHtml,
}

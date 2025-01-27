// controller/asciidoc.js

// set reload script
const reloadScript = '<script src="script.js"></script>';

// convert AsciiDoc to HTML
function convertAsciidocToHtml(processor, file, cacheDir) {
  switch (processor) {
    case "js":
      return convertWithAsciidoctorJs(file);
    case "cmd":
      return convertWithAsciidoctorCmd(file, cacheDir);
    default:
      return "<p>Invalid converter!</p>";
  }
}

// convert with Asciidoctor.js
function convertWithAsciidoctorJs(file) {
  // needed Asciidoctor modules
  const Asciidoctor = require("asciidoctor");
  const asciidoctor = Asciidoctor();
  const kroki = require("asciidoctor-kroki");
  kroki.register(asciidoctor.Extensions);
  const registry = asciidoctor.Extensions.create();

  // add script for client registration and refresh event
  registry.docinfoProcessor(function () {
    const self = this;
    self.atLocation("head");
    self.process(function () {
      return reloadScript;
    });
  });

  // convert file with Asciidoctor.js to html
  return asciidoctor.convertFile(file, {
    to_file: false,
    standalone: true,
    safe: "unsafe", // unsafe: access files outside of the parent directory
    attributes: {
      webfonts: "", // use webfonts
      "data-uri": "", // embed images (base64)
    },
    //base_dir: '',
    extension_registry: registry,
  });
}

// convert with local installed Asciidoctor tools
function convertWithAsciidoctorCmd(file, cacheDir) {
  // -a ... set document attributes (overwrites source attributes)
  //        - webfonts ... use webfonts
  //        - toc=auto ... theme of content
  //        - data-uri ... embed images as base64
  // -e ... for embedded documents
  // -o ... output target (`-` stdout)
  const attributes = "-a toc=auto -a data-uri";
  const resources = "-r asciidoctor-diagram";
  let cmd = "asciidoctor";
  cmd = `${cmd} ${resources} ${attributes} -o - "${file}"`;

  // set command to run asciidoctor in cache directory
  cmd = `mkdir -p "${cacheDir}" && cd "${cacheDir}" && ${cmd}`;
  // console.log("DEBUG: " + cmd);

  // FIX: Handle build artefacts?!
  //      - Remove all generated files (content of build folder)
  //      - Generate on source file path
  //      - Generate on ~/.local/state/nvim/asciidoctor-preview
  //
  // convert mit Asciidoctor command
  const childProcess = require("child_process");
  const stdout = childProcess.execSync(cmd, { stdio: "ignore" });

  // add script for client registration and refresh event
  // (not perfect, but it works)
  return stdout.toString() + reloadScript;
}

// module exports
module.exports = {
  convertAsciidocToHtml,
};
